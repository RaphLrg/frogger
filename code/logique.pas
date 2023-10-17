{
- Jeu multijoueur
}

unit logique;

interface

uses typesFrogger,  sdl_mixer, sdl, unitDeplacementObjets, menu_unit, unitAffichage, sauvegarde, initialisation;

procedure jeu(var frog: Frog; plateau: Plateau; tab_image: tab_picture; tab_scores : tableau_score; cst: constantes; var data_infini: rec_infini);

implementation

function collision(frog: Frog; plateau: Plateau; largeur_jeu, hauteur_ecran, hauteur_biome : integer): Boolean;
{ Vérifie si le joueur est en collision avec un obstacle ou si le joueur est dans l'eau}
var i, ligne, xo1, xo2, xf1, xf2: Integer;
    bool, plouf: Boolean;
begin
  bool  := False;
  ligne := NB_LIGNES - (frog.y - (hauteur_ecran- NB_LIGNES*hauteur_biome)) div hauteur_biome; // numéro de la ligne où se situe le joueur
  if plateau.lignes[ligne].eau then
    plouf := True
  else
    plouf := False;
  i := 1;
  while (i <= plateau.lignes[ligne].taille) and not bool do
  begin
    xo1 := plateau.lignes[ligne].objets[i].x;
    xo2 := plateau.lignes[ligne].objets[i].x + plateau.lignes[ligne].objets[i].l;
    xf1 := frog.x;
    xf2 := frog.x + frog.l;
    // Si le joueur sort du cadre :
    if (xf1 < 0) or (xf2 > largeur_jeu) then
      bool := True
    // Si le joueur est sur la route et qu'il touche un objet :
    else if not plateau.lignes[ligne].eau and (((xf1 > xo1) and (xf1 < xo2)) or ((xf2 > xo1) and (xf1 < xo2))) then
      bool := True
    // Si le joueur est sur une ligne d'eau mais sur un objet :
    else if plateau.lignes[ligne].eau and ((xf1 + frog.l div 2 > xo1) and (xf2 - frog.l div 2 < xo2)) then
      plouf := False;
    i := i + 1;
  end;
  collision := bool or plouf;
end;

procedure actualiserScore(var score: Score; evenement: Evt_score);
{ Met à jour le score en fonction de ce qu'a fait le joueur }
begin
  case evenement of
    avance : score.score := score.score + 10;
    bonus  : score.score := score.score + 50;
    maison : score.score := score.score + 100;
  end;
end;

function victoire(var frog: Frog; hauteur_ecran, hauteur_biome : integer): Boolean;
{ Vérifie si le joueur est arrivé en haut de la carte sur une case libre }
var bool: Boolean;
begin
  bool := False;
  if (frog.y - (hauteur_ecran- NB_LIGNES*hauteur_biome)) div hauteur_biome < 1 then
  begin
    bool := True;
    actualiserScore(frog.score, maison);
  end;
  victoire := bool;
end;

procedure retirerVie(var frog: Frog);
begin
  frog.vies := frog.vies - 1;
end;

procedure reinitPosition(var frog: Frog; tab_images : tab_picture; cst : constantes);
begin
  frog.x := tab_images[0].l div 2;
  frog.y := tab_images[0].h - tab_images[cst.rang.biome + 1].h;
end;

procedure deplacementJoueur(var frog: Frog; direction: Byte; x_max_jeu, hauteur_ecran, hauteur_biome: Integer);
{ Permet de déplacer le joueur dans les 4 directions N-S-O-E: 1-2-3-4}
var ligne: Integer;
begin
  if (direction = 1) and (frog.y - hauteur_biome >= 0) then // en haut
  begin
    ligne  := frog.y div hauteur_biome; // numéro de la ligne où se situe le joueur
    frog.y := frog.y - hauteur_biome;
    // actualisation du score
    if NB_LIGNES - ligne > frog.hauteur_atteinte then
    begin
      frog.hauteur_atteinte := frog.hauteur_atteinte + 1;
      actualiserScore(frog.score, avance);
    end;
  end
  else if (direction = 2) and (frog.y + hauteur_biome < hauteur_ecran) then // en bas
    frog.y := frog.y + hauteur_biome
  else if (direction = 3) and (frog.x + hauteur_biome < x_max_jeu) then // à droite
    frog.x := frog.x + hauteur_biome
  else if (direction = 4) and (frog.x - hauteur_biome >= 0) then       // à gauche
    frog.x := frog.x - hauteur_biome;
end;

procedure deplacementJoueurSurEau(var x: Integer; y: Integer; plateau: Plateau; delta_t: Real; hauteur_ecran, hauteur_biome : integer);
{ Permet de déplacer le joueur automatiquement lorsqu'il est sur un objet qui se déplace sur l'eau }
var ligne, sens: Integer;
begin
  ligne := NB_LIGNES - (y - (hauteur_ecran - NB_LIGNES*hauteur_biome)) div hauteur_biome; // numéro de la ligne où se situe le joueur
  if plateau.lignes[ligne].eau then
  begin
    if plateau.lignes[ligne].direction then
      sens := 1
    else
      sens := -1;
    x := x + round(sens * plateau.lignes[ligne].vitesse * delta_t);
  end;
end;

procedure jeu(var frog: Frog; plateau: Plateau; tab_image: tab_picture; tab_scores : tableau_score; cst: constantes; var data_infini: rec_infini);
var loopstop: Boolean = False;
    pause: Boolean = False;
    event: pSDL_Event;
    temps_pause: Longword = 0;
    temps_limite: Longword = 0;
    loaded_font:pointer;
    colour_font:PSDL_COLOR;
    t0: Longword;
    delta_t: Real;
    {gestion de la musique}
    music : pMix_Music = NIL; //pointe vers le fichier de musique
begin
  initAffichageScore(loaded_font, colour_font);
  temps_limite := SDL_GetTicks();
  delta_t := 0;

  SDL_Init(SDL_INIT_AUDIO);
  if mix_openaudio(FREQUENCY,FORMAT,CHANNELS,CHUNKSIZE) <> 0 then
	halt;
  music := mix_loadmus('images/frogger_music.mp3');
  mix_volumeMusic(plateau.vol); //de 0 à 128;
  mix_playmusic(music, -1);

  if plateau.coupe then
	mix_pausemusic;

  new(event);
  while not loopstop do
  begin
    if not pause then
    begin
      t0 := SDL_GetTicks();
      // gestion des évènements :
      if (SDL_POLLEVENT(event) = 1) then
      begin
        case event^.type_ of
        SDL_QUITEV  : loopstop := true; // croix de la fenêtre
        SDL_KEYDOWN :
    			begin //necessité de mettre des if else if, case ne pouvant contenir que des constantes
    			if event^.key.keysym.sym = plateau.up then
    				deplacementJoueur(frog, 1, cst.x_max_jeu, tab_image[0].h, tab_image[cst.rang.biome+1].h)
    			else if event^.key.keysym.sym = plateau.down then
    				deplacementJoueur(frog, 2, cst.x_max_jeu, tab_image[0].h, tab_image[cst.rang.biome+1].h)
    			else if event^.key.keysym.sym = plateau.right then
    				deplacementJoueur(frog, 3, cst.x_max_jeu, tab_image[0].h, tab_image[cst.rang.biome+1].h)
    			else if event^.key.keysym.sym = plateau.left then
    				deplacementJoueur(frog, 4, cst.x_max_jeu, tab_image[0].h, tab_image[cst.rang.biome+1].h)
          else if event^.key.keysym.sym = 27 then // touche echap pour quitter la partie
    				loopstop := true;
    			end;
        end;
      end;
      // gestion du jeu :
      deplacementJoueurSurEau(frog.x, frog.y, plateau, delta_t, tab_image[0].h, tab_image[cst.rang.biome+1].h);
      deplacementObjets(plateau, delta_t, cst.x_max_jeu);
      if collision(frog, plateau, cst.x_max_jeu, tab_image[0].h, tab_image[cst.rang.biome+1].h) then
      begin
        retirerVie(frog);
        // on met le jeu en pause pendant 1s :
        pause := True;
        temps_pause := SDL_GetTicks();
        writeln('Collision');
      end;
      if victoire(frog, tab_image[0].h, tab_image[cst.rang.biome+1].h) then
      begin
        pause := True;
        frog.hauteur_atteinte := 0;
        temps_pause := SDL_GetTicks();
        writeln('Victoire !');
      end;
      if (SDL_GetTicks() - temps_limite > cst.temps_max_partie) and (cst.temps_max_partie > 0) then // si le temps max impartis est dépassé
      begin
        pause := True;
        writeln('temps_pause depassé');
        temps_pause := SDL_GetTicks();
        retirerVie(frog);
      end;
      if frog.vies = 0 then
        loopstop := true;

      // affichage:
      affichageSDL(plateau, frog, tab_image, loaded_font, colour_font, cst, SDL_GetTicks() - temps_limite, tab_scores);

      if plateau.mode = infini then
        if frog.y - (tab_image[0].H - NB_LIGNES*tab_image[cst.rang.biome+1].h) < (cst.y_max_jeu div NB_LIGNES) * 5 then
        begin
          decalage_plateau(plateau, cst, frog);
          actualiserScore(frog.score, avance);
          plateau.lignes[NB_LIGNES] := generation_ligne(data_infini, cst, tab_image, NB_LIGNES);
        end;

    end;

    // gestion du temps
    if pause and (SDL_GetTicks() - temps_pause > 1000) then // pause de 1s avant de relancer la partie
    begin
      pause := False;
      temps_limite := SDL_GetTicks();
      frog.hauteur_atteinte := 0;
      reinitPosition(frog, tab_image, cst);
    end;

    delta_t := (SDL_GetTicks - t0) / 1000;
  end;

  writeln('Score final: ', frog.score.score);
  enregistrerScore('donnees/scores', frog.score);

  mix_haltmusic;
  mix_freeMusic(music);
  mix_closeaudio;
end;

end.

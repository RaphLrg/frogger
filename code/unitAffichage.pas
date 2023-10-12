unit unitAffichage;
{$H+}

interface

uses typesFrogger, sdl, SDL_image, SDL_TTF, sysutils;

procedure affichageSDL(p : Plateau; joueur : frog; images : tab_picture; var loaded_font : pointer; var colour_font : PSDL_COLOR; cst: constantes; temps: Word; tab_scores: tableau_score);
procedure initAffichageScore(var loaded_font : pointer; var colour_font : PSDL_COLOR);

implementation

procedure affichageObjets(p : Plateau; joueur : frog; images : tab_picture; cst: constantes);
var i,j:Integer;
 		img,screen:PSDL_SURFACE;
begin
	screen := images[0].img;
	for i := 1 to NB_LIGNES do
	begin
		for j := 1 to p.lignes[i].taille do
		begin
			img := images[p.lignes[i].objets[j].indice_image].img;
			BlitSurface(p.lignes[i].objets[j].x,p.lignes[i].objets[j].y,p.lignes[i].objets[j].x+p.lignes[i].objets[j].l,p.lignes[i].objets[j].y+p.lignes[i].objets[j].h,img,screen);
		end;
	end;
end;

procedure affichageBackground(p : Plateau; images : tab_picture; cst: constantes);
var i: Integer;
 		image: picture;
 		screen: PSDL_SURFACE;
begin
	screen := images[0].img;
	for i := 1 to NB_LIGNES do
	begin
		image := images[p.lignes[i].indiceBiome];
		BlitSurface(0,images[0].h-image.h*i,image.l,image.h,image.img,screen);
	end;
end;

procedure affichageBordDroit(screen: picture; cst: constantes);
begin
	fillRect(cst.x_max_jeu, 0, screen.l, screen.h, 0, 0, 0, screen.img); // fond noir sur la marge à droite
end;

procedure initAffichageScore(var loaded_font : pointer; var colour_font : PSDL_COLOR);
begin
	if TTF_INIT=-1 then
		halt;
	loaded_font:=TTF_OPENFONT('polices/game_over.ttf',55);
	new(colour_font);
	colour_font^.r := 255;
	colour_font^.g := 242;
	colour_font^.b := 51;
end;

procedure affichageScore(joueur: frog; screen: pSDL_SURFACE; var loaded_font: pointer; var colour_font: PSDL_COLOR);
var fontface: PSDL_SURFACE;
 		text: String;
begin
	text := joueur.score.nom+':'+IntToStr(joueur.score.score);
	fontface := TTF_RENDERTEXT_BLENDED(loaded_font,PChar(text),colour_font^);
	BlitSurface(1900-fontface^.w,20,fontface^.w,fontface^.h,fontface,screen);
end;

procedure affichageMeilleursScores(tab_scores: tableau_score; screen: pSDL_SURFACE; var loaded_font: pointer; var colour_font: PSDL_COLOR; cst: constantes);
var fontface: PSDL_SURFACE;
 		text: String;
    i: Integer;
begin
  for i := 1 to MAX_SCORE do
  begin
    text := IntToStr(i) + ' : ' + tab_scores[2,i];
    fontface := TTF_RENDERTEXT_BLENDED(loaded_font, PChar(text), colour_font^);
    BlitSurface(cst.x_max_jeu+100-fontface^.w, 250 + fontface^.h*i, fontface^.w, fontface^.h, fontface,screen);
  end;
end;

procedure affichageJoueur(frog: Frog; images: tab_picture; cst: constantes);
begin
	BlitSurface(frog.x, frog.y, frog.x + frog.l, frog.y + frog.h, images[cst.rang.frogger + frog.indice_image].img, images[0].img);
end;

procedure affichageTempsRestant(temps: Word; screen: pSDL_Surface; x_max_jeu: Integer);
var pourcentage: Integer;
begin
  pourcentage := round(temps/LIMITE_TEMPS_MANCHE * x_max_jeu);
  fillRect(0, 0, pourcentage, 10, 0, 255, 0, screen);
end;

procedure affichageVie(images: tab_picture; frog: Frog; cst: constantes);
var i: Integer;
begin
  for i := 1 to frog.vies do
    BlitSurface(cst.x_max_jeu + (i-1)*(frog.l+5), 100, cst.x_max_jeu + i*(frog.l), 100, images[cst.rang.frogger + frog.indice_image].img, images[0].img);
end;

procedure affichageSDL( p : Plateau; joueur : frog; images : tab_picture; var loaded_font : pointer; var colour_font : PSDL_COLOR; cst: constantes; temps: Word; tab_scores: tableau_score);
begin
	affichageBackground(p, images, cst);
	affichageObjets(p, joueur, images, cst);
	affichageBordDroit(images[0], cst);
  if cst.temps_max_partie > 0 then
    affichageTempsRestant(temps, images[0].img, cst.x_max_jeu);
	affichageJoueur(joueur, images, cst);
	affichageScore(joueur, images[0].img, loaded_font, colour_font);
  affichageMeilleursScores(tab_scores, images[0].img, loaded_font, colour_font, cst);
  affichageVie(images, joueur, cst);
	SDL_Flip(images[0].img);
end;

end.

program frogger;

uses SDL, SDL_Image, logique, typesFrogger, menu_unit, unitDeplacementObjets, initialisation;

var p : Plateau;
  	joueur : Frog;
    cst : constantes;
    tab_images : tab_picture;
    tab_scores : tableau_score;
    data_infini : rec_infini;

begin
  randomize;
  // MENU
  repeat
	menu(p);
	// INITIALISATION
	initialisation_globale(p, cst, tab_images, data_infini);
	if p.partie then
		begin
		// joueur := init_frog(p.theme, cst, tab_images);
		tab_scores := extraction_tableau_score('donnees/scores');
		initialisation_partie(joueur, p, cst,  tab_scores, tab_images);
		// JEU

		jeu(joueur, p, tab_images, tab_scores, cst, data_infini);
		end;
  until not(p.partie);
  // QUITTER
  quitter_sdl(tab_images);
end.

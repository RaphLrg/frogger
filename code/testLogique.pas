program test;
uses SDL, SDL_image, logique, typesFrogger;

procedure initFrog(var frog: Frog);
begin
  frog.x := LARGEUR div 2;
  frog.y := HAUTEUR - HAUTEUR_LIGNE;
  frog.l := HAUTEUR_LIGNE;
  frog.h := HAUTEUR_LIGNE;
  frog.hauteur_atteinte := 0;
  frog.score.score := 0;
end;

procedure initPlateau(var p: Plateau);
var obj: Objet;
    i: Integer;
begin
  obj.x := 0;
  obj.l := LARGEUR div 2;
  obj.h := HAUTEUR_LIGNE;
  for i := 1 to NB_LIGNES do
    p.lignes[i].taille := 0;
  p.lignes[5].taille := 1;
  p.lignes[5].objets[1] := obj;
  p.lignes[10].taille := 1;
  obj.x := 400;
  obj.l := LARGEUR div 3;
  obj.h := HAUTEUR_LIGNE;
  p.lignes[10].objets[1] := obj;
end;

var f: Frog;
    p: Plateau;
    screen, image: pSDL_SURFACE;

begin
  initFrog(f);
  initPlateau(p);
  SDL_INIT(SDL_INIT_VIDEO);
  screen := SDL_SETVIDEOMODE(LARGEUR, HAUTEUR, 8, SDL_HWSURFACE);
  image  := IMG_Load('images/frog_degueu.png');
  jeu(f, p, screen, image);
  SDL_FREESURFACE(screen);
  SDL_QUIT;
end.

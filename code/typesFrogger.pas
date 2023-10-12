unit typesFrogger;

interface

uses sdl;

{ ~~~~~~ LES CONSTANTES ~~~~~~ }
const
  LARGEUR = 1920; // largeur de l'écran
  HAUTEUR = 1080; // hauteur de l'écran
  NB_LIGNES = 15;
  HAUTEUR_LIGNE = HAUTEUR div NB_LIGNES;
  MAX_IMAGES = 100;
  MAX_SCORE = 10;
  MAX_OBJET = 10;
  MAX_ETAGE = 12;
  LIMITE_TEMPS_MANCHE = 30000; // 30s pour arriver en haut
  MAX_ENSEMBLE_INFINI = 20;

{ ~~~~~~~~ LES TYPES ~~~~~~~~ }
type categorie_image = (voiture, rondin, biome, cases, frogger, autre);

type orientation = (haut, bas, droite, gauche);

type Objet = record // permet de définir tout les objets qui bougent dans le jeu
  x, y, l, h : Integer;
  categorie : categorie_image;
  sens : orientation;
  indice_image : integer;
end;

type Evt_score = (avance, maison, bonus); // le score augmente differemment en fonction de ce que fait le joueur

type Score = record
  nom: String;
  score: Integer;
end;

type direction = record             //Type regroupant les differentes images d'un même objet
  i_b,i_h,i_d,i_g : integer;      //Indice dans le tableau des images selon l'orientation (bas, haut, droite, gauche)
  sens : orientation;
end;

type Frog = record
  x, y, l, h: Integer;
  hauteur_atteinte: Integer; // enregistre la hauteur max atteinte pour augmenter le score que lorsque le joueur augmente cette hauteur
  score: Score;
  dir: direction;
  indice_image: Integer;
  vies: Integer;
  // skin, etc...
end;

type Theme = (standard, espace, medieval, onepiece);      //Etc..

type Mode = (facile, normal, difficile, infini); //infini a rajouter quand fonctionnel

type Ligne = record
  vitesse, taille, serie, indiceBiome : integer;
  objets: array[1..MAX_OBJET] of Objet;
  direction: Boolean; // pas nécessaire
  eau : boolean;
end;

type tableau_aleatoire = array[1..3*MAX_ENSEMBLE_INFINI] of ligne;

type ensemble_infini = set of 1..MAX_ENSEMBLE_INFINI;

type rec_infini = record
  tab_alea : tableau_aleatoire;
  route, riviere, transition : ensemble_infini;
  nb_couches, nb_prec : integer;
  type_etage : string;
end;

type Plateau = record
  lignes : array [1..NB_LIGNES] of Ligne; // 10 objets max par lignes
  mode: Mode;
  theme : Theme;
  vol : Integer; //volume du son
  coupe, partie : Boolean; //volume présent ou non
  up,down,right,left : Integer; //amené a changer, a voir ...
end;

type picture = record               //Type d'une image
  path : string;                          //Chemin d'acces memoire
  l, h : integer;                         //Dimensions
  img : PSDL_SURFACE;                     //image
end;

type categorie_image_record = record       //Constantes de catégories d'images
  voiture, rondin, biome, cases, frogger, autre : integer;
end;

type constantes = record            //Constantes de quantité et de tri des catégories d'images
  rang : categorie_image_record;                 //indice de la dernière image de la catégorie précédente (rang.voiture + 1 = indice de la 1ère voiture)
  nb : categorie_image_record;                   //nombre d'image de chaque catégories
  nb_total : integer;
  x_max_jeu , x_min_jeu, y_max_jeu, y_min_jeu : integer;
  temps_max_partie : integer;
end;

type tab_picture = array[0..MAX_IMAGES] of picture;

type tableau_score = array[1..2, 1..MAX_SCORE] of string;

{ ~~~~~~~~ LES PROCEDURES ~~~~~~~~ }

procedure fillRect(x,y,w,h,r,g,b : Integer; p_screen : PSDL_surface);
procedure blitSurface(x,y,w,h:Integer; surface, p_screen : PSDL_Surface);

implementation

procedure fillRect(x,y,w,h,r,g,b : Integer; p_screen : PSDL_surface );
{simplifie SDL_fillRect}
var destination_rect : TSDL_RECT;
begin
	destination_rect.x := x;
	destination_rect.y := y;
	destination_rect.w := w;
	destination_rect.h := h;
	SDL_FillRect(p_screen,@destination_rect,SDL_mapRGB(p_screen^.format,r,g,b));
end;


procedure blitSurface(x,y,w,h:Integer; surface, p_screen : PSDL_Surface);
{simplifie SDL_blitSurface}
var destination_rect : TSDL_RECT;
begin
	destination_rect.x := x;
	destination_rect.y := y;
	destination_rect.w := w;
	destination_rect.h := h;
	SDL_BlitSurface(surface,NIL,p_screen,@destination_rect);
end;

end.

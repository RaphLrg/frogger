unit menu_unit;
{$H+}

interface

uses sdl, sdl_image, sdl_mixer, SDL_TTF, sysutils, crt, typesFrogger, math;

CONST
	FPS = 60;
	{taille de la fenetre de menu}
	MENU_WIDTH = 1000; //1000
	MENU_HEIGHT = 625; //625
	{taille et emplacement du texte "Frogger"}
	MENU_TEXT_WIDTH = 500;
	MENU_TEXT_HEIGHT = 100;
	MENU_TEXT_X = (MENU_WIDTH - MENU_TEXT_WIDTH) div 2 ;
	MENU_TEXT_Y = 100;
	{taille des boutons}
	MENU_BUTTON_WIDTH = 300;
	MENU_BUTTON_HEIGHT = 70;
	MENU_ARROW_WIDTH = 70;
	MENU_ARROW_HEIGHT = MENU_ARROW_WIDTH;
	{abcisse des boutons (texte), la meme pour tous}
	MENU_BUTTON_X = (MENU_WIDTH - MENU_BUTTON_WIDTH) div 2;
	{ecart entre les textes/boutons/fleches}
	SPACE_TEXT_HEIGHT = 40;
	SPACE_ARROW_WIDTH = 10;
	{ordonnee des boutons/texte}
	MENU_PLAY_Y = MENU_TEXT_Y + MENU_TEXT_HEIGHT + SPACE_TEXT_HEIGHT;
	MENU_MODE_Y = MENU_PLAY_Y + MENU_BUTTON_HEIGHT + SPACE_TEXT_HEIGHT;

	MENU_DEROULANT_HEIGHT = 30;
	MENU_DEROULANT_Y = MENU_HEIGHT - MENU_DEROULANT_HEIGHT;
	MENU_DEROULANT_WIDTH = 1280;
	MENU_DEROULANT_VEL = 1.1;
	{fleche de retour}
	MENU_BACK_X = 10;
	MENU_BACK_Y = 10;	
	{changement de controles}
	MENU_CHANGE_WIDTH = 700;
	MENU_CHANGE_HEIGHT = 150;
	{gestion de la musique}
	FREQUENCY : Integer = 22050;
	FORMAT : Word = Audio_s16;
	CHANNELS : Integer = 2;
	CHUNKSIZE : Integer = 4096; 

type 
	TSpriteSheetMenu = record
	menutext, menufond, menufond2, menufond3, menufond4, play, normal, facile,
	 difficile, infini, triangled, triangleg, deroulant, textoptions, options, blank : PSDL_Surface;
	end;
	PSpriteSheetMenu=^TSpriteSheetMenu;
	{menu déroulant}
	deroulantTab = array [0..1] of Integer;
	{gestion des différents écrans disponibles}
	ecran = (main, options, controles, changement);

	Button = Record
		x,y,w,h : Integer;
		nom : String; 
		texture : PSDL_Surface;
	end;
	
	Buttons = array of Button; 
	TButtons = array[ecran] of Buttons;
	

procedure menu(var plateau : Plateau);

implementation

operator = (b1, b2 : Button) b : boolean;
{overload du égal pour comparer deux boutons}
begin
	b := False;
	if (b1.x = b2.x) and (b1.y = b2.y) and (b1.w = b2.w) and (b1.h = b2.h) and (b1.nom = b2.nom) and (b1.texture = b2.texture) then
		b := True;
end;

function newButton(x,y,w,h : Integer; s : String; tex : PSDL_Surface) : Button;
{crée un nouveau button}
var b : Button;
begin
	b.x := x;
	b.y := y;
	b.w := w;
	b.h := h;
	b.nom := s;
	b.texture := tex;
	newButton := b;
end;

procedure addButton(bu : Button;var t : Buttons);
begin
	setLength(t, length(t)+1);
	t[length(t)-1] := bu;
end;
	
function prevButton(t : Buttons) : Button;
begin
	prevButton := t[length(t)-1];
end;

function TextureMode( ps : PSpriteSheetMenu; p : Plateau) : PSDL_Surface;
begin
	case p.mode of
		facile : TextureMode := ps^.facile;
		normal : TextureMode := ps^.normal;
		difficile : TextureMode := ps^.difficile;
		infini : TextureMode := ps^.infini;
	end;
end;


function newSpriteSheetMenu():PSpriteSheetMenu;
{On charge les textures en mémoire}
begin
    new(newSpriteSheetMenu);
    newSpriteSheetMenu^.menutext:=IMG_Load('images/frogger_menu_text.png');
    newSpriteSheetMenu^.menufond:=IMG_Load('images/menufond.png');
    newSpriteSheetMenu^.menufond2:=IMG_Load('images/menufond2.png');
    newSpriteSheetMenu^.menufond3:=IMG_Load('images/menufond3.png');
    newSpriteSheetMenu^.menufond4:=IMG_Load('images/menufond4.png');
    newSpriteSheetMenu^.play:=IMG_Load('images/frogger_menu_play.png');
    newSpriteSheetMenu^.normal:=IMG_Load('images/frogger_menu_normal.png');
    newSpriteSheetMenu^.facile:=IMG_Load('images/menu_facile.png');
    newSpriteSheetMenu^.difficile:=IMG_Load('images/menu_difficile.png');
    newSpriteSheetMenu^.infini:=IMG_Load('images/frogger_menu_infini.png');
    newSpriteSheetMenu^.triangled:=IMG_Load('images/frogger_menu_triangle_d.png');
    newSpriteSheetMenu^.triangleg:=IMG_Load('images/frogger_menu_triangle_g.png');
    newSpriteSheetMenu^.deroulant:=IMG_Load('images/menu_deroulant_noms.png');
    newSpriteSheetMenu^.textoptions:=IMG_Load('images/menu_options_text.png');
    newSpriteSheetMenu^.options:=IMG_Load('images/menu_options.png');
    newSpriteSheetMenu^.blank:=IMG_Load('images/blank.png');
end;

procedure disposeSpriteSheetMenu(p_sprite_sheet: PSpriteSheetMenu);//
{On décharge les textures de la mémoire}
begin
    SDL_FreeSurface(p_sprite_sheet^.menutext);
    SDL_FreeSurface(p_sprite_sheet^.menufond);
    SDL_FreeSurface(p_sprite_sheet^.menufond2);
    SDL_FreeSurface(p_sprite_sheet^.menufond3);
    SDL_FreeSurface(p_sprite_sheet^.menufond4);
    SDL_FreeSurface(p_sprite_sheet^.play);
    SDL_FreeSurface(p_sprite_sheet^.infini);
    SDL_FreeSurface(p_sprite_sheet^.normal);
    SDL_FreeSurface(p_sprite_sheet^.facile);
    SDL_FreeSurface(p_sprite_sheet^.difficile);
    SDL_FreeSurface(p_sprite_sheet^.triangled);
    SDL_FreeSurface(p_sprite_sheet^.triangleg);
    SDL_FreeSurface(p_sprite_sheet^.deroulant);
    SDL_FreeSurface(p_sprite_sheet^.textoptions);
    SDL_FreeSurface(p_sprite_sheet^.options);
    SDL_FreeSurface(p_sprite_sheet^.blank);
    dispose(p_sprite_sheet);
end;

procedure affichageMenu(var t : TButtons;current : ecran; var p_screen:PSDL_Surface; p_sprite_sheet : PSpriteSheetMenu; var colour_font, colour_font2:pSDL_COLOR;var loaded_font: pointer; plateau : Plateau;var deroulant_x : deroulantTab);
var i : Integer;
begin
	{fond}
	case plateau.mode of
		facile : BlitSurface(0, 0, MENU_WIDTH, MENU_HEIGHT, p_sprite_sheet^.menufond, p_screen);
		normal : BlitSurface(0, 0, MENU_WIDTH, MENU_HEIGHT, p_sprite_sheet^.menufond4, p_screen);
		difficile : BlitSurface(0, 0, MENU_WIDTH, MENU_HEIGHT, p_sprite_sheet^.menufond2, p_screen);
		infini : BlitSurface(0, 0, MENU_WIDTH, MENU_HEIGHT, p_sprite_sheet^.menufond3, p_screen);
		else FillRect(0, 0, MENU_WIDTH, MENU_HEIGHT, 220, 20, 60, p_screen);
	end;
	for i := 0 to length(t[current])-1 do
		begin
		BlitSurface(t[current][i].x, t[current][i].y, t[current][i].w, t[current][i].h, t[current][i].texture, p_screen);
		end;
	{deroulant avec les noms}
	for i := 0 to 1 do
		begin
		deroulant_x[i] := round(deroulant_x[i] - MENU_DEROULANT_VEL);
		if deroulant_x[i]  < -MENU_DEROULANT_WIDTH -1 then
			deroulant_x[i] := MENU_DEROULANT_WIDTH;
		BlitSurface(deroulant_x[i], MENU_DEROULANT_Y, MENU_DEROULANT_WIDTH, MENU_DEROULANT_HEIGHT, p_sprite_sheet^.deroulant, p_screen);
		end;
	SDL_flip(p_screen);
end;

function buttonPushed(x,y : Integer;t : TButtons; current : ecran): String;
{renvoie le nom du bouton pressé si il y en a un, sinon renvoie une chaine de caractère vide}
var i : Integer ;
	temp : String;
begin
	for i := 0 to length(t[current])-1 do
		begin
		if InRange(x, t[current][i].x, t[current][i].x+t[current][i].w) and InRange(y, t[current][i].y, t[current][i].y + t[current][i].h) then
			begin
			temp := t[current][i].nom;
			break;
			end;
		if i = length(t[current])-1 then temp := '';
		end;
		buttonPushed := temp;
end;


procedure choixMode(var plateau : Plateau; fleche_pressee : String);
begin
	case fleche_pressee of
		'arrowright' :	if plateau.mode = high(mode) then //droite
				plateau.mode := low(mode)
			else
				plateau.mode := succ(plateau.mode);
		'arrowleft' : if plateau.mode = low(mode) then
				plateau.mode := high(mode)
			else
				plateau.mode := pred(plateau.mode);
	end;
end;

procedure choixTheme(var Plateau : Plateau; fleche_pressee : String; var s : PChar);
var temp : String;
begin
	case fleche_pressee of
		'arrowrightt' :	if plateau.theme = high(theme) then //droite
				plateau.theme := low(theme)
			else
				plateau.theme := succ(plateau.theme);
		'arrowleftt' : if plateau.theme = low(theme) then
				plateau.theme := high(theme)
			else
				plateau.theme := pred(plateau.theme);
		end;
	Str(Plateau.theme, temp);
	s := PChar(temp);
end;

procedure choixVolume(var p : Plateau; fleche_pressee : String; var s : PChar);
begin
	case fleche_pressee of
		'arrowrightv' : if p.vol < 100 then
			p.vol += 10;
		'arrowleftv' : if p.vol > 9 then
			p.vol -= 10;
		end;
	s := PChar('volume : ' + IntToStr(p.vol));
end;

function etatVolume(p : Plateau) : PChar;
begin
	etatVolume := PChar('volume : ' + IntToStr(p.vol));
end;

function etatSon(p : Plateau) : Pchar;
var s : PChar;
begin
	if p.coupe then
		s := 'son : off'
	else
		s := 'son : on';
	etatSon := s;
end;

function etatControle(p : Plateau; mouv : string) : PChar;
var s : String;
begin
	s :=  mouv + ' : ';
	case mouv of
		'up' : s += SDL_GetKeyName(p.up);
		'down' : s += SDL_GetKeyName(p.down);
		'left' : s += SDL_GetKeyName(p.left);
		'right' : s += SDL_GetKeyName(p.right);
	end;
	etatControle := PChar(s);
end;

function CreateTextureText(ps : PSpriteSheetMenu; s : PChar;var loaded_font : pointer; var couleur : PSDL_COLOR) : PSDL_SURFACE;
var surface, temp : PSDL_Surface;
begin
	//surface := ps^.blank; //lie les deux surfaces ...
	surface := SDL_CreateRGBSurface(0,MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT,32,0,0,0,0);
	BlitSurface(0,0,MENU_BUTTON_WIDTH,MENU_BUTTON_HEIGHT,ps^.blank, surface); 
	temp := TTF_RENDERTEXT_BLENDED(loaded_font, s, couleur^);
	//on met lécriture sur le bouton vide
	BlitSurface((surface^.w - temp^.w) div 2, (surface^.h - temp^.h) div 2, temp^.w, temp^.h, temp, surface); 
	CreateTextureText := surface;
end;

function createTextureChangementControle(ps : PSpriteSheetMenu; var loaded_font : pointer; var couleur : PSDL_Color) : PSDL_Surface;
var surface, temp : PSDL_Surface;
begin
	surface := SDL_CreateRGBSurface(0, MENU_CHANGE_WIDTH, MENU_CHANGE_HEIGHT,32,0,0,0,0);
	FillRect(0,0, MENU_CHANGE_WIDTH, MENU_CHANGE_HEIGHT,255,255,255,surface);
	{contour en noir}
	FillRect(0,0, MENU_CHANGE_WIDTH, 4,0,0,0,surface); //haut
	FillRect(0,0, 4, MENU_CHANGE_HEIGHT,0,0,0,surface); //gauche
	FillRect(MENU_CHANGE_WIDTH-4,0, 4, MENU_CHANGE_HEIGHT,0,0,0,surface); //droit
	FillRect(0,MENU_CHANGE_HEIGHT-4, MENU_CHANGE_WIDTH, 4,0,0,0,surface); //bas
	temp := TTF_RENDERTEXT_BLENDED(loaded_font, 'appuyez sur une touche ...', couleur^);
	BlitSurface((surface^.w - temp^.w) div 2, (surface^.h - temp^.h) div 2, temp^.w, temp^.h, temp, surface);
	CreateTextureChangementControle := surface;
end; 	

function setButtonsArray(ps : PSpriteSheetMenu; p : Plateau; var couleur, couleur2 : PSDL_COLOR;var loaded_font: pointer) : TButtons;
var t : TButtons;
	x,y : Integer;
	current : ecran;
	temp : String;
begin
	{main screen}
	current := main;
	x := (MENU_WIDTH - MENU_TEXT_WIDTH) div 2;
	y := 100;
	addButton(newButton(x,y,MENU_TEXT_WIDTH,MENU_TEXT_HEIGHT,'_menutext',ps^.menutext),t[current]);
	x := (MENU_WIDTH - MENU_BUTTON_WIDTH) div 2;
	y := prevButton(t[current]).y + prevButton(t[current]).h + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH,MENU_BUTTON_HEIGHT,'play',ps^.play),t[current]);
	x := prevButton(t[current]).x;
	y := prevButton(t[current]).y + prevButton(t[current]).h + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH,MENU_BUTTON_HEIGHT,'_mode',TextureMode(ps,p)),t[current]);
	x := prevButton(t[current]).x - SPACE_ARROW_WIDTH - MENU_ARROW_WIDTH;
	y := prevButton(t[current]).y ;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'arrowleft',ps^.triangleg),t[current]);
	x := prevButton(t[current]).x + 2*SPACE_ARROW_WIDTH + MENU_BUTTON_WIDTH + t[current][3].w;
	y := prevButton(t[current]).y ;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'arrowright',ps^.triangled),t[current]);
	x := (MENU_WIDTH - MENU_BUTTON_WIDTH) div 2;
	y := prevButton(t[current]).y + prevButton(t[current]).h + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT,'options', ps^.options),t[current]);
	{options screen}
	current := options;
	x := MENU_BACK_X;
	y := MENU_BACK_Y;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'retour',ps^.triangleg),t[current]);
	x := (MENU_WIDTH - MENU_TEXT_WIDTH) div 2;
	y := 25;
	addButton(newButton(x,y,MENU_TEXT_WIDTH,MENU_TEXT_HEIGHT,'_optionstext',ps^.textoptions),t[current]);
	x := (MENU_WIDTH - MENU_BUTTON_WIDTH) div 2;
	y := prevButton(t[current]).y + MENU_TEXT_HEIGHT + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT,'coupeson', CreateTextureText(ps,etatSon(p),loaded_font,couleur)),t[current]);
	x := prevButton(t[current]).x;
	y := prevButton(t[current]).y + MENU_BUTTON_HEIGHT + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT,'_volume', CreateTextureText(ps,etatVolume(p),loaded_font,couleur) ), t[current]);
	x := prevButton(t[current]).x - SPACE_ARROW_WIDTH - MENU_ARROW_WIDTH;
	y := prevButton(t[current]).y ;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'arrowleftv',ps^.triangleg),t[current]);
	x := prevButton(t[current]).x + 2*SPACE_ARROW_WIDTH + MENU_BUTTON_WIDTH + MENU_ARROW_WIDTH;
	y := prevButton(t[current]).y ;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'arrowrightv',ps^.triangled),t[current]);
	x := (MENU_WIDTH - MENU_BUTTON_WIDTH) div 2;
	y := prevButton(t[current]).y + MENU_BUTTON_HEIGHT + SPACE_TEXT_HEIGHT;
	Str(p.theme, temp);
	addButton(newButton(x,y,MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT,'_theme', CreateTextureText(ps,Pchar(temp),loaded_font,couleur) ), t[current]);
	x := prevButton(t[current]).x - SPACE_ARROW_WIDTH - MENU_ARROW_WIDTH;
	y := prevButton(t[current]).y ;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'arrowleftt',ps^.triangleg),t[current]);
	x := prevButton(t[current]).x + 2*SPACE_ARROW_WIDTH + MENU_BUTTON_WIDTH + MENU_ARROW_WIDTH;
	y := prevButton(t[current]).y ;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'arrowrightt',ps^.triangled),t[current]);
	x := (MENU_WIDTH - MENU_BUTTON_WIDTH) div 2;
	y := prevButton(t[current]).y + MENU_BUTTON_HEIGHT + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT,'controles', CreateTextureText(ps,'controles',loaded_font,couleur)), t[current]);
	{controles screen}
	current := controles;
	x := MENU_BACK_X;
	y := MENU_BACK_Y;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'retour',ps^.triangleg),t[current]);
	x := 100;
	y := 50;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH,MENU_BUTTON_HEIGHT,'up',CreateTextureText(ps,etatControle(p,'up'),loaded_font,couleur)),t[current]);
	x := prevButton(t[current]).x;
	y := prevButton(t[current]).y + MENU_BUTTON_HEIGHT + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH,MENU_BUTTON_HEIGHT,'down',CreateTextureText(ps,etatControle(p,'down'),loaded_font,couleur)),t[current]);
	x := prevButton(t[current]).x;
	y := prevButton(t[current]).y + MENU_BUTTON_HEIGHT + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH,MENU_BUTTON_HEIGHT,'left',CreateTextureText(ps,etatControle(p,'left'),loaded_font,couleur)),t[current]);
	x := prevButton(t[current]).x;
	y := prevButton(t[current]).y + MENU_BUTTON_HEIGHT + SPACE_TEXT_HEIGHT;
	addButton(newButton(x,y,MENU_BUTTON_WIDTH,MENU_BUTTON_HEIGHT,'right',CreateTextureText(ps,etatControle(p,'right'),loaded_font,couleur)),t[current]);
	{changement screen}
	current := changement;
	x := MENU_BACK_X;
	y := MENU_BACK_Y;
	addButton(newButton(x,y,MENU_ARROW_WIDTH,MENU_ARROW_HEIGHT,'retour',ps^.triangleg),t[current]);
	x := (MENU_WIDTH - MENU_CHANGE_WIDTH) div 2;
	y := (MENU_HEIGHT - MENU_CHANGE_HEIGHT) div 2;
	addButton(newButton(x,y,MENU_CHANGE_WIDTH,MENU_CHANGE_HEIGHT,'_change',createTextureChangementControle(ps, loaded_font, couleur)),t[current]);
	
	SetButtonsArray := t;
end; 		
			
procedure menu(var plateau : Plateau);
var
	p_screen : PSDL_surface;
	p_sprite_sheet : PSpriteSheetMenu;
	colour_font, colour_font2 : PSDL_COLOR;
	loaded_font : pointer;
	test_event : PSDL_Event;
	loopstop : boolean;
	x, y : Integer;
	nom, tempControle : String;
	temp : PChar;
	deroulant_x : deroulantTab;
	boutons : TButtons;
	current : ecran = main;
	{gestion de la musique}
	music : pMix_Music = NIL; //pointe vers le fichier de musique
	sound : pMix_Chunk = NIL; //pointe vers le fichier de bruitages
	soundChannel : Integer;
begin
	{parametres de base}
	plateau.vol := 10;
	plateau.coupe := false;
	plateau.up := 273; 
	plateau.down := 274; 
	plateau.right := 275; 
	plateau.left := 276;
	plateau.mode := normal;
	plateau.theme := standard;
	plateau.partie := True;
	
	SDL_Init(SDL_INIT_VIDEO);
	SDL_Init(SDL_INIT_AUDIO);
	if mix_openaudio(FREQUENCY,FORMAT,CHANNELS,CHUNKSIZE) <> 0 then
		halt;
		
	SDL_WM_SetCaption('Frogger_Menu', NIL);
	p_sprite_sheet := newSpriteSheetMenu();
	p_screen := SDL_SetVideoMode(MENU_WIDTH, MENU_HEIGHT, 32,SDL_SWSURFACE);
	
	music := mix_loadmus('images/frogger_music.mp3');
	mix_volumeMusic(plateau.vol); //de 0 à 128;  
	mix_playmusic(music, -1); 

	sound := mix_loadwav('images/clic.wav');
	MIX_VOLUMECHUNK(sound, 40);
	
	{gestion de la police}
	if TTF_INIT=-1 then
		halt;
	loaded_font:=TTF_OPENFONT('polices/LinLibertine_DR_G.ttf',55);
	new(colour_font);
	new(colour_font2);
	colour_font^.r:=0;
	colour_font^.g:=0;
	colour_font^.b:=255;
	colour_font2^.r:=255;
	colour_font2^.g:=255;
	colour_font2^.b:=255;
	
	deroulant_x[0] := 0;
	deroulant_x[1] := MENU_DEROULANT_WIDTH+1;

	boutons := setButtonsArray( p_sprite_sheet, plateau, colour_font, colour_font2, loaded_font);

	new(test_event);
	loopstop := false;
	while not loopstop  do
		begin
		if SDL_POLLEVENT(test_event)=1 then
			begin
			case test_event^.type_ of
				SDL_QUITEV : begin
					loopstop := true;
					plateau.partie := False;
					end;
				SDL_MOUSEBUTTONDOWN: begin
					x := test_event^.motion.x;
					y := test_event^.motion.y;
					nom := buttonPushed(x,y,boutons,current);
					if (nom <> '') and ((length(nom) > 0 ) and (nom[1] <> '_' )) then
						soundchannel := MIX_PLAYCHANNEL(-1, sound,0);
					if current = main then
						begin
						case nom of
							'play' : loopstop := true;
							'arrowright', 'arrowleft' :
								begin 
								choixMode(Plateau, nom);
								boutons[main][2].texture := TextureMode(p_sprite_sheet, plateau);
								end;
							'options' : current := options;
							end; //case of
						end
					else if current = options then
						begin
						case nom of
							'retour' : current := main;
							'coupeson' : 
								begin
								plateau.coupe := not plateau.coupe;
								if plateau.coupe then
									mix_pausemusic
								else
									mix_resumemusic;
								boutons[options][2].texture := CreateTextureText(p_sprite_sheet,etatSon(plateau), loaded_font, colour_font);
								end;//coupeson
							'arrowleftv', 'arrowrightv' : 
								begin
								choixVolume(plateau,nom,temp);
								mix_volumeMusic(plateau.vol);
								boutons[options][3].texture := CreateTextureText(p_sprite_sheet,temp, loaded_font, colour_font);
								end;
							'arrowleftt', 'arrowrightt' : 
								begin
								choixTheme(plateau,nom,temp);
								boutons[options][6].texture := CreateTextureText(p_sprite_sheet,temp,loaded_font,colour_font);
								end;
							'controles' : current := controles;
							end;//case of
						end
					else if current = controles then
						begin
						case nom of 
							'retour' : current := options;
							'up', 'down', 'left', 'right' : 
								begin
								current := changement;
								tempControle := nom;
								end;
							end;//case
						end
					else if current = changement then
						begin
						case nom of
							'retour' : current := controles;
						end;
						end; //if changement
					end; // SDL_MOUSEBUTTONDOWN
				SDL_KEYDOWN:
					begin
					if (test_event^.key.keysym.sym = 13) and (current = main) then 
						loopstop := True
					else if (test_event^.key.keysym.sym = 27) and (current = options) then 
						current := main
					else if (current = changement) then
						begin
						case tempControle of
							'up' : 
								begin
								plateau.up := test_event^.key.keysym.sym;
								boutons[controles][1].texture := CreateTextureText(p_sprite_sheet,etatControle(plateau,'up'),loaded_font,colour_font);
								end;
							'down' : 
								begin
								plateau.down := test_event^.key.keysym.sym;
								boutons[controles][2].texture := CreateTextureText(p_sprite_sheet,etatControle(plateau,'down'),loaded_font,colour_font);
								end;
							'left' : 
								begin
								plateau.left := test_event^.key.keysym.sym;
								boutons[controles][3].texture := CreateTextureText(p_sprite_sheet,etatControle(plateau,'left'),loaded_font,colour_font);
								end;
							'right' : 
								begin
								plateau.right := test_event^.key.keysym.sym;
								boutons[controles][4].texture := CreateTextureText(p_sprite_sheet,etatControle(plateau,'right'),loaded_font,colour_font);
								end;
						end;
						current := controles;
						end;
					end;
			end;
		end;
		//SDL_Delay(round(1000/FPS));
		affichageMenu(boutons, current,p_screen, p_sprite_sheet, colour_font, colour_font2, loaded_font, plateau, deroulant_x);
		end;

	SDL_FreeSurface(p_screen);
	disposeSpriteSheetMenu(p_sprite_sheet);
	dispose(colour_font);
	dispose(colour_font2);
	TTF_closefont(loaded_font);
	TTF_Quit;
	{gestion de la musique}
	mix_haltmusic;
	mix_haltchannel(soundChannel); //on ne lutilise pas encore
	mix_freeMusic(music);
	mix_freeChunk(sound);
	mix_closeaudio;
	
	SDL_quit;

end;

end.

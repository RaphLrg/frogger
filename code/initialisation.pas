unit initialisation;

interface
    uses sysutils, crt, typesFrogger, sdl, sdl_image;

    // procedure init_sdl(var cst : constantes; var tab_image : tab_picture);

    function extraction_tableau_score(nom_fichier : string): tableau_score;

    // function init_frog(th : theme; cst : constantes; tab : tab_picture): frog;
    // procedure changement_orientation_frog(var grenouille : frog; sens : orientation; tab : tab_picture);

    // function est_un_theme(str_a_verifier : string):boolean;
    // function est_une_categorie(str_a_verifier : string):boolean;
    // function est_un_sens(str_a_verifier : string):boolean;
    // function reconnaissance(str_a_lire : string):string;
    // function extraction(str_a_lire : string):string;
    // procedure init_items(var plateau_ : Plateau; cst : constantes; tab_image : tab_picture; var data_infini : rec_infini);
    // function nb_final(str_a_etudier : string):string;

    procedure initialisation_globale(var p : Plateau; var cst : constantes; var tab_image : tab_picture; var data_infini : rec_infini);
    procedure initialisation_partie(var joueur : Frog; p : plateau; var cst : constantes; var tab_scores : tableau_score; tab_images : tab_picture);
    procedure quitter_sdl(tab : tab_picture);

    procedure initAffichage(cst : constantes; tabImages: tab_picture;var line : ligne; etage : integer);

    function generation_ligne(var data_infini : rec_infini; cst : constantes; var tab_img : tab_picture; etage : integer):ligne;
    procedure decalage_plateau(var p : plateau; cst : constantes; var frog : Frog);


implementation

{ ~~~~~~~~~~~~~~~~~~~~~~~~ Types locaux ~~~~~~~~~~~~~~~~~~~~~~~~ }
    type tab_niveau = array[1..3,1..NB_LIGNES] of string;
    type info_etage = record
        item, fond : array[1..2] of string;
        serie, sens, vitesse, nb_item : string;
    end;
    type categorie_etage = (route, riviere, transition, fin);
    type structure_objet = record
        indice_image : integer;
    end;

{ ~~~~~~~~~~~~~~~~~~~~~~~~ Fonctions et procedures d'initialisation images ~~~~~~~~~~~~~~~~~~~~~~~~ }   //rajouter un dossier menu

    function get_rang(cst : constantes; categ : categorie_image):integer;
    begin
        get_rang := -1;
        case categ of
            voiture : get_rang := cst.rang.voiture;
            rondin : get_rang := cst.rang.rondin;
            biome : get_rang := cst.rang.biome;
            cases : get_rang := cst.rang.cases;
            frogger : get_rang := cst.rang.frogger;
            autre : get_rang := cst.rang.autre;
        end;
    end;

    function get_nb(cst : constantes; categ : categorie_image):integer;
    begin
        get_nb := -1;
        case categ of
            voiture : get_nb := cst.nb.voiture;
            rondin : get_nb := cst.nb.rondin;
            biome : get_nb := cst.nb.biome;
            cases : get_nb := cst.nb.cases;
            frogger : get_nb := cst.nb.frogger;
            autre : get_nb := cst.nb.autre;
        end;
    end;

    procedure set_rang(var cst : constantes; categ : categorie_image; valeur : integer);
    begin
        case categ of
            voiture : cst.rang.voiture := valeur;
            rondin : cst.rang.rondin := valeur;
            biome : cst.rang.biome := valeur;
            cases : cst.rang.cases := valeur;
            frogger : cst.rang.frogger := valeur;
            autre : cst.rang.autre := valeur;
        end;
    end;

    procedure set_nb(var cst : constantes; categ : categorie_image; valeur : integer);
    begin
        case categ of
            voiture : cst.nb.voiture := valeur;
            rondin : cst.nb.rondin := valeur;
            biome : cst.nb.biome := valeur;
            cases : cst.nb.cases := valeur;
            frogger : cst.nb.frogger := valeur;
            autre : cst.nb.autre := valeur;
        end;
    end;

    { ~~~~~~ Vérifie la présence d'une erreur de chargement des images ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function verif_erreur_nb_image(total : integer):boolean;
    begin
        verif_erreur_nb_image := true;
        if total > MAX_IMAGES then
        begin
            verif_erreur_nb_image := false;
            writeln('Tentative de charger plus d''images qu''il n''y a plus de place dans le tableau' + #13#10 + 'Veuillez augmenter la constante MAX_IMAGES');
        end;
    end;

    { ~~~~~~ Chargement de l'image pointée (une seule image) ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure charge_surface_image(var image : picture);
    var pimage : pointer;
    begin
		pimage := StrAlloc(length(image.path)+1);
		strPCopy(pimage, image.path);
		image.img := IMG_Load(pimage);
    end;

    { ~~~~~~ Calcule le nombre d'images de chaquee catégorie ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure recense_nb_images(var cst : constantes; categ : categorie_image; dim : string);
    var str_categ : string;
        compteur : integer;
    begin
        compteur := 0;
        writeStr(str_categ,categ);
        while fileExists('ressources/images_' + dim + 'p/' + str_categ + '/' + str_categ + '_' + intToStr(compteur + 1) + '.png') do
            compteur := compteur + 1;
        set_nb(cst,categ,compteur);
    end;

    { ~~~~~~ Initialise les constantes de rang pour chaque catégories d'images et associe à chaque image son adresse ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure recense_path_rang_images(var tab_image : tab_picture; var cst : constantes; dim : string);
    var i, j, rang_actuel : integer;
        categ : categorie_image;
        str_categ : string;
    begin
        rang_actuel := 0;
        categ := low(categ);                                //Initialisation de categ à la 1ère valeur de la liste
        for i := 1 to ord(high(categ)) do                   //Parcours de toute la liste
        begin
            writeStr(str_categ,categ);                      //Transforme la valeur de la liste (categ) en string (str_categ)
            recense_nb_images(cst, categ, dim);                  //Calcul du nombre d'image de chaque catégorie
            set_rang(cst, categ, rang_actuel);              //Calcul du rang de la dernière image de la catégorie précédente
            if verif_erreur_nb_image(get_rang(cst, categ) + get_nb(cst, categ)) then  //Vérification de non dépassement de tableau
                for j := 1 to get_nb(cst, categ) do
                begin                                       //Calcul de l'adresse de chaque image
                    rang_actuel := rang_actuel + 1;
                    tab_image[rang_actuel].path := 'ressources/images_' + dim + 'p/' + str_categ + '/' + str_categ + '_' + intToStr(j) + '.png';
                end;
            categ := succ(categ);                           //Passage à la catégorie suivante
        end;                                                //Calcul du nombre total d'images
        cst.nb_total := cst.nb.biome + cst.nb.cases + cst.nb.frogger + cst.nb.rondin + cst.nb.voiture + cst.nb.autre;
    end;

    { ~~~~~~ Charge toutes les images et associe a chacune ses dimensions en pixels ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure charge_images(var tab_image : tab_picture; var cst : constantes; dim : string);
    var i : integer;
        dimension : tsdl_rect;
    begin
        recense_path_rang_images(tab_image, cst, dim);           //Initialisation des constantes et calcul de l'adresse de chaque image
        if verif_erreur_nb_image(cst.nb_total) then
            for i := 1 to cst.nb_total do
            begin
                charge_surface_image(tab_image[i]);             //Chargement de chaque image
                sdl_getcliprect(tab_image[i].img, @dimension);  //Implémentation des dimensions
                tab_image[i].l := dimension.w;
                tab_image[i].h := dimension.h;
            end
    end;

    { ~~~~~~ Initialisation générale des images ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure init_sdl(var cst : constantes; var tab_image : tab_picture);
    var d : tsdl_rect;
        dim : string;
    begin
        SDL_Init(SDL_INIT_VIDEO);
        tab_image[0].img := SDL_SetVideoMode(0, 0, 32, SDL_FULLSCREEN);     //Création de la fenêtre
        sdl_getcliprect(tab_image[0].img,@d);                               //Calcul de la résolution de l'écran
        tab_image[0].l := d.w;
        tab_image[0].h := d.h;
        //writeln(d.w, ' ',d.h);
        if (tab_image[0].l >= 1920) and (tab_image[0].h >= 1080) then
        begin
            dim := '1080';
            cst.x_max_jeu := 1670;
            cst.x_min_jeu := 0;
            cst.y_max_jeu := 1080;
            cst.y_min_jeu := 0;
        end
        else
        begin
            dim := '720';
            cst.x_max_jeu := 1110;
            cst.x_min_jeu := 0;
            cst.y_max_jeu := 720;
            cst.y_min_jeu := 0;
        end;
        charge_images(tab_image, cst, dim);
    end;

{ ~~~~~~~~~~~~~~~~~~~~~~~~ Fonctions et procedures d'initialisation fichiers ~~~~~~~~~~~~~~~~~~~~~~~~ }

    { ~~~~~~ Extrait du fichier scores un tableau ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function recherche_indice(tab : tableau_score; valeur, borne : integer):integer;
    var gauche, droite, milieu : integer;
    begin
        gauche := 0;
        droite := borne;
        while droite - gauche > 1 do
        begin
            milieu := (droite + gauche) div 2;
            if strToInt(tab[2,milieu]) >= valeur then
                gauche := milieu
            else
                droite := milieu
        end;
        recherche_indice := droite
    end;

    { ~~~~~~ Extrait du fichier scores un tableau ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function extraction_tableau_score(nom_fichier : string): tableau_score;
    var i, j, k, indice_insertion : integer;
        score_actuel : score;
        fichier : file of score;
    begin
        assign(fichier, nom_fichier);
        reset(fichier);
        for i := 1 to MAX_SCORE do                                  //Initialisation du tableau à des valeurs nulles
        begin
            extraction_tableau_score[2,i] := '0';
            extraction_tableau_score[1,i] := ' ';
        end;

        i := 0;
        while not eof(fichier) do                                   //i correspond aux lignes du tableau et du fichier
        begin
            seek(fichier,i);                                        //On se place à la position i (allant de 0 à eof) du fichier
            read(fichier, score_actuel);                            //On récupère les informations de cette position
            k := i + 1;
            if k > MAX_SCORE then k := MAX_SCORE;
            if score_actuel.score > strToInt(extraction_tableau_score[2,MAX_SCORE]) then
            begin
                indice_insertion := recherche_indice(extraction_tableau_score, score_actuel.score, k);      //On calcul l'indice d'insertion du score récupéré
                for j := MAX_SCORE downto indice_insertion + 1 do       //On décale vers la droite la partie à droite de cette indice
                begin
                    extraction_tableau_score[1,j] := extraction_tableau_score[1,j-1];
                    extraction_tableau_score[2,j] := extraction_tableau_score[2,j-1];
                end;                                                    //On insère les nouvelles valeurs
                extraction_tableau_score[1,indice_insertion] := score_actuel.nom;
                extraction_tableau_score[2,indice_insertion] := intToStr(score_actuel.score);
            end;
            i := i + 1;
        end;
        close(fichier);
    end;

{ ~~~~~~~~~~~~~~~~~~~~~~~~ Fonctions et procedures d'initialisation frog ~~~~~~~~~~~~~~~~~~~~~~~~ }     //rajouter l'indice_image

    { ~~~~~~ Initialisation de la grenouille ~~~~~~ }          { ~~~~ NON TESTEE ~~~~ }
    function init_frog(th : theme; cst : constantes; tab : tab_picture): frog;
    begin
        init_frog.hauteur_atteinte := 0;            //Réinitialisation de la hauteur maximale atteinte
        init_frog.dir.sens := haut;                 //Initialisation du sens à haut

        case th of
            standard :
                begin
                    init_frog.indice_image := cst.rang.frogger + 1;
                    init_frog.dir.i_h := 1;
                end;
            medieval :
                begin
                    init_frog.indice_image := cst.rang.frogger + 2;
                    init_frog.dir.i_h := 2;
                end;
            espace :
                begin
                    init_frog.indice_image := cst.rang.frogger + 3;
                    init_frog.dir.i_h := 3;
                end;
            onepiece :
                begin
                    init_frog.indice_image := cst.rang.frogger + 4;
                    init_frog.dir.i_h := 4;
                end;
        end;

        // init_frog.dir.i_h := ord(th) + 1;
        // init_frog.dir.i_b := ord(th)*4 + 2;
        // init_frog.dir.i_g := ord(th)*4 + 3;
        // init_frog.dir.i_d := ord(th)*4 + 4;

        init_frog.l := tab[init_frog.indice_image].l;    //Initialisation des dimensions et de la position de la grenouille
        init_frog.h := tab[init_frog.indice_image].h;


        init_frog.x := tab[0].l div 2;
        init_frog.y := tab[0].h - tab[cst.rang.biome + 1].h;

        init_frog.indice_image := init_frog.dir.i_h;
        init_frog.vies := 3;
        init_frog.score.score := 0;
    end;

    { ~~~~~~ changement d'orientation de la grenouille ~~~~~~ }          { ~~~~ NON TESTEE ~~~~ }
    procedure changement_orientation_frog(var grenouille : frog; sens : orientation; tab : tab_picture);
    var p_dir : pinteger;
    begin
        grenouille.dir.sens := sens;                   //changement du sens
        case sens of                                //Selection de l'image correspondant au sens
            haut : p_dir := @grenouille.dir.i_h;
            bas : p_dir := @grenouille.dir.i_b;
            droite : p_dir := @grenouille.dir.i_d;
            gauche : p_dir := @grenouille.dir.i_g;
        end;
        grenouille.l := tab[p_dir^].l;                 //Mise à jour des dimensions de la grenouille
        grenouille.h := tab[p_dir^].h;
        grenouille.indice_image := p_dir^;
    end;

{ ~~~~~~~~~~~~~~~~~~~~~~~~ Fonctions et procedures d'initialisation objets ~~~~~~~~~~~~~~~~~~~~~~~~ }   //Penser à initiliser le theme et le mode

    { ~~~~~~ Vérifie si la chaîne de caractère corresepond à un theme ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function est_un_theme(str_a_verifier : string):boolean;
    var th : theme;
        i : integer;
        str_test : string;
    begin
        th := low(th);
        est_un_theme := false;
        for i := ord(low(th)) to ord(high(th)) do
        begin
            writeStr(str_test, th);
            if str_test = str_a_verifier then
                est_un_theme := true;
            th := succ(th);
        end;
    end;

    { ~~~~~~ Vérifie si la chaîne de caractère corresepond à une catégorie ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function est_une_categorie(str_a_verifier : string):boolean;
    var categorie : categorie_image;
        i : integer;
        str_test : string;
    begin
        categorie := low(categorie);
        est_une_categorie := false;
        for i := ord(low(categorie)) to ord(high(categorie)) do
        begin
            writeStr(str_test, categorie);
            if str_test = str_a_verifier then
                est_une_categorie := true;
            categorie := succ(categorie);
        end;
    end;

    { ~~~~~~ Vérifie si la chaîne de caractère corresepond à un sens ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function est_un_sens(str_a_verifier : string):boolean;
    var sens : orientation;
        i : integer;
        str_test : string;
    begin
        sens := low(sens);
        est_un_sens := false;
        for i := ord(low(sens)) to ord(high(sens)) do
        begin
            writeStr(str_test, sens);
            if str_test = str_a_verifier then
                est_un_sens := true;
            sens := succ(sens);
        end;
    end;

    { ~~~~~~ Vérifie si la chaîne de caractère corresepond à un mode ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function est_un_mode(str_a_verifier : string):boolean;
    var mode_ : mode;
        i : integer;
        str_test : string;
    begin
        mode_ := low(mode_);
        est_un_mode := false;
        for i := ord(low(mode_)) to ord(high(mode_)) do
        begin
            writeStr(str_test, mode_);
            if str_test = str_a_verifier then
                est_un_mode := true;
            mode_ := succ(mode_);
        end;
    end;

    { ~~~~~~ Vérifie si la chaîne de caractère corresepond à un theme ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function est_un_etage(str_a_verifier : string):boolean;
    var etage : categorie_etage;
        i : integer;
        str_test : string;
    begin
        etage := low(etage);
        est_un_etage := false;
        for i := ord(low(etage)) to ord(high(etage)) do
        begin
            writeStr(str_test, etage);
            if str_test = str_a_verifier then
                est_un_etage := true;
            etage := succ(etage);
        end;
    end;

    { ~~~~~~ Renvoie la 1ère partie d'une chaîne de caractères (séparateur = ' ') ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function reconnaissance(str_a_lire : string):string;
    var i, nb : byte;
    begin
        nb := 0;
        repeat
            nb := nb + 1;
        until((str_a_lire[nb] = ' ') or (nb = length(str_a_lire)));
        for i := 1 to nb do
            reconnaissance[i] := str_a_lire[i];
        if str_a_lire[nb] = ' ' then
            nb := nb - 1;
        setlength(reconnaissance,nb);
    end;

    { ~~~~~~ Renvoie la 2ère partie d'une chaîne de caractères (séparateur = ' ') ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function extraction(str_a_lire : string):string;
    var i, mini, maxi : byte;
    begin
        mini := 0;                                  //On place une borne apres le 1er séparateur
        repeat
            mini := mini + 1;
        until((str_a_lire[mini] = ' ') or (mini = length(str_a_lire)));
        if mini >= length(str_a_lire) then          //Si il n'y a pas de 2ème partie on renvoie une chaîen nulle
            extraction := ''
        else                                        //Sinon
        begin
            maxi := mini;                           //On place la 2eme borne à la fin de la chaîne ou au 2ème séparateur
            repeat
                maxi := maxi + 1;
            until((str_a_lire[maxi] = ' ') or (maxi = length(str_a_lire)));
            if str_a_lire[maxi] = ' ' then
                maxi := maxi - 1;
        end;
        for i := mini to maxi do                    //On renvoie la chaîne correspondant à la 2ème partie de la chaîne en entrée
            extraction[i-mini] := str_a_lire[i];
        setlength(extraction, maxi - mini);
    end;

    { ~~~~~~ Place le fichier en lecture à partir du theme sélectionné ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure position_fichier_str(var fichier : text; str_recherchee : string);
    var str_actuelle : string;
    begin
        repeat
            readln(fichier, str_actuelle);
        until (reconnaissance(str_actuelle) = str_recherchee) or eof(fichier);
    end;

    { ~~~~~~ Place le fichier en lecture à partir du theme sélectionné ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure position_fichier_str_2(var fichier : text; str_recherchee_1, str_recherchee_2 : string);
    var str_actuelle : string;
    begin
        repeat
            readln(fichier, str_actuelle);
        until (((reconnaissance(str_actuelle) = str_recherchee_1) and (extraction(str_actuelle) = str_recherchee_2))) or eof(fichier);
    end;

    { ~~~~~~ Renvoie le 3ème nombre s'il y en a un ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function nb_final(str_a_etudier : string):string;
    var compteur, i, nb : integer;
    begin
        compteur := 0;
        i := 1;
        while (compteur < 2) and (i <= length(str_a_etudier)) do
        begin
            if str_a_etudier[i] = ' ' then
                compteur := compteur + 1;
            i := i + 1;
        end;
        nb := 1;
        while (('0' <= str_a_etudier[i]) and (str_a_etudier[i] <= '9')) and (i <= length(str_a_etudier)) do
        begin
            nb_final[nb] := str_a_etudier[i];
            nb := nb + 1;
            i := i + 1;
        end;
        if nb_final[nb] = ' ' then
            nb := nb - 1;
        setlength(nb_final,nb-1);
    end;

    { ~~~~~~ Initialisation des fichiers ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
        procedure init_fichiers_items(var fichier_niveau,fichier_etage,fichier_objet : text);
        begin
            assign(fichier_niveau, 'fichier_niveau.txt');
            assign(fichier_etage, 'fichier_type_etage.txt');
            assign(fichier_objet, 'fichier_objet.txt');
            reset(fichier_niveau);
            reset(fichier_etage);
            reset(fichier_objet);
        end;

    { ~~~~~~ Récupération des infos du niveau ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function extraction_fichier_niveau(var fichier_niveau : text; str_mode,str_theme : string):tab_niveau;
    var i,j : integer;
        str_niveau, str_actuelle : string;
        theme_non_defini : boolean;

    begin
        theme_non_defini := false;
        position_fichier_str(fichier_niveau,str_mode);                  //Positionnement du fichier niveau en lecture à partir du mode sélectionné
        repeat                                                          //Positionnement du fichier niveau en lecture à partir du theme du mode sélectionné
            readln(fichier_niveau, str_actuelle);
            if est_un_mode(reconnaissance(str_actuelle)) then theme_non_defini := true;
        until (((reconnaissance(str_actuelle) = 'theme') and (extraction(str_actuelle) = str_theme))) or eof(fichier_niveau);

        if not eof(fichier_niveau) and not theme_non_defini then
            for i := 1 to NB_LIGNES do
            begin
                readln(fichier_niveau, str_niveau);                     //Recherche des informations à charger pour chaque étage fonction du niveau
                extraction_fichier_niveau[1,i] := reconnaissance(str_niveau);
                extraction_fichier_niveau[2,i] := extraction(str_niveau);
                extraction_fichier_niveau[3,i] := nb_final(str_niveau);
            end
        else
            for i := 1 to NB_LIGNES do
                for j := 1 to 3 do
                    extraction_fichier_niveau[j,i] := 'erreur';
    end;

    { ~~~~~~ Récupération des infos du etage ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure info_etage_zero(var info : info_etage);
    begin
        info.item[1] := '0';                                            //Initialisation des valeurs de sortie;
        info.item[2] := '0';
        info.fond[1] := '0';
        info.fond[2] := '0';
        info.serie := '0';
        info.sens := '0';
    end;

    { ~~~~~~ Récupération des infos du fichier etage ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function extraction_fichier_etage(var fichier_etage : text; str_theme, type_etage, num_type_etage : string):info_etage;
    var str_etage : string;
    begin
        reset(fichier_etage);
        position_fichier_str(fichier_etage,str_theme);                              //Positionnement du fichier etage en lecture à partir du theme sélectionné
        position_fichier_str_2(fichier_etage,type_etage,num_type_etage);            //Positionnement du fichier niveau en lecture à partir du theme du mode sélectionné
        info_etage_zero(extraction_fichier_etage);                                  //Initialisation des valeurs de sortie;
        repeat                                                                      //Lecture du fichier et extraction des données lues
            readln(fichier_etage, str_etage);
            case reconnaissance(str_etage) of
                'item' :
                begin
                    extraction_fichier_etage.item[1] := extraction(str_etage);
                    extraction_fichier_etage.item[2] := nb_final(str_etage);
                end;
                'nb_item' : extraction_fichier_etage.nb_item := extraction(str_etage);
                'vitesse' : extraction_fichier_etage.vitesse := extraction(str_etage);
                'fond' :
                begin
                    extraction_fichier_etage.fond[1] := extraction(str_etage);
                    extraction_fichier_etage.fond[2] := nb_final(str_etage);
                end;
                'serie' : extraction_fichier_etage.serie := extraction(str_etage);
                'sens' : extraction_fichier_etage.sens := extraction(str_etage);
            end;
        until est_un_etage(reconnaissance(str_etage)) or eof(fichier_etage);                //Arrêt de la lecture une fois que l'on arrive à la description d'un autre étage
    end;

    { ~~~~~~ Vérification des infos récupérées dans le fichier etage ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function verif_etage(info : info_etage; nb_etage : integer):boolean;
    begin
        if (nb_etage = 1) or (nb_etage = 8) or (nb_etage = 15) then
            if info.sens = '0' then
                verif_etage := true
            else
                verif_etage := false
        else
            if (info.sens = 'droite') or (info.sens = 'gauche') then
                verif_etage := true
            else
                verif_etage := false
    end;

    { ~~~~~~ Renvoie les information sur un objet ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function extraction_fichier_objet(var fichier_objet : text; nom_objet, numero_objet, sens, str_theme : string; cst : constantes): structure_objet;
    var str_actuelle, str_categ: string;
        categ : categorie_image;
        numero_image : integer;
    begin
        extraction_fichier_objet.indice_image := -1;                    //Initialisation des valeurs de sortie de la fonction
        categ := low(categ);                                            //Initialisation de la variable de test de catégorie
        reset(fichier_objet);                                           //Dans le fichier objets : On se place en lecture au début du fichier
        position_fichier_str(fichier_objet, str_theme);                                         // On se place dans le thème donné en entrée
        position_fichier_str_2(fichier_objet,nom_objet,numero_objet);                           // On se place sur l'objet précisé dans les entrées
        repeat
            readln(fichier_objet, str_actuelle);
            if reconnaissance(str_actuelle) = sens then                 //Si la ligne lue correspond au sens spécifié en entrée alors on cherche à récupérer l'indice dans le tableau image correspondant à l'image spécifiée apres le sens dans le fichier_objet.txt
            begin
                numero_image := StrToInt(nb_final(str_actuelle));       //On recupère le numero de l'image correspondant à l'objet demandé dans le sens demandé
                writeStr(str_categ, categ);

                while not (extraction(str_actuelle) = str_categ) do     //On recherche la categorie correspondant à la chaîne de catactère lue (extraction(str_actuelle))
                begin
                    categ := succ(categ);
                    writeStr(str_categ, categ);
                end;

                if get_rang(cst, categ) + numero_image <= get_rang(cst, succ(categ)) then   //Si l'indice calculé correspond à une image chargée on renvoie cet indice
                    extraction_fichier_objet.indice_image := get_rang(cst, categ) + numero_image
                else                                                                        //Sinon on renvoie un message d'erreur
                    writeln('L''image ', str_categ, '_',numero_image,'.png ne semble pas exister.');
            end;
        until  est_une_categorie(reconnaissance(str_actuelle)) or eof(fichier_objet);       //On s'arrête lorsqu'on arrive soit à un autre objet soit à la fin du fichier
    end;

    { ~~~~~~ Initialise un étage du plateau ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    function init_ligne(tab_image : tab_picture; cst : constantes; data_objet : structure_objet; data_etage : info_etage; type_etage : string):ligne;
    var i : integer;
        categ : categorie_image;
        str_categ : string;
    begin
        if (type_etage <> 'transition') and (type_etage <> 'fin') then
        begin
            init_ligne.eau := type_etage = 'riviere';
            init_ligne.vitesse := strToInt(data_etage.vitesse);
            init_ligne.taille := strToInt(data_etage.nb_item);
            init_ligne.direction := data_etage.sens = 'droite';         //Utile ou pas ?
            init_ligne.serie := strToInt(data_etage.serie);
            init_ligne.indiceBiome := cst.rang.biome + strToInt(data_etage.fond[2]);
            if init_ligne.taille > MAX_OBJET then
                init_ligne.taille := MAX_OBJET;

            categ := low(categ);
            writeStr(str_categ,categ);
            while str_categ <> data_etage.item[1] do
            begin
                categ := succ(categ);
                writeStr(str_categ,categ);
            end;

            for i := 1 to MAX_OBJET do
            begin
                init_ligne.objets[i].indice_image := get_rang(cst, categ) + strToInt(data_etage.item[2]);
                init_ligne.objets[i].x := 0;
                init_ligne.objets[i].y := 0;
                init_ligne.objets[i].l := tab_image[init_ligne.objets[i].indice_image].l;
                init_ligne.objets[i].h := tab_image[init_ligne.objets[i].indice_image].h;
                if data_etage.sens = 'droite' then
                    init_ligne.objets[i].sens := droite
                else
                    init_ligne.objets[i].sens := gauche;
                init_ligne.objets[i].categorie := categ;
            end;
        end
        else
        begin
            init_ligne.eau := false;
            init_ligne.vitesse := 0;
            init_ligne.taille := 0;
            init_ligne.direction := true;         //Utile ou pas ?
            init_ligne.serie := 0;
            init_ligne.indiceBiome := cst.rang.biome + strToInt(data_etage.fond[2]);
            for i := 1 to MAX_OBJET do
            begin
                init_ligne.objets[i].indice_image := -1;
                init_ligne.objets[i].x := 0;
                init_ligne.objets[i].y := 0;
                init_ligne.objets[i].l := 0;
                init_ligne.objets[i].h := 0;
                init_ligne.objets[i].sens := droite;
                init_ligne.objets[i].categorie := low(categ);
            end;
        end;
    end;

    { ~~~~~~ Vérifie la validité du fichier objets ~~~~~~ }          { ~~~~ NON TESTEE ~~~~ }
    function objet_valide():boolean;
    begin

    end;

    { ~~~~~~ Initialisation des positions des objets au lancement du jeu ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure initAffichage(cst : constantes; tabImages: tab_picture; var line : ligne; etage : integer);
    var j, y_ligne, h, intervalle, alea: Integer;
    begin
        //Initialisation des y
            h := tabImages[line.indiceBiome].h;  //Hauteur de l'image du biome
            y_ligne :=  tabImages[0].h  - (etage-1) * h - h div 2; //Ligne est à la hauteur des autres lignes au dessous moins sa demi hauteur
            //write(y_ligne, '  --  ');
            for j:=1 to line.taille do
                line.objets[j].y := y_ligne - tabImages[line.objets[j].indice_image].h div 2;  //Le coin gauche de l'objet se trouve sur la même hauteur que la ligne moins sa demi hauteur

        //Initialisation des x
            if line.taille > 0 then
            begin
                intervalle := cst.x_max_jeu div line.taille;
                alea := random(intervalle);
                for j := 1 to line.taille do
                begin
                    line.objets[j].x := alea + (j-1) * intervalle;
                    //writeln('ligne : ',i,' | objet : ',j,' | dimension : ',line.objets[j].x);
                end;
            end;
    end;

    { ~~~~~~ Décalage vers le bas de chaque lignes du plateau ~~~~~~ }          { ~~~~ NON TESTEE ~~~~ }
    procedure decalage_plateau(var p : plateau; cst : constantes; var frog : Frog);
    var i, j : integer;
    begin
        for i := 2 to NB_LIGNES-1 do
        begin
            p.lignes[i] := p.lignes[i+1];
            for j := 1 to p.lignes[i].taille do
                p.lignes[i].objets[j].y := p.lignes[i].objets[j].y + cst.y_max_jeu div NB_LIGNES;
        end;
        frog.y := frog.y + cst.y_max_jeu div NB_LIGNES;
    end;

    { ~~~~~~ Récupération des infos du niveau en mode infini ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure extraction_fichier_niveau_infini(var fichier_niveau : text; str_theme : string; var data_infini : rec_infini);
    var str_lecture : string;
    begin
        data_infini.route := [];
        data_infini.riviere := [];
        data_infini.transition := [];
        reset(fichier_niveau);
        position_fichier_str(fichier_niveau,'infini');
        repeat
            readln(fichier_niveau, str_lecture);
        until extraction(str_lecture) = str_theme;
        repeat
            readln(fichier_niveau,str_lecture);
            case reconnaissance(str_lecture) of
                'route': data_infini.route := data_infini.route + [strToInt(extraction(str_lecture))];
                'riviere': data_infini.riviere := data_infini.riviere + [strToInt(extraction(str_lecture))];
                'transition': data_infini.transition := data_infini.transition + [strToInt(extraction(str_lecture))];
            end;
        until est_un_theme(reconnaissance(str_lecture)) or est_un_mode(reconnaissance(str_lecture)) or eof(fichier_niveau);
    end;

    { ~~~~~~ Sélection aléatoire d'une valeur d'un ensemble ~~~~~~ }          { ~~~~ NON TESTEE ~~~~ }
    function valeur_alea(ensemble : ensemble_infini):integer;
    var i, compteur, indice_alea : integer;
    begin
        valeur_alea := 0;
        compteur := 0;
        for i in ensemble do
            compteur := compteur + 1;
        indice_alea := random(compteur) + 1;
        compteur := 0;
        for i in ensemble do
        begin
            compteur := compteur + 1;
            if compteur = indice_alea then
                valeur_alea := i;
        end;
    end;

    { ~~~~~~ Génération du plateau comportant toutes less routes, rivières et transition pouvant être sélectionnée dans le mode infini ~~~~~~ }          { ~~~~ NON TESTEE ~~~~ }
    function generation_ensemble(var fichier_objet, fichier_etage : text; var data_infini : rec_infini; str_theme : string; tab_image : tab_picture; cst : constantes): tableau_aleatoire;
    var i,j : integer;
        data_etage : info_etage;
        info_objet : structure_objet;
        p_ensemble : ^ensemble_infini;

    begin
        for i := 1 to 3 do
        begin
            case i of
                1 : begin
                        p_ensemble := @data_infini.route;
                        data_infini.type_etage := 'route';
                    end;
                2 : begin
                        p_ensemble := @data_infini.riviere;
                        data_infini.type_etage := 'riviere';
                    end;
                3 : begin
                        p_ensemble := @data_infini.transition;
                        data_infini.type_etage := 'transition';
                    end;
            end;
            for j in p_ensemble^ do
            begin
                data_etage := extraction_fichier_etage(fichier_etage, str_theme, data_infini.type_etage, intToStr(j));
                info_objet := extraction_fichier_objet(fichier_objet, data_etage.item[1], data_etage.item[2], data_etage.sens, str_theme,cst);
                generation_ensemble[j + (i-1)*MAX_ENSEMBLE_INFINI] := init_ligne(tab_image, cst, info_objet, data_etage, data_infini.type_etage);
            end;
        end;
    end;

    { ~~~~~~ Génération d'une ligne du plateau en mode infini ~~~~~~ }          { ~~~~ NON TESTEE ~~~~ }
    function generation_ligne(var data_infini : rec_infini; cst : constantes; var tab_img : tab_picture; etage : integer):ligne;
    var valeur : integer;
    begin
        if data_infini.nb_couches > 0 then
        begin
            data_infini.nb_couches := data_infini.nb_couches - 1;
            if data_infini.type_etage = 'transition' then
                case random(2) of
                    0 : data_infini.type_etage := 'route';
                    1 : data_infini.type_etage := 'riviere';
                end;
            if data_infini.type_etage = 'route' then
            begin
                repeat
                    valeur := valeur_alea(data_infini.route);
                until data_infini.nb_prec <> valeur;
                generation_ligne := data_infini.tab_alea[valeur];
                data_infini.nb_prec := valeur;
            end
            else
            begin
                repeat
                    valeur := valeur_alea(data_infini.riviere);
                until data_infini.nb_prec <> valeur;
                generation_ligne := data_infini.tab_alea[valeur + MAX_ENSEMBLE_INFINI];
                data_infini.nb_prec := valeur;
            end;
            initAffichage(cst, tab_img, generation_ligne, etage);
        end
        else
        begin
            data_infini.nb_couches := random(3) + 3;
            data_infini.type_etage := 'transition';
            generation_ligne := data_infini.tab_alea[valeur_alea(data_infini.transition) + 2*MAX_ENSEMBLE_INFINI];
        end;
    end;

    { ~~~~~~ Génération d'un niveau en mode infini ~~~~~~ }          { ~~~~ NON TESTEE ~~~~ } //encore un soucis de plantage a elucider
    function generation_niveau(var data_infini : rec_infini):tab_niveau;
    var i, valeur : integer;
    begin
        data_infini.nb_couches := 0;
        data_infini.nb_prec := 0;
        for i := 1 to NB_LIGNES do
        begin
            if data_infini.nb_couches < 1 then
            begin
                data_infini.type_etage := 'transition';
                data_infini.nb_couches := random(3) + 3;
            end
            else
            begin
                data_infini.nb_couches := data_infini.nb_couches - 1;
                if data_infini.type_etage = 'transition' then
                    if random(2) = 0 then
                        data_infini.type_etage := 'route'
                    else
                        data_infini.type_etage := 'riviere';
            end;
            generation_niveau[1,i] := intToStr(i);
            generation_niveau[2,i] := data_infini.type_etage;
            case data_infini.type_etage of
                'route':
                begin
                    repeat
                        valeur := valeur_alea(data_infini.route);
                    until data_infini.nb_prec <> valeur;
                    generation_niveau[3,i] := intToStr(valeur);
                    data_infini.nb_prec := valeur;
                end;
                'riviere':
                begin
                    repeat
                        valeur := valeur_alea(data_infini.riviere);
                    until data_infini.nb_prec <> valeur;
                    generation_niveau[3,i] := intToStr(valeur);
                    data_infini.nb_prec := valeur;
                end;
                'transition': generation_niveau[3,i] := intToStr(valeur_alea(data_infini.transition));
            end;
            if generation_niveau[3,i] = intToStr(0) then writeln('Probleme fonction valeur_alea');
            //writeln(generation_niveau[1,i],' ',generation_niveau[2,i],' ',generation_niveau[3,i],' ');
        end;
        //writeln(data_infini.nb_couches);
    end;

    { ~~~~~~ Initialisation des objets en fonction du fichier objets ~~~~~~ }          { ~~~~ TESTEE ~~~~ }
    procedure init_items(var plateau_ : Plateau; cst : constantes; tab_image : tab_picture; var data_infini : rec_infini);
    var fichier_niveau, fichier_etage, fichier_objet : text;
        str_theme, str_mode : string;
        info_niveau : tab_niveau;
        info_etage_ : info_etage;
        info_objet : structure_objet;
        i : integer;

    begin
        writeStr(str_theme, plateau_.theme);                                    //Initialisation des chaînes de caractère du theme et du mode
        writeStr(str_mode, plateau_.mode);
        init_fichiers_items(fichier_niveau,fichier_etage,fichier_objet);        //Initialisation des fichiers

        if str_mode <> 'infini' then
        begin
            info_niveau := extraction_fichier_niveau(fichier_niveau, str_mode, str_theme);
            data_infini.route := [];
            data_infini.riviere := [];
            data_infini.transition := [];
        end
        else
        begin
            extraction_fichier_niveau_infini(fichier_niveau, str_theme, data_infini);
            info_niveau := generation_niveau(data_infini);
            data_infini.tab_alea := generation_ensemble(fichier_objet, fichier_etage, data_infini, str_theme, tab_image, cst);
            //renvoyer le plateau de départ aléatoirement
            //ensuite en continu créer une procédure EFFICACE qui met le plateau a jour d'un seul étage
        end;
        if info_niveau[1,1] <> 'erreur' then
            for i := 1 to NB_LIGNES do
            begin
                info_etage_ := extraction_fichier_etage(fichier_etage, str_theme, info_niveau[2,i], info_niveau[3,i]);  //Recherche des informations à charger pour chaque étage fonction du niveau

                if verif_etage(info_etage_, i) or (str_mode = 'infini') then
                begin
                    info_objet := extraction_fichier_objet(fichier_objet, info_etage_.item[1], info_etage_.item[2], info_etage_.sens, str_theme,cst);
                    plateau_.lignes[i] := init_ligne(tab_image, cst, info_objet, info_etage_, info_niveau[2,i]);
                end
                else
                    writeln('|| Erreur fichier niveau || Mode : ', str_mode,', Theme : ', str_theme,', Ligne : ',i,' || L''etage demande n''est pas defini dans le fichier fichier_type_etage.txt');

                //writeln(info_niveau[1,i],' ',info_niveau[2,i],' ','''',info_niveau[3,i],'''');
                //write('Item : ',info_etage_.item[1],' ',info_etage_.item[2],', font : ',info_etage_.fond[1],' ',info_etage_.fond[2]);
                //writeln(', nb_item : ',info_etage_.nb_item,', serie : ',info_etage_.serie,', sens : ',info_etage_.sens);
            end
        else
            writeln('Le theme ',str_theme,' n''est pas defini dans le mode ',str_mode,' dans le fichier fichier_niveau.txt');

        {position_fichier_str(fichier_objet,str_theme);                          //Positionnement du fichier objets en lecture à partir du theme sélectionné
        repeat                                                                  //Parcours du theme selectionné dans le fichier objets
            readln(fichier_objet, str_actuelle);
        until est_un_theme((str_actuelle)) or eof(fichier_objet);}

        close(fichier_niveau);
        close(fichier_etage);
        close(fichier_objet);
    end;

{ ~~~~~~~~~~~~~~~~~~~~~~~~ Procedures d'initialisation globale et parties~~~~~~~~~~~~~~~~~~~~~~~~ }

    { ~~~~~~ Initialisation au lancement du jeu ~~~~~~ }
    procedure initialisation_globale(var p : Plateau; var cst : constantes; var tab_image : tab_picture; var data_infini : rec_infini);
    var etage : integer;
    begin
        init_sdl(cst, tab_image);
        init_items(p, cst, tab_image, data_infini);
        for etage := 1 to NB_LIGNES do
            initAffichage(cst,tab_image, p.lignes[etage], etage);
    end;

    procedure initialisation_partie(var joueur : Frog; p : plateau; var cst : constantes; var tab_scores : tableau_score; tab_images : tab_picture);
    begin
        if p.mode = infini then
            cst.temps_max_partie := -1
        else
            cst.temps_max_partie := LIMITE_TEMPS_MANCHE;

        joueur := init_frog(p.theme, cst, tab_images);

        tab_scores := extraction_tableau_score('donnees/scores');
    end;

    procedure quitter_sdl(tab : tab_picture);
    var i : integer;
    begin
        for i := 0 to MAX_IMAGES do
            SDL_FreeSurface(tab[i].img);
        sdl_quit();
    end;
end.



//Il reste a faire la procedure de decalage du plateau
















//A faire :
//Debuguer initAffichage
//Verifier indices biomes
//
//

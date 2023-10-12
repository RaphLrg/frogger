program test;

uses typesFrogger, Initialisation, sdl, sdl_image, sysutils, crt, sauvegarde;

function diffTemps(temps1, temps2 : TSystemTime {Temps1 - Temps2}):longint;

begin
	diffTemps := (temps2.millisecond - temps1.millisecond) + 1000*(temps2.second - temps1.second) + 60000*(temps2.minute - temps1.minute) + 3600*1000*(temps2.hour - temps1.hour) + 3600*1000*24*(temps2.day - temps1.day); //  + 3600*1000*24*30*(temps2.month - temps1.month) + 3600*1000*24*12(temps2.year - temps1.year)
end;

var tab_image : tab_picture;
    cst : constantes;
    d, h, j, u, v : tsdl_rect;
    i, indice, vitesse : integer;
    str : string;
    nom_fichier : string;
    sc : score;
    k : char;
    tab : tableau_score;
    fichier : file of objet;
    item : objet;
    plateau_ : plateau;
    fichier_text : text;
    t_1, t_2 : tSystemTime;

begin

    //init_sdl(cst, tab_image);
    // for i := 1 to cst.nb_total do
    //     writeln('x : ', tab_image[i].l, ', y : ', tab_image[i].h, ', path : ', tab_image[i].path);
    
    
    

    
    // d.x := 650;
    // d.y := 800;

    // h.x := 0;
    // h.y := 100;

    // j.x := 1280;
    // j.y := 600;
    
    // u.x := 10;
    // u.y := 90;

    // v.x := 10;
    // v.y := 590;


    // for i := 1 to 5 do
    // begin
    //     sdl_blitsurface(tab_image[cst.rang.rondin + 2].img,nil,tab_image[0].img,@d);
    //     d.x := d.x - 44;
    // end;

    // sdl_blitsurface(tab_image[cst.rang.voiture + 1].img,nil,tab_image[0].img,@h);
    // sdl_blitsurface(tab_image[cst.rang.voiture + 2].img,nil,tab_image[0].img,@j);

    // sdl_flip(tab_image[0].img); 
    // DateTimeToSystemTime(Now,t_1);

    // //sdl_blitsurface(tab_image[cst.rang.biome + 1].img,nil,tab_image[0].img,@u);
    // //sdl_blitsurface(tab_image[cst.rang.biome + 2].img,nil,tab_image[0].img,@v);

    // for i := 1 to 500 do
    // begin
    //     DateTimeToSystemTime(Now,t_2);

    //     if diffTemps(t_1,t_2) < 100 then
    //     begin
    //         vitesse := 1*(1*diffTemps(t_1,t_2))div 4;
    //         j.x := j.x - vitesse;
    //         h.x := h.x + vitesse;
    //         //writeln(vitesse);
    //         sdl_blitsurface(tab_image[cst.rang.voiture + 1].img,nil,tab_image[0].img,@h);
    //         sdl_blitsurface(tab_image[cst.rang.voiture + 2].img,nil,tab_image[0].img,@j);

    //         sdl_flip(tab_image[0].img); 
    //         DateTimeToSystemTime(Now,t_1);

    //         sdl_blitsurface(tab_image[cst.rang.biome + 1].img,nil,tab_image[0].img,@u);
    //         sdl_blitsurface(tab_image[cst.rang.biome + 2].img,nil,tab_image[0].img,@v);
    //     end;


    // end;

    // h.x := 0;
    // h.y := 100;

    // j.x := 1280;
    // j.y := 600;
    
    // u.x := 10;
    // u.y := 90;

    // v.x := 10;
    // v.y := 590;

    // for i := 1 to 500 do
    // begin
    //     vitesse := 1;
    //     j.x := j.x - vitesse;
    //     h.x := h.x + vitesse;
    //     //writeln(vitesse);
    //     sdl_blitsurface(tab_image[cst.rang.voiture + 1].img,nil,tab_image[0].img,@h);
    //     sdl_blitsurface(tab_image[cst.rang.voiture + 2].img,nil,tab_image[0].img,@j);

    //     sdl_flip(tab_image[0].img); 

    //     sdl_blitsurface(tab_image[cst.rang.biome + 1].img,nil,tab_image[0].img,@u);
    //     sdl_blitsurface(tab_image[cst.rang.biome + 2].img,nil,tab_image[0].img,@v);
    // end;
    
    // //delay(1000);

    // sdl_quit();

    {for i := 11 to MAX_SCORE do
        tab[2,i] := '0';
    tab[2,1] := '1';
    tab[2,2] := '1';
    tab[2,3] := '1';
    tab[2,4] := '1';
    tab[2,5] := '1';
    tab[2,6] := '2';
    tab[2,7] := '4';
    tab[2,8] := '4';
    tab[2,9] := '4';
    tab[2,10] := '4';

    for i := 1 to 11 do write(tab[2,i],' ');

    write(#10#13, recherche_indice(tab, 3, 10), #10#13);
    indice := recherche_indice(tab, 3, 10);
    
    for i := MAX_SCORE downto indice +1 do
    begin
        //tab[1,i] := tab[1,i-1];
        tab[2,i] := tab[2,i-1];
    end;
    tab[2,indice] := '3';
    for i := 1 to 11 do write(tab[2,i],' ');

    nom_fichier := 'fichier_score_test';
    randomize;
    for k := 'a' to 'z' do
    begin
        sc.nom := k;
        sc.score := random(25)+ 3;
        enregistrerScore(nom_fichier,sc);
    end;}

    {for i := 1 to MAX_SCORE do 
    begin
        tab[1,i] := '';
        tab[2,i] := '0';
    end;
    tab := extraction_tableau_score(nom_fichier);
    for i := 1 to MAX_SCORE do write(tab[1,i],' : ', tab[2,i], ', ');}
    {assign(fichier,'abc.txt');
    rewrite(fichier);
    for i := 1 to 20 do
    begin
        seek(fichier, i);
        item.x := i+1;
        item.y := i;
        item.l := i;
        item.h := i;
        item.vitesse := i;
        item.categorie := i;
        write(fichier, item);
    end;
    writeln('ok');
    reset(fichier);
    for i := 0 to 9 do 
    begin
        seek(fichier, i);
        read(fichier, item);
        write(i,' ',item.x,', ');
    end;
    close(fichier);}
    
    {str := 'voiture 1               description de la voiture 1';
    for indice:=1 to length(str) do
        for i := 0 to 255 do
            if str[indice] = chr(i) then
                writeln(indice,' ''',chr(i),'''  ',i);
    writeln(length(str));
    writeln('''',reconnaissance(str),'''');
    writeln(est_un_theme(reconnaissance(str)),' ',est_une_categorie(reconnaissance(str)), ' ', est_un_sens(reconnaissance(str)));
    writeln('''',extraction(str),'''');
    quitter_sdl(tab_image);}
    plateau_.theme := standard;
    plateau_.mode := difficile;

    //init_items(plateau_,cst,tab_image);
    // writeln('plateau_.theme = ',plateau_.theme,' | plateau_.mode = ',plateau_.mode);
    // delay(2000);
    // for i := 1 to MAX_ETAGE do
    // begin
    //     writeln('i : ', i, ' | plateau_.lignes[i].vitesse = ',plateau_.lignes[i].vitesse, ' | plateau_.lignes[i].taille = ',plateau_.lignes[i].taille,' | plateau_.lignes[i].taille = ',plateau_.lignes[i].taille,' | plateau_.lignes[i].serie = ',plateau_.lignes[i].serie);
    //     //writeln('plateau_.lignes[i].eau = ',plateau_.lignes[i].eau,' | plateau_.lignes[i].indiceBiome = ',plateau_.lignes[i].indiceBiome,' | plateau_.lignes[i].direction = ',plateau_.lignes[i].direction);
    //     //for indice := 1 to 1 do //plateau_.lignes[i].taille do
    //     //    writeln('x = ',plateau_.lignes[i].objets[indice].x,' | y = ',plateau_.lignes[i].objets[indice].y,' | l = ',plateau_.lignes[i].objets[indice].l,' | h = ',plateau_.lignes[i].objets[indice].h,' | indice = ',plateau_.lignes[i].objets[indice].indice_image,' | categorie = ',plateau_.lignes[i].objets[indice].categorie,' | sens = ',plateau_.lignes[i].objets[indice].sens);
    //     //delay(2000);
    // end;
    //writeln('1');
    
    initialisation_globale(plateau_, cst, tab_image);

    indice := 1;
    for i := 1 to NB_LIGNES do
        //for indice := 1 to plateau_.lignes[i].taille do
            writeln('i = ',i,' | x = ',plateau_.lignes[i].objets[indice].x,' | y = ',plateau_.lignes[i].objets[indice].y,' | l = ',plateau_.lignes[i].objets[indice].l,' | h = ',plateau_.lignes[i].objets[indice].h,' | indice = ',plateau_.lignes[i].objets[indice].indice_image,' | categorie = ',plateau_.lignes[i].objets[indice].categorie,' | sens = ',plateau_.lignes[i].objets[indice].sens);

    //writeln('');

    //initAffichage(tab_image,plateau_);
    //for i := 1 to NB_LIGNES do //plateau_.lignes[i].taille do
    //    writeln('i = ',i,' | x = ',plateau_.lignes[i].objets[indice].x,' | y = ',plateau_.lignes[i].objets[indice].y,' | l = ',plateau_.lignes[i].objets[indice].l,' | h = ',plateau_.lignes[i].objets[indice].h,' | indice = ',plateau_.lignes[i].objets[indice].indice_image,' | categorie = ',plateau_.lignes[i].objets[indice].categorie,' | sens = ',plateau_.lignes[i].objets[indice].sens);
end.
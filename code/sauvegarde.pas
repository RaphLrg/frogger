unit sauvegarde;

interface

uses sysutils, typesFrogger;

procedure enregistrerScore(nomFichier: String; score: Score);

implementation

procedure enregistrerScore(nomFichier: String; score: Score);
{ Permet d'enregistrer le score et le nom du joueur qui a joué dans un fichier typé }
var fichier: file of Score;
begin
  assign(fichier, nomFichier);
  if FileExists(nomFichier) then
  begin
    reset(fichier); // ouvre le fichier en mode lecture/écriture pour les fichiers typés
    seek(fichier, Filesize(fichier)); // permet de se placer à la fin du fichier
  end
  else
    rewrite(fichier); // créé le fichier et l'ouvre en mode écriture
  write(fichier, score);
  close(fichier);
end;

end.

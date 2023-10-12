unit unitDeplacementObjets;

interface

uses typesFrogger;

procedure deplacementObjets(var p:plateau; delta_t: Real; X_MAX : integer);

implementation

procedure deplacementObjets(var p:plateau; delta_t: Real; X_MAX : integer);
var i,j,posNext:Integer;
var sens:Integer;
begin
	for i:=1 to NB_LIGNES do
	begin
		if p.lignes[i].direction then
			sens:=+1
		else
			sens:=-1;
		for j:=1 to p.lignes[i].taille do
		begin
			posNext:=p.lignes[i].objets[j].x+round(sens*p.lignes[i].vitesse * delta_t);
			if not(posNext<0-p.lignes[i].objets[j].l) and not(posNext>X_MAX)  then
				p.lignes[i].objets[j].x:=posNext
			else
				if (posNext<0-p.lignes[i].objets[j].l) then
					p.lignes[i].objets[j].x:= X_MAX
				else if (posNext>X_MAX) then
					p.lignes[i].objets[j].x:=0-p.lignes[i].objets[j].l;
		end;
	end;
end;

end.

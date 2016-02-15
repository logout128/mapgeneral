MapGeneral
----------
Perlový skript, umožňující stáhnout mapové podklady se serveru Mapy.cz a vytvořit z nich .tar použitelný v aplikaci Locus pro Android. 

Použití
-------
mapgeneral.pl "parametr1" "parametr2" parametr3 parametr4 parametr5

    parametr1 – URL levého spodního rohu stahované oblasti
    parametr2 – URL pravého horního rohu stahované oblasti
			Tvar URL: http://www.mapy.cz/#x=13.416047&y=49.754452&z=15. 
			Pro skript jsou podstatné parametry x= a y=, zbytek je ignorován. 
			Tyto dva parametry je nutné uzavřít do uvozovek.

    parametr3 – typ mapy:
			turist – čístá turistická mapa bez vyznačených turistických a cyklostezek
			turist_trail – turistická mapa s turistickými stezkami
			turist_bike – turistická mapa s cyklostezkami
			turist_trail_bike – turistická mapa s turistickými a cyklostezkami

    parametr4 – zoom (přiblížení) mapy
			Číslo za parametrem z= v URL mapy, u turistických map je nejpodrobnější
			přiblížení označené jako 16, při použití čísla vyššího server vrací
			letecké snímky, nemá proto smysl tuto hranici překračovat. 
			Už při z=13 zabírá celá ČR několik GB, při bližším přiblížení pak půjde
			o opravdu velký objem dat.

    parametr5 – jméno výsledného archivu bez přípony
    
Závislosti
----------
Skript ke svému fungování vyžaduje přítomnost programu tar a následující perlové moduly:
*	Geo::Coordinates::UTM
*	WWW::Mechanize
*	File::Copy

Licence
-------
Tento program je šířen pod licencí GNU General Public License ve verzi 3 nebo
novější. Pro plné znění této licence čtete soubor GPL.txt, distribuovaný společně
s tímto programem.

#!/usr/bin/perl

# MapGeneral 0.256
# Downloads map tiles from mapy.cz and builds .tar for Locus / Android.

use Geo::Coordinates::UTM;
use WWW::Mechanize;
use File::Copy;
use strict;

printf "\nMapGeneral 0.256\n\n";

$ARGV[0] =~ m/#x=([\d].*)&y=([\d].*)/;
my $lon1 = $1;
my $lat1 = $2;			

$ARGV[1] =~ m/#x=([\d].*)&y=([\d].*)/;
my $lon2 = $1;
my $lat2 = $2;			

my $t = $ARGV[2];
my $z = $ARGV[3];

my $mapname = $ARGV[4];

printf "Processing coordinates:\n\tN\t%f - %f\n\tE\t%f - %f\n\tZoom\t%d\n\tType\t%s\n", $lat1, $lat2, $lon1, $lon2, $z, $t;

my ($zone1, $utm_e1, $utm_n1) = latlon_to_utm_force_zone("WGS-84", 33, $lat1, $lon1); 
my ($zone2, $utm_e2, $utm_n2) = latlon_to_utm_force_zone("WGS-84", 33,  $lat2, $lon2);

$utm_e1 = (int($utm_e1)+3700000)*32;
$utm_e2 = (int($utm_e2)+3700000)*32;
$utm_n1 = (int($utm_n1)-1300000)*32;
$utm_n2 = (int($utm_n2)-1300000)*32;

my $step =  1 << (28-$z);

$utm_e1 = int($utm_e1/$step)*$step;
$utm_e2 = int($utm_e2/$step)*$step;
$utm_n1 = int($utm_n1/$step)*$step;
$utm_n2 = int($utm_n2/$step)*$step;


printf "Downloading tiles...\n";

my $wm = WWW::Mechanize->new();
my $server = "http://mapserver.mapy.cz";
my $url; my $filename; my $locpath;
my $finalfile;

system("rm -f set/*");

open(SETFILE, ">".$mapname.".set"); 

for (my $x=$utm_e1;$x<=$utm_e2;$x+=$step) {
	for (my $y=$utm_n2;$y>=$utm_n1; $y-=$step) {
	
		$locpath = sprintf "%s/", $t;
		$filename = sprintf "%s_%x_%x", $z, $x, $y;
		if (-e $locpath.$filename) {
			printf "Tile %s exists, not downloading.\n", $filename;
		}
		else {
			$url = sprintf "%s/%s/%s", $server, $t, $filename;
			printf "%s\n",$url;
			$wm->get($url);
			$wm->save_content($locpath.$filename);
		}

		$finalfile = sprintf "t_%d_%d.png", (int(($x-$utm_e1)/$step)*256), (int(($utm_n2-$y)/$step)*256);
		copy($locpath.$filename, "set/".$finalfile);
		printf SETFILE $finalfile."\r\n";
	}
}

close(SETFILE);

my $pe = int(($utm_e2-$utm_e1)/$step+1)*256-1;
my $pn = int(($utm_n2-$utm_n1)/$step+1)*256-1;

$utm_e1 = int($utm_e1/32)-3700000;
$utm_e2 = int(($utm_e2+$step)/32)-3700000;
$utm_n1 = int($utm_n1/32)+1300000;
$utm_n2 = int(($utm_n2+$step)/32)+1300000;


open (MAPFILE, ">".$mapname.".map");

printf MAPFILE "OziExplorer Map Data File Version 2.2\r\n";
printf MAPFILE $mapname."\r\n";
printf MAPFILE $mapname.".map\r\n";
printf MAPFILE "1 ,Map Code,\r\n";
printf MAPFILE "WGS 84,WGS 84,   0.0000,   0.0000,WGS 84\r\n";
printf MAPFILE "Reserved 1\r\n";
printf MAPFILE "Reserved 2\r\n";
printf MAPFILE "Magnetic Variation,,,E\r\n";
printf MAPFILE "Map Projection,(UTM) Universal Transverse Mercator,PolyCal,No,AutoCalOnly,No,BSBUseWPX,No\r\n";

printf MAPFILE "Point%.02d,xy,%5d,%5d,in, deg,    ,        ,N,    ,        ,W, grid, 33,%11d,%11d,N\r\n", 1, 0, 0, $utm_e1, $utm_n2;
printf MAPFILE "Point%.02d,xy,%5d,%5d,in, deg,    ,        ,N,    ,        ,W, grid, 33,%11d,%11d,N\r\n", 2, $pe, $pn, $utm_e2, $utm_n1;

for (my $i=3; $i<=30;$i++) {
   printf MAPFILE "Point%.02d,xy,     ,     ,in, deg,    ,        ,N,    ,        ,W, grid,   ,           ,           ,N\r\n", $i;
}

printf MAPFILE "Projection Setup,,,,,,,,,,\r\n";
printf MAPFILE "Map Feature = MF ; Map Comment = MC     These follow if they exist\r\n";
printf MAPFILE "Track File = TF      These follow if they exist\r\n";
printf MAPFILE "Moving Map Parameters = MM?    These follow if they exist\r\n";
printf MAPFILE "IWH,Map Image Width/Height,%d,%d\r\n", $pe+1, $pn+1;


close(MAPFILE);


my $tarcmd = sprintf "tar -cf %s.tar %s.map %s.set set/*", $mapname, $mapname, $mapname;

system $tarcmd;

printf "Done.\n";

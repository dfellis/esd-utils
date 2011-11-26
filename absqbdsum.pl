#!/usr/bin/perl

use Tie::Handle::CSV;

$ARGC = @ARGV;
if($ARGC != 4) {
	die "absqbdsum usage: \nabsqbdsum CSVFILE AOX VPULSE TPULSE\n";
}

$fh = Tie::Handle::CSV->new("$ARGV[0]", header => 1, open_mode => '<') or die "$ARGV[0] is not a file: $!";

my $i = 0;
my $deltaT;
my $sum;
while(my $csv_line = <$fh>) {
	if($i == 1) {
		$deltaT = $csv_line->{"timeI"}+0;
	}
	for(my $j = 0.5; $j < $ARGV[2]; $j += 0.5) {
		if(exists($csv_line->{"I" . $j . "V"})) {
			$sum += abs($csv_line->{"I" . $j . "V"}+0);
		}
	}
	if(exists($csv_line->{"I" . $ARGV[2] . "V"}) && $csv_line->{"timeI"} < ($ARGV[3]+0)) {
		$sum += abs($csv_line->{"I" . $j . "V"}+0);
	}
	$i++;
}

close $fh;

$sum = $sum * $deltaT;
$sum = $sum / ($ARGV[1]+0);

print "$sum\n";
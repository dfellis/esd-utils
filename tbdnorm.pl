#!/usr/bin/perl

use Tie::Handle::CSV;

$ARGC = @ARGV;
if($ARGC != 8) {
	die "tbdnorm usage: \ntbdnorm TLPFILE TP VPULSE TPULSE VDEATH N VNORM TNORM\n";
}

$tp = $ARGV[1]+0;
$vpulse = $ARGV[2]+0;
$tpulse = $ARGV[3]+0;
$vdeath = $ARGV[4]+0;
$n = $ARGV[5]+0;
$vnorm = $ARGV[6]+0;
$tnorm = $ARGV[7]+0;

$fh = Tie::Handle::CSV->new("$ARGV[0]", header => 1, open_mode => '<') or die "$ARGV[0] is not a file: $!";

my $tbd = 0;
my $csv_line = <$fh>;
while($csv_line->{"PulseV"} != $vpulse) {
	$tbd += $tp*(($vnorm/$csv_line->{"VDUT"})**(-$n));
	$csv_line = <$fh>;
}

#for(my $j = 0.5; $j < $vpulse; $j += 0.5) {
#	if(exists($csv_line->{"V" . $j . "V"})) {
#		#$tbd += $tp*(10**((-$vaf)*($vnorm-$j))); Wrong equation
#		$tbd += $tp*(($vnorm/$j)**(-$n));
#	}
#}
close $fh;

#$tbd += $tpulse*(10**((-$vaf)*($vnorm-$vpulse))); Wrong equation
$tbd += $tpulse*(($vnorm/$vdeath)**(-$n));

$tbd /= $tnorm;

print "$tbd\n";
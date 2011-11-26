#!/usr/bin/perl

use Tie::Handle::CSV;

$ARGC = @ARGV;
if($ARGC != 3) {
	die "vdeath usage: \nvdeath TWFFILE VPULSE TPULSE\n";
}

$vpulse = $ARGV[1]+0;
$tpulse = $ARGV[2]+0;

$fh = Tie::Handle::CSV->new("$ARGV[0]", header => 1, open_mode => '<') or die "$ARGV[0] is not a file: $!";

my @vdata;
my $csv_line = <$fh>;
while($csv_line->{"timeV"} < ($tpulse * 1e-9 + 2.55e-9)) { #Convert $tpulse to sec and add shift to data start. Cheap solution but its crunchtime.
	unshift(@vdata, $csv_line->{"V" . $vpulse . "V"}+0);
	$csv_line = <$fh>;
}

close $fh;

my $vdeath = ($vdata[12] + $vdata[11] + $vdata[10] + $vdata[9] + $vdata[8]) / 5; #Average 5 points that should be during normal operation together.
print "$vdeath\n";
#!/usr/bin/perl

use Tie::Handle::CSV;

my %columns;
my $maxvalue = "NULL";
my $maxloc = "NULL";

$ARGC = @ARGV;
if($ARGC < 3) {
	die "csvmax usage: \ncsvmax FILE RANGE MAXCOLUMN [COLUMN2 .. COLUMNn]\n";
}

$fh = Tie::Handle::CSV->new("$ARGV[0]", header => 1, open_mode => '<') or die "$ARGV[0] is not a file: $!";

my $i = 0;
while(my $csv_line = <$fh>) {
	for(my $j = 2; $j < $ARGC; $j++) {
		$columns{"col" . $j . "_" . $i} = $csv_line->{$ARGV[$j]}+0;
		if($j == 2 && ($csv_line->{$ARGV[$j]}+0 > $maxvalue || $maxvalue eq "NULL")) {
			$maxvalue = $csv_line->{$ARGV[$j]}+0;
			$maxloc = $i;
		}
	}
	$i++;
}

close $fh;

my $min_print = $maxloc - $ARGV[1];
if($min_print < 0) { $min_print = 0; }

my $max_print = $maxloc + $ARGV[1];
if($max_print >= $i) { $max_print = $i - 1; }

for(my $j = 2; $j < $ARGC; $j++) {
	print "$ARGV[$j]\t";
}
print "\b\n";

for(my $k = $min_print; $k <= $max_print; $k++) {
	for(my $j = 2; $j < $ARGC; $j++) {
		my $temp = $columns{"col" . $j . "_" . $k};
		print "$temp\t";
	}
	print "\b\n";
}
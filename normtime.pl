#!/usr/bin/perl

#normtime
#normalizes a series of time-based measurements into a single timescale

use strict;
use Text::CSV;

if(@ARGV != 2) {
        print "Syntax: normtime [COLUMN] [CSVFILE]\n";
}

open(CSV, "<$ARGV[1]");

my $prevTime = 0;
my $delta = 0;
my $csv = Text::CSV->new();
my $line = <CSV>;
print $line;
$line = <CSV>;
while($line) {
	$csv->parse($line);
	my @columns = $csv->fields();
	my $currTime = $columns[$ARGV[0]];
	$currTime =~ s/"//g;
	if($currTime < $prevTime) { # New measurement cycle
		$delta += $prevTime;
	}
	$prevTime = $currTime;
	$columns[$ARGV[0]] = $currTime + $delta;
	print join(",", @columns) . "\n";
        $line = <CSV>;
}

close(CSV);


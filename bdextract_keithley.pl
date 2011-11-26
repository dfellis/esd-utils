#!/usr/bin/perl

#bdextract_keithley
#extracts the time-to-breakdown from a a pre-processed (with at least xls2csv3) Keithley output data

use strict;
use Text::CSV;

if(@ARGV != 2) {
        print "Syntax: normtime [COLUMN(s)] [CSVFILE]\n";
}

open(CSV, "<$ARGV[1]");

my @reqCols = split(",", $ARGV[0]);
my @colNums;
my @prevVals;
my $timeCol = -1;
my $csv = Text::CSV->new();
my $line = <CSV>;
my $firstLine = 1;
while($line) {
        $csv->parse($line);
        my @columns = $csv->fields();
	if($firstLine == 1) {
		$firstLine = 0;
		for(my $i = 0; $i < @reqCols; $i++) {
			for(my $j = 0; $j < @columns; $j++) {
				if($columns[$j] =~ m/$reqCols[$i]/) {
					$colNums[$i] = $j;
				}
				if($columns[$j] =~ m/Time/) {
					$timeCol = $j;
				}
			}
		}
	} elsif($firstLine == 0) {
		@prevVals = @columns;
		$firstLine = -1;
	} else {
		for(my $i = 0; $i < @colNums; $i++) {
			if($columns[$colNums[$i]] / $prevVals[$colNums[$i]] > 10) {
				print $ARGV[1] . "," . join(",", @columns) . "\n";
				exit;
			}
		}
	}
        $line = <CSV>;
}

close(CSV);


#!/usr/bin/perl
#The line above indicates to BASH what interpretter to use when "running" a text file.

#       $ARGV[0]  $ARGV[1]
#csv2st [OPTIONS] [CSVFILE]

use strict;
use Text::CSV;

my $user = getlogin();
my $pid = $$;
my $pwd;
my $outfile;
#Regular Expression below matches (checks for) the existance of a \ or a / (to see if a full path is provided)
if($ARGV[1] =~ /[\/\\]/) {
	$pwd = $ARGV[1];
	#Regular Expression below substitutes (replaces) the full path and filename with just the full path.
	$pwd =~ s/(.*)[\/\\]([^\/\\]*)$/\1/;
	$outfile = $2;
} else {
	$pwd = `pwd`;
	#Regular Expression below substitutes (replaces) <ENTER> with nothing.
	$pwd =~ s/[\n\r\f]//g;
	$outfile = $ARGV[1];
}
$outfile =~ s/.csv$//;
$outfile .= "_" . lc($ARGV[0]) . ".st";
my $csv = Text::CSV->new();
open(CSV, $ARGV[1]) or die "Cannot open CSV File: $!";
# ">" means write/overwrite. ">>" means append to this file. "<" (default) means read from this file.
open(ST, ">$pwd/$outfile") or die "Cannot open ST File for Writing: $!";
my $firstline = 1;
my $valCol;
my $timeCol;
while(<CSV>) {
	if($csv->parse($_)) {
		my @columns = $csv->fields();
		if($firstline == 1) {
			$firstline = 0;
			for(my $i = 0; $i < @columns; $i++) {
				if((lc($ARGV[0]) =~ /v/ && lc($columns[$i]) eq "voltage") || (lc($ARGV[0]) =~ /i/ && lc($columns[$i]) eq "current")) {
					$valCol = $i;
				}
				if(lc($columns[$i]) eq "time") {
					$timeCol = $i;
				}
			}
		} elsif($firstline == 0) {
			$firstline = -1;
			if(lc($ARGV[0]) =~ /pwl/) {
				print ST $columns[$timeCol] . " " . $columns[$valCol] . " ";
			} elsif(lc($ARGV[0]) =~ /tlp/) {
				print ST $columns[$valCol] . " at " . $columns[$timeCol];
			}
		} else {
			if(lc($ARGV[0]) =~ /pwl/) {
				print ST $columns[$timeCol] . " " . $columns[$valCol] . " ";
			} elsif(lc($ARGV[0]) =~ /tlp/) {
				print ST ", " . $columns[$valCol] . " at " . $columns[$timeCol];
			}
		}
	}
}
close(CSV);
close(ST);
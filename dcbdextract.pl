#!/usr/bin/perl

#dcbdextract FILE

use strict;
use Text::CSV;

if(@ARGV != 1) {
	die "Usage: dcbdextract FILE\n";
}

my $user = getlogin();
my $pid = $$;
my $pwd;
my $file;
if($ARGV[0] =~ /[\/\\]/) {
	$pwd = $ARGV[0];
	$pwd =~ s/(.*)[\/\\][^\/\\]*$/\1/;
	$file = $ARGV[0];
	$file =~ s/.*[\/\\]([^\/\\]*)$/\1/;
} else {
	$pwd = `pwd`;
	$pwd =~ s/[\n\r\f]//g;
	$file = $ARGV[0];
}
my $tmp;
$tmp = "/tmp/$user-dcbdextract-$pid";

my $fileType = "csv";

my $csvfile = $tmp . "/" . $file;

if($ARGV[0] =~ /.txt$/) {
	system("mkdir $tmp; cp \"" . $ARGV[0] . "\" $tmp; cd $tmp; dctxt2csv \"" . $file . "\"");
	$csvfile .= ".csv";
	$fileType = "txt";
} else {
	system("mkdir $tmp; cp \"" . $ARGV[0] . "\" $tmp;");
}

open(CSV, $csvfile);

my $firstline = 1;
my $time;
my $idut;
my @bd;
my @leak;
my $csv = Text::CSV->new();
my %pulses;

while(<CSV>) {
	if($csv->parse($_)) {
		my @columns = $csv->fields();
		if($firstline == 1) {
			$firstline = 0;
			for(my $i = 0; $i < @columns; $i++) {
				if($columns[$i] eq "\@TIME" || $columns[$i] eq "Time") {
					$time = $i;
				}
				if($columns[$i] eq "I1" || $columns[$i] eq "GateI") {
					$idut = $i;
				}
			}
		} else {
			if($columns[$time] ne "") { #Guard for crappy Keithley output
				if(exists($pulses{$columns[$time]+0})) {
					$pulses{$columns[$time]+0}++;
					unshift(@bd, ($columns[$time]+0) . "-" . $pulses{$columns[$time]+0});
				} else {
					$pulses{$columns[$time]+0} = 0;
					unshift(@bd, $columns[$time]+0);
				}
				unshift(@leak, $columns[$idut]+0);
				if($leak[1] != 0 && $leak[0] / $leak[1] > 100) { #Two order of magnitude leakage change
					print $bd[1] . "\n";
					close(CSV);
					system("rm -rf $tmp");
					exit;
				}
			}
		}
	}
}
print "Possibly NaN: $bd[0]\n";
close(CSV);
system("rm -rf $tmp");
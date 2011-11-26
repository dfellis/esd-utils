#!/usr/bin/perl

#bdextract TLPFILE

use strict;
use Text::CSV;

if(@ARGV != 1) {
	die "Usage: bdextract TLPFILE\n";
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
$tmp = "/tmp/$user-bdextract-$pid";

system("mkdir $tmp; cp \"" . $ARGV[0] . "\" $tmp; cd $tmp; tlp2csv \"" . $file . "\"");

my $csvfile = $tmp . "/" . $file . ".csv";

open(CSV, $csvfile);

my $firstline = 1;
my $vpulse;
my $ileak;
my @bd;
my @leak;
my $csv = Text::CSV->new();
my $final = 0;
my %pulses;

while(<CSV>) {
	if($csv->parse($_)) {
		my @columns = $csv->fields();
		if($firstline == 1) {
			$firstline = 0;
			for(my $i = 0; $i < @columns; $i++) {
				if($columns[$i] eq "VPULSE") {
					$vpulse = $i;
				}
				if($columns[$i] eq "ILEAK") {
					$ileak = $i;
				}
			}
		} elsif($final == 1) {
			if(exists($pulses{$columns[$vpulse]+0})) {
				$pulses{$columns[$vpulse]+0}++;
				unshift(@bd, ($columns[$vpulse]+0) . "-" . $pulses{$columns[$vpulse]+0});
			} else {
				$pulses{$columns[$vpulse]+0} = 0;
				unshift(@bd, $columns[$vpulse]+0);
			}
			unshift(@leak, $columns[$ileak]);
			print $ARGV[0] . ": " . $bd[2] . "," . $bd[1] . "," . $bd[0] . "\n";
			close(CSV);
			system("rm -rf $tmp");
			exit;
		} else {
			if(exists($pulses{$columns[$vpulse]+0})) {
				$pulses{$columns[$vpulse]+0}++;
				unshift(@bd, ($columns[$vpulse]+0) . "-" . $pulses{$columns[$vpulse]+0});
			} else {
				$pulses{$columns[$vpulse]+0} = 0;
				unshift(@bd, $columns[$vpulse]+0);
			}
			unshift(@leak, $columns[$ileak]);
			if($leak[1] != 0 && $leak[0] / $leak[1] > 100) { #Two order of magnitude leakage change
				$final = 1;
			#} elsif($leak[0] > 1e-12) { #Absolute value for leakage current detection in these oxides
			#	$final = 1;
			}
		}
	}
}

close(CSV);

print "$ARGV[0]: 0,0,0\n";
system("rm -rf $tmp");

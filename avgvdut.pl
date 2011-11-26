#!/usr/bin/perl

#avgvdut TLPFILE

use strict;
use Text::CSV;

if(@ARGV != 1) {
	die "Usage: avgvdut TLPFILE\n";
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
$tmp = "/tmp/$user-avgvdut-$pid";

system("mkdir $tmp; cp \"" . $ARGV[0] . "\" $tmp; cd $tmp; tlp2csv \"" . $file . "\"");

my $csvfile = $tmp . "/" . $file . ".csv";

open(CSV, $csvfile);

my $firstline = 1;
my $vdut;
my $vdutavg = 0;
my $pulses = 0;
my $csv = Text::CSV->new();

while(<CSV>) {
	if($csv->parse($_)) {
		my @columns = $csv->fields();
		if($firstline == 1) {
			$firstline = 0;
			for(my $i = 0; $i < @columns; $i++) {
				if($columns[$i] eq "VDUT") {
					$vdut = $i;
				}
			}
		} else {
			$pulses++;
			$vdutavg += $columns[$vdut]+0;
		}
	}
}

$vdutavg /= $pulses;
print $vdutavg . "\n";

close(CSV);
system("rm -rf $tmp");

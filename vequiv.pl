#!/usr/bin/perl

#vequiv TWFFILE N TEFF

use strict;
use Text::CSV;

if(@ARGV != 3) {
	die "Usage: vequiv TWFFILE N TEFF\n";
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
$tmp = "/tmp/$user-vequiv-$pid";

system("mkdir $tmp; cp \"" . $ARGV[0] . "\" $tmp; cd $tmp; twf2csv \"" . $file . "\"");

my $csvfile = $tmp . "/" . $file . ".csv";

open(CSV, $csvfile);

my $firstline = 1;
my $csv = Text::CSV->new();
my $n = $ARGV[1];
my $teff = $ARGV[2];
my $vequiv = 0;
my $prevT = 0;
my $prevV = 0;

while(<CSV>) {
	if($csv->parse($_)) {
		my @columns = $csv->fields();
		if($firstline == 1) {
			$firstline = 0;
		} elsif($prevV == $columns[2]) {
			$vequiv = ($vequiv**$n + ($prevV**$n)*(($columns[0] - $prevT)/($teff)))**(1/$n);
		} else {
			$vequiv = ($vequiv**$n + (($columns[0] - $prevT) / ($teff*($n+1))) * (($columns[2]**($n+1) - $prevV**($n+1)) / ($columns[2] - $prevV)))**(1/$n);
		}
	}
}

close(CSV);
system("rm -rf $tmp");

print "$vequiv\n";
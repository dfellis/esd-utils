#!/usr/bin/perl

use strict;

if(@ARGV != 3) {
        print "Syntax: bodydrainbd [tb|n|b]= [tb|n|b]= [tb|n|b]=\n";
	die;
}

my $tb;
my $n;
my $b;

for(my $i = 0; $i < @ARGV; $i++) {
	if($ARGV[$i] =~ /^tb=(.*)/) {
		$tb = $1;
	} elsif($ARGV[$i] =~ /^n=(.*)/) {
		$n = $1;
	} elsif($ARGV[$i] =~ /^b=(.*)/) {
		$b = $1;
	}
}

print "" . ($tb*(($n*$b+1)**(1/$b))) . "\n";

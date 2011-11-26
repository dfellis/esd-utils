#!/usr/bin/perl

if(@ARGV != 5) {
	die "vstepsolver usage: vstepsolver step=[] stop=[] t=[] n=[] veff=[]\n";
}

my $step = "solve";
my $stop = "solve";
my $t = "solve";
my $n = "solve";
my $veff  = "solve";

for(my $i = 0; $i < @ARGV; $i++) {
	if($ARGV[$i] =~ /step=(.*)/i) {
		$step = $1 + 0;
	} elsif($ARGV[$i] =~ /stop=(.*)/i) {
		$stop = $1 + 0;
	} elsif($ARGV[$i] =~ /t=(.*)/i) {
		$t = $1 + 0;
	} elsif($ARGV[$i] =~ /n=(.*)/i) {
		$n = $1 + 0;
	} elsif($ARGV[$i] =~ /veff=(.*)/) {
		$veff = $1 + 0;
	}
}

my $answer = 0;

for(my $v = $step; $v <= $stop; $v += $step) {
	$answer += $t * ( ($veff / $v) ** (-$n) );
}

print "$answer\n";

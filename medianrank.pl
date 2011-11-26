#!/usr/bin/perl

#medianrank
#generates median rank values for a given failure set size

use strict;

if(@ARGV != 1) {
        print "Syntax: medianrank [SETSIZE]\n";
}

for(my $i = 1; $i <= $ARGV[0]; $i++) {
	print "" . (($i - 0.3)/($ARGV[0] + 0.4)) . "\n";
}

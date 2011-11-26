#!/usr/bin/perl

#simtlpextract PLTFILE p=var1 r=var2 w=var3 f=var4 avgs=var5 avge=var6

use strict;
use Text::CSV;
use Math::BigFloat;

if(@ARGV != 7) {
	die "Usage: simtlpextract PLTFILE p=var1 r=var2 w=var3 f=var4 avgs=var5 avge=var6\n";
}

my $period;
my $rise;
my $pwidth;
my $fall;
my $start;
my $end;

for(my $i = 1; $i < @ARGV; $i++) {
	if($ARGV[$i] =~ /[pP]=(.*)/) {
		$period = $1;
	} elsif($ARGV[$i] =~ /[rR]=(.*)/) {
		$rise = $1;
	} elsif($ARGV[$i] =~ /[wW]=(.*)/) {
		$pwidth = $1;
	} elsif($ARGV[$i] =~ /[fF]=(.*)/) {
		$fall = $1;
	} elsif($ARGV[$i] =~ /[aA][vV][gG][sS]=(.*)/) {
		$start = $1;
	} elsif($ARGV[$i] =~ /[aA][vV][gG][eE]=(.*)/) {
		$end = $1;
	} else {
		die "Usage: simtlpextract PLTFILE p=var1 r=var2 w=var3 f=var4 avgs=var5 avge=var6\n";
	}
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
$tmp = "/tmp/$user-simtlpextract-$pid";

system("mkdir $tmp; cp \"" . $ARGV[0] . "\" $tmp; cd $tmp; plt2csv \"" . $file . "\"");

my $csvfile = $tmp . "/" . $file . ".csv";

open(CSV, $csvfile);

my $firstline = 1;
my $csv = Text::CSV->new();
my @Time;
my $TimeLoc;
my @I;
my $ILoc;
my @V;
my $VLoc;
my @newI;
my @newV;

while(<CSV>) {
	if($csv->parse($_)) {
		my @columns = $csv->fields();
		if($firstline == 1) {
			$firstline = 0;
			for(my $i = 0; $i < @columns; $i++) {
				if($columns[$i] eq "time") {
					$TimeLoc = $i;
				}
				if($columns[$i] eq "drain TotalCurrent") {
					$ILoc = $i;
				}
				if($columns[$i] eq "drain InnerVoltage") {
					$VLoc = $i;
				}
			}
		} else {
			push(@Time, $columns[$TimeLoc]);
			push(@I, $columns[$ILoc]);
			push(@V, $columns[$VLoc]);
		}
	}
}

close(CSV);

sub avgArray {
	my @array = @_;
	if(@array == 0) {
		return(0);
	}
	my $val = Math::BigFloat->new;
	for(my $i = 0; $i < @array; $i++) {
		$val->badd($array[$i]);
	}
	$val->bdiv(@array . ".0");
	return($val);
}

for(my $i = 0; $i*$period < $Time[-1]; $i++) {
	my $starttime = $i*$period + $rise + $pwidth*$start;
	my $endtime = $i*$period + $rise + $pwidth*$end;
	my @avgV;
	my @avgI;
	my $belowStart = 0;
	my $belowIndex;
	my $aboveEnd = 1e99;
	my $aboveIndex;
	for(my $j = 0; $j < @Time; $j++) {
		if($Time[$j] < $starttime && $Time[$j] > $belowStart) {
			$belowStart = $Time[$j];
			$belowIndex = $j;
		} elsif($Time[$j] >= $starttime && $Time[$j] <= $endtime) {
			push(@avgV, $V[$j]);
			push(@avgI, $I[$j]);
		} elsif($Time[$j] > $endtime && $Time[$j] < $aboveEnd) {
			$aboveEnd = $Time[$j];
			$aboveIndex = $j;
		}
	}
	if(@avgV == 0) {
		@avgV = ($V[$belowIndex], $V[$aboveIndex]);
		@avgI = ($I[$belowIndex], $I[$aboveIndex]);
	}
	push(@newV, avgArray(@avgV));
	push(@newI, avgArray(@avgI));
}

print "I,V\n";
for(my $i = 0; $i < @newV; $i++) {
	print "$newI[$i],$newV[$i]\n";
}

system("rm -rf $tmp");

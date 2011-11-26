#!/usr/bin/perl

use Text::CSV;

$ARGC = @ARGV;
if($ARGC != 5) {
	die "tbdnorm2 usage: \ntbdnorm2 TWFFILE VPULSE TDEATH N VEFF\n";
}

my $infile = $ARGV[0];
my $vpulse = $ARGV[1]+0.0;
my $tdeath = $ARGV[2]+0.0;
my $n = $ARGV[3]+0.0;
my $n1 = $n + 1;
my $veff = $ARGV[4]+0.0;

my $user = getlogin();
my $pid = $PID;
my $pwd;
if($ARGV[0] =~ /\//) {
	$pwd = $ARGV[0];
	$pwd =~ s/(.*)\/[^\/]*$/\1/;
	$infile =~ s/.*\/([^\/]*)$/\1/;
} else {
	$pwd = `pwd`;
	$pwd =~ s/\n//g;
}
my $tmp = "/tmp/$user-tbdnorm2-$pid";

mkdir("$tmp");

system("cp \"$ARGV[0]\" $tmp");
system("cd $tmp; twf2csv \"$infile\"");

$infile .= ".csv";

my $csv = Text::CSV->new();
open(CSV, "$tmp/$infile") or die "Could not open file $tmp/$infile: $!";

my $teff = 0;
my $tinit = "NULL";
my $tau = "NULL";
my $counter = 2;
my @Vpulses;
my $maxi;
my @Vprev;
my @Vnow;
my $csv_line;
while(<CSV>) {
	if($csv->parse($_)) {
		my @columns = $csv->fields();
		if($tau ne "NULL") {
			#Normal Mode
			$counter++;
			@Vprev = @Vnow;
			@Vnow = ();
			for($i = 2; $i <= $maxi; $i++) {
				push(@Vnow, $columns[$i]+0);
			}
			for($i = 0; $i < @Vnow; $i++) {
				if($i != (@Vnow - 1) && ($tau * $counter) <= $tdeath) {
					if($Vnow[$i] == $Vprev[$i]) {
						$teff += $tau * ($veff / $Vnow[$i])**(-$n);
					} else {
						$teff += ($tau / $n1) * ($veff**(-$n)) * ((($Vnow[$i]**$n1) - ($Vprev[$i]**$n1)) / ($Vnow[$i] - $Vprev[$i]));
					}
				}
			}
		} elsif($tinit ne "NULL") {
			#First calculation
			$tau = $columns[0]-$tinit;
			@Vprev = @Vnow;
			@Vnow = ();
			for($i = 2; $i <= $maxi; $i++) {
				push(@Vnow, $columns[$i]+0);
			}
			for($i = 0; $i < @Vnow; $i++) {
				if($Vnow[$i] == $Vprev[$i]) {
					$teff += $tau * ($veff / $Vnow[$i])**(-$n);
				} else {
					$teff += ($tau / $n1) * ($veff**(-$n)) * ((($Vnow[$i]**$n1) - ($Vprev[$i]**$n1)) / ($Vnow[$i] - $Vprev[$i]));
				}
			}
		} elsif(@Vpulses > 0 && @Vnow <= 0) {
			#First data point
			$tinit = $columns[0]+0;
			for($i = 2; $i <= $maxi; $i++) {
				push(@Vnow, $columns[$i]+0);
			}
		} else {
			#Header loading
			for($i = 0; $i < @columns; $i++) {
				if($columns[$i] =~ m/^V([0-9.]*)V/ && ($1 + 0) <= $vpulse) {
					push(@Vpulses, $columns[$i]);
					$maxi = $i;
				}
			}
		}
	}
}

close CSV;

print "$teff\n";
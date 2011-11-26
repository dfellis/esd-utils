#!/usr/bin/perl

#bdextract2 /path/to/TLPANDTWFFILES (no ext)

use strict;
use Text::CSV;
use Math::Trig;


#Check if called properly
if(@ARGV != 1) {
	die "Usage: bdextract2 /path/to/TLPANDTWFFILES (no ext)\n";
}

#Init script
my $user = getlogin();
my $pid = $$;
my $pwd;
my $file;

#Determine PWD
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

#Create tmp directory, copy, and convert files
my $tmp;
$tmp = "/tmp/$user-bdextract2-$pid";

system("mkdir $tmp; cp \"" . $ARGV[0] . ".tlp\" $tmp; cd $tmp; tlp2csv \"" . $file . ".tlp\"");
system("cp \"" . $ARGV[0] . ".twf\" $tmp; cd $tmp; twf2csv \"" . $file . ".twf\"");

my $csvtlpfile = $tmp . "/" . $file . ".tlp.csv";
my $csvtwffile = $tmp . "/" . $file . ".twf.csv";

#Analyze TLP file, first
open(CSV, $csvtlpfile);

my $firstline = 1;
my %locations;
my %data;
my $csv = Text::CSV->new();

while(<CSV>) {
	if($csv->parse($_)) {
		my @columns = $csv->fields();
		if($firstline == 1) { #Initialize column storage
			$firstline = 0;
			for(my $i = 0; $i < @columns; $i++) {
				$locations{$i} = $columns[$i];
			}
			$data{PulseV} = [];
			$data{VDUT} = [];
			$data{IDUT} = [];
			$data{ILEAK} = [];
			$data{VDUTdiff} = [];
			$data{IDUTdiff} = [];
			$data{DUTdiffFactor} = [];
			$data{ILEAKdiff} = [];
			$data{FailFactor} = [];
		} else {
			for(my $i = 0; $i < @columns; $i++) { #Load data
				push(@{$data{$locations{$i}}}, $columns[$i]);
			}
			#Perform diff calculations
			if(@{$data{VDUT}} eq 1) { #First set of data, nothing to diff
				push(@{$data{VDUTdiff}}, 0);
				push(@{$data{IDUTdiff}}, 0);
				push(@{$data{DUTdiffFactor}}, 0);
				push(@{$data{ILEAKdiff}}, 0);
			} else { #At least two rows of data
				push(@{$data{VDUTdiff}}, (${$data{VDUT}}[-1] - ${$data{VDUT}}[-2]));
				push(@{$data{IDUTdiff}}, (${$data{IDUT}}[-1] - ${$data{IDUT}}[-2]));
				push(@{$data{DUTdiffFactor}}, (abs(${$data{VDUTdiff}}[-1]*${$data{IDUTdiff}}[-1]) * cos(atan2(${$data{IDUTdiff}}[-1],${$data{VDUTdiff}}[-1])-(3 * pi / 4))));
				#DUTdiffFactor is an algorithm to emphasize VDUT & IDUT diffs that are the signature of failing into a short (positive) or open (negative) and de-emphasize before and after failure data
				push(@{$data{ILEAKdiff}}, (${$data{ILEAK}}[-1] - ${$data{ILEAK}}[-2]));
			}
		}
	}
}
close(CSV);

#Oxides can fail into either a short (conductive), or a temporary short followed by complete blowout (open). This temporary short may or may not be recorded. Therefore, failure is seen when either leakage current increases AND DUT current increases AND DUT voltage decreases (details, later), OR leakage current decreases AND  DUT current decreases AND DUT voltage increases.

#However, since the VDUT and IDUT window is only part of the oxide, and its possible for the leakage stress to do damage, the leakage current increase or decrease may occur on either the pulse before or the pulse during the recorded changes to VDUT and IDUT.

#Therefore, the final factor for comparing pulses and determining likely failure points is to multiply that pulse's DUTdiffFactor by (ILEAKdiff + ILEAKdiffNext), where ILEAKdiffNext is the next pulse's ILEAKdiff (since we're trying to find the pulse prior to a measureable delta in VDUT or IDUT shifting.

#This final factor conflates both breakdown modes as large positive values, and an array of VPULSE values sorted by this factor from largest to 0 (all negative numbers, if any, cut out), provides a listing of breakdown pulses ranked from most likely to least likely.

#Later code will test these versus the recorded waveform and eliminate pulses that don't match an expected "signature" (based on the three pulses surrounding the expected failure pulse). The highest probability pulse that matches the expected signature will be selected as the breakdown pulse, and the time within that pulse where failure occurs (or -1 if not determinable) will be reported along with the PulseV.

my %factorToPulse; #Hash that will be used to get pulse values sorted by their FailFactor
my $noiseFloor = 1e-15; #Noise floor of leakage current measurements on Barth TLP system

for(my $i = 0; $i < @{$data{DUTdiffFactor}}-1; $i++) {
	my $dutFactor = ${$data{DUTdiffFactor}}[$i];
	my $leakDiff = ${$data{ILEAKdiff}}[$i];
	my $leakNextDiff = ${$data{ILEAKdiff}}[$i+1];
	push(@{$data{FailFactor}}, ($dutFactor * ($leakDiff + $leakNextDiff)));
	if(${$data{FailFactor}}[-1] > $noiseFloor) {
		$factorToPulse{${$data{FailFactor}}[$i]} = ${$data{PulseV}}[$i] . '_' . $i;
	}
	#print "${$data{PulseV}}[$i] $dutFactor $leakDiff $leakNextDiff ${$data{FailFactor}}[$i]\n";
}

my @pulsesByProbability; #Final array of pulses in their probabilistic order
foreach my $key (sort {$b <=> $a} keys(%factorToPulse)) {
	#print "$key $factorToPulse{$key}\n";
	push(@pulsesByProbability, $factorToPulse{$key});
}

#For now, before I go any further, let's just see the list
print "$ARGV[0]: @pulsesByProbability\n";


system("rm -rf $tmp");
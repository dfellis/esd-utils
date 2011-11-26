#!/usr/bin/perl

#getVpVth [leadFileFragment]

use strict;
use Text::CSV;

if(@ARGV != 1) {
	die "Usage: getVpVth [leadFileFragment]\nFiles must be of the form: [leadFileFragment]_[Vpulse]V_vgs-id.xls.csv\n";
}

my @files = `ls $ARGV[0]_*_vgs-id.xls.csv`;

my %outData;

#open(VpVth, ">$ARGV[0]_VpVth.csv");

#print VpVth "Vp,Vth\n";

foreach my $file (@files) {
	$file =~ /^$ARGV[0]_(.*)_vgs-id.xls.csv$/;
	my $vpulse = $1;
	if($vpulse eq "fresh") {
		$vpulse = 0;
	} else {
		$vpulse =~ s/V//;
	}
	
	my $csv = Text::CSV->new();
	open(getVth, "<$file");
	my $line = <getVth>;
	$line =~ s/#//g;
	$csv->parse($line);
	my @columns = $csv->fields();
	my $vtcol;
	for(my $i = 0; $i < @columns; $i++) {
		if($columns[$i] eq "VT") {
			$vtcol = $i;
		}
	}
	$line = <getVth>;
	$line =~ s/#//g;
	$csv->parse($line);
	@columns = $csv->fields();
	my $vt = $columns[$vtcol];
	close(getVth);
	#print VpVth "$vpulse,$vt\n";
	$outData{$vpulse} = $vt;
}

#close(VpVth);

open(VpVth, ">$ARGV[0]_VpVth.csv");
print VpVth "Vp,Vth\n";
foreach my $key (sort {$a <=> $b} keys %outData) {
	print VpVth $key . "," . $outData{$key} . "\n";
}
close(VpVth);
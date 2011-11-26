#!/usr/bin/perl

#getVpVth [leadFileFragment]

use strict;
use Text::CSV;

if(@ARGV != 1) {
	die "Usage: getVpI22 [leadFileFragment]\nFiles must be of the form: [leadFileFragment]_[Vpulse]V_vds-id.xls.csv\n";
}

my @files = `ls $ARGV[0]_*_vds-id.xls.csv`;

my %outData;

foreach my $file (@files) {
	$file =~ /^$ARGV[0]_(.*)_vds-id.xls.csv$/;
	my $vpulse = $1;
	if($vpulse eq "fresh") {
		$vpulse = 0;
	} else {
		$vpulse =~ s/V//;
	}
	
	my $csv = Text::CSV->new();
	open(getI22, "<$file");
	my $line = <getI22>;
	$line =~ s/#//g;
	$csv->parse($line);
	my @columns = $csv->fields();
	my $i22col;
	for(my $i = 0; $i < @columns; $i++) {
		if($columns[$i] eq "DrainI(5)") {
			$i22col = $i;
		}
	}
	my $i22;
	while(<getI22>) {
		$line = $_;
		$line =~ s/#//g;
		$csv->parse($line);
		@columns = $csv->fields();
		if($columns[$i22col] ne "") {
			$i22 = $columns[$i22col];
		}
	}
	close(getI22);
	$outData{$vpulse} = $i22;
}

open(VpI22, ">$ARGV[0]_VpI22.csv");
print VpI22 "Vp,I22\n";
foreach my $key (sort {$a <=> $b} keys %outData) {
	print VpI22 $key . "," . $outData{$key} . "\n";
}
close(VpI22);
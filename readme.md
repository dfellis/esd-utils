# ESD Utilities

A set of utilities written during the course of my PhD. Perhaps someone will find them useful.

## absqbdsum
extracts the absolute charge-to-breakdown from a CSV file (probably converted via [tlp2csv](https://github.com/dfellis/2csv)).

``
Usage:
absqbdsum CSVFILE AOX VPULSE TPULSE
``

## avgvdut
simple script that extracts the average VDUT from a Barth ``.tlp`` file (assumes [tlp2csv])https://github.com/dfellis/2csv) is in the path).

## bdextract & bdextract2
The first ``bdextract`` was used successfully on larger processes (0.35µm and 0.18µm) for determining the pulse to induce gate oxide breakdown under vfTLP-level stress. ``bdextract2`` was begun for very thin oxides where the breakdown level is closer to the noise floor of the vfTLP equipment, but was abandoned because I couldn't think of an algorithm that would work.

## bdextract_keithley
Extracts time-to-breakdown for constant voltage stress type measurements done with a Keithley 4200 SCS. Needs [xls2csv3](https://github.com/dfellis/2csv)

## bodydrainbd
Simple converter utility that translates the time-to-breakdown of a body-gate constant voltage stress into a drain-gate constant voltage stress, given said time-to-breakdown, the extracted Power Law constant ``n``, and the extract Weibull shape parameter ``beta``, assuming negligible fringe effects from the drain-gate overlap.

## csv2st
converts csv files (possibly converted with one of my [2csv](https://github.com/dfellis/2csv) converters) containing voltage and/or current versus time data into formats usable by the Sentaurus suite of simulation tools.

``
Usage:
csv2st [pwli|pwlv|tlpi|tlpv] filename.csv > filename.st
``

The i and v indicate current and voltage versus time, respectively, and the pwl and tlp indicate which output format to use.

## csvmax
Prints the row (or rows surrounding the row) where the maximum value of a particular column resides.

## dcbdextract
Extracts time-to-breakdown for constant voltage stress measurements done with an HP 4156. Needs [dctxt2csv](https://github.com/dfellis/2csv).

## getVpI22 & getVpVth
Extracts the I22 and Vth values from a series of Keithley 4200 measurements performed after each specified TLP pulse voltage (to produce damage indicators in a similar vein to the standard leakage current measurement.

## medianrank
Simple utility to calculate the median ranking used for Weibull analysis of raw data.

## normtime
A tool that takes several sets of CSV data (merged into one file) and mangles the 'time' column so it is continuously increasing -- assuming any decrease from one row to the next represents a reset in the counter. Good for merging very-long-running Keithley 4200 constant voltage stress measurements that wouldn't fit in a single file.

## pwrsolver
A tool that can solve the transformative version of the Power Law for any one of its 5 variables.

## qbdsum
extracts the charge-to-breakdown from a CSV file (negative current will induce a reduce the sum).

## simtlpextract
a tool that generates a TLP-like CSV file from a TLP-like SPICE simulation.

## tbdnorm & tbdnorm2
take data from Barth ``.tlp`` or ``.twf`` files and calculates the equivalent constant voltage time-to-breakdown using the [Transient Power Law](http://dx.doi.org/10.1109/TED.2010.2053864)

## twf2tlp
a tool that takes Barth ``.twf`` files and performs one of several extraction operations per pulse (beyond the standard averaging window) to produce ``.tlp``-like file. In this case, the files are not ``.csv``, but are as similar as possible to the ``.tlp`` format.

## twfmanip
a similar tool that generates ``.csv`` files from Barth ``.twf`` files. In this case, focused more on extracting Power and Energy versus the stress pulse voltage.

## vdeath
extracts the actual voltage during the pulse that induces gate oxide breakdown from a Barth ``.twf`` file.

## vdutvpulse
extract the average ratio between the ``.tlp`` VDUT and VPULSE voltages just prior to gate oxide breakdown. Useful for determining the pulse voltage to apply to get a desired DUT voltage (to see if your breakdown predictions work :).

## vequiv
extracts the equivalent constant voltage stress voltage to the gate oxide breakdown measured in a Barth ``.twf`` file, assuming the [Transient Power Law](http://dx.doi.org/10.1109/TED.2010.2053864).

## vstepsolver
converts a Ramped Voltage Stress to a Constant Voltage Stress or vice versa, assuming the [Transient Power Law](http://dx.doi.org/10.1109/TED.2010.2053864).

# License (MIT)

Copyright (C) 2008-2011 by David Ellis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

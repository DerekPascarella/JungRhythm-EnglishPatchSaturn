#!/usr/bin/perl
#
# jung_to_bmp.pl
# Bitmap to raw graphics converter for the SEGA Saturn game "Jung Rhythm".
#
# Written by Derek Pascarella (ateam)

# Include necessary modules.
use strict;

# Store input parameters.
my $infile = $ARGV[0];
my $width = $ARGV[1];
my $height = $ARGV[2];

# Ensure proper input parameters.
if($infile eq "" || $width eq "" || $height eq "")
{
	die "\nOne or more input parameters missing...\n\nUsage:\nbmp_to_jung <BITMAP_FILE> <WIDTH> <HEIGHT>\n\n";
}
elsif(!-e $infile || !-R $infile)
{
	die "\nCould not find or read $infile...\n\nUsage:\nbmp_to_jung <BITMAP_FILE> <WIDTH> <HEIGHT>\n\n";
}
elsif($width eq "" || $height eq "" || $width !~ /^[+-]?\d+$/ || $height !~ /^[+-]?\d+$/)
{
	die "\nWidth and height parameters must be whole numbers...\n\nUsage:\nbmp_to_jung <BITMAP_FILE> <WIDTH> <HEIGHT>\n\n";
}

# Construct output filename.
(my $outfile = $infile) =~ s/\.BMP//gi;

# Status message.
print "\nConverting $infile to $outfile...\n\n";

# Open input and output files.
open(my $in, '<:raw', $infile) or die "Can't open $infile: $!";
open(my $out, '>:raw', $outfile) or die "Can't open $outfile: $!";

# Skip the 54-byte bitmap header.
seek($in, 54, 0);

# Calculate padding for each row.
my $padding = ($width * 3) % 4;
$padding = (4 - $padding) % 4;
my $row_size = $width * 3 + $padding;

# Read the entire bitmap into memory.
read($in, my $bmp_data, $row_size * $height);

for my $y (0 .. $height-1)
{
	for my $x (0 .. $width-1)
	{
		my $row_start = ($height - 1 - $y) * $row_size;
		my $pos = $row_start + $x * 3;

		# Extract RGB colors from bitmap directly.
		my ($r, $g, $b) = unpack("CCC", substr($bmp_data, $pos, 3));

		my $value;

		if($r == 255 && $g == 0 && $b == 255)
		{
			# Handle transparency.
			$value = 0;
		}
		else
		{
			# Scale down from 8 bits to 5 bits per channel.
			$r >>= 3;
			$g >>= 3;
			$b >>= 3;

			# Combine into a 15-bit value and ensure the MSB is set for non-transparent pixels.
			$value = 0x8000 | ($r << 10) | ($g << 5) | $b;
		}

		# Write the value in big-endian format.
		print $out pack("n", $value);
	}
}

# Close input and output files.
close($in);
close($out);

# Status message.
print "Complete!\n\n";
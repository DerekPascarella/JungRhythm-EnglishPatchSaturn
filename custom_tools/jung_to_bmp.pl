#!/usr/bin/perl
#
# jung_to_bmp.pl
# Raw graphics to bitmap converter for the SEGA Saturn game "Jung Rhythm".
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
	die "\nOne or more input parameters missing...\n\nUsage:\njung_to_bmp <RAW_GRAPHICS_FILE> <WIDTH> <HEIGHT>\n\n";
}
elsif(!-e $infile || !-R $infile)
{
	die "\nCould not find or read $infile...\n\nUsage:\njung_to_bmp <RAW_GRAPHICS_FILE> <WIDTH> <HEIGHT>\n\n";
}
elsif($width eq "" || $height eq "" || $width !~ /^[+-]?\d+$/ || $height !~ /^[+-]?\d+$/)
{
	die "\nWidth and height parameters must be whole numbers...\n\nUsage:\njung_to_bmp <RAW_GRAPHICS_FILE> <WIDTH> <HEIGHT>\n\n";
}

# Construct output filename.
my $outfile = $infile . ".BMP";

# Status message.
print "\nConverting $infile to $outfile...\n\n";

# Open input and output files.
open(my $in, '<:raw', $infile) or die "Can't open $infile: $!";
open(my $out, '>:raw', $outfile) or die "Can't open $outfile: $!";

# Construct the BMP header (14 bytes) and DIB header (40 bytes) for 24-bit bitmap image.
my $file_header = "BM" . pack("V", 14 + 40 + $width * $height * 3) . pack("V", 0) . pack("V", 14 + 40);
my $dib_header = pack("V", 40) . pack("V", $width) . pack("V", $height) . pack("v", 1) .
				 pack("v", 24) . pack("V", 0) . pack("V", $width * $height * 3) .
				 pack("V", 0) . pack("V", 0) . pack("V", 0) . pack("V", 0);

# Write header data to file.
print $out $file_header;
print $out $dib_header;

# Read in and convert all pixel data.
my @rows;

for my $y (1..$height)
{
	my $row = '';

	for my $x (1..$width)
	{
		# Read 2 bytes per pixel.
		my $raw_pixel;
		read($in, $raw_pixel, 2);
		
		# Convert from big-endian.
		my $value = unpack("n", $raw_pixel);

		# Check for transparency.
		my $is_transparent = !($value & 0x8000);

		my $r = ($value >> 10) & 0x1F;
		my $g = ($value >> 5) & 0x1F;
		my $b = $value & 0x1F;
		
		if($is_transparent)
		{
			# Set to 255 without bit-shifting for full magenta to represent transparent pixels.
			$r = 255;
			$g = 0;
			$b = 255;
		}
		else
		{
			# Extract and scale RGB values if not transparent.
			$r = ($value >> 10) & 0x1F;
			$g = ($value >> 5) & 0x1F;
			$b = $value & 0x1F;

			# Scale up to 8 bits per channel.
			$r = ($r << 3) | ($r >> 2);
			$g = ($g << 3) | ($g >> 2);
			$b = ($b << 3) | ($b >> 2);
		}

		$row .= pack("CCC", $r, $g, $b);
	}

	# Push data to array.
	push @rows, $row;
}

# Write pixel data in reverse order.
for my $row (reverse @rows)
{
	print $out $row;
}

# Close input and output files.
close($in);
close($out);

# Status message.
print "Complete!\n\n";
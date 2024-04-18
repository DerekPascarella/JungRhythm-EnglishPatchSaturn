#!/usr/bin/perl
#
# extract_other_text.pl
# Other text extractor for the SEGA Saturn game "Jung Rhythm".
#
# Written by Derek Pascarella (ateam)

# Include necessary modules.
use strict;
use utf8;
use Spreadsheet::WriteExcel;
use Encode qw(decode encode);

# Set STDOUT encoding to UTF-8.
binmode(STDOUT, "encoding(UTF-8)");

# Store array of files containing in-game text.
my @input_files = ("0KERNEL.BIN", "REN.BIN;");

# Store input/output paths.
my $input_folder = "/mnt/z/saturn/__projects/jung/disc_image_original_extracted/";
my $output_folder = "/mnt/z/saturn/__projects/jung/custom_tools/xls/";

# Store offsets for each string in "0KERNEL.BIN" into an array.
my @kernel = (
    3248, 12632, 12664, 12696, 12736, 12772, 12812, 12832, 12852, 12892,
    12928, 12964, 13008, 13048, 13060, 13104, 13148, 13196, 13232, 13276,
    13312, 13336, 13380, 13424, 14404, 14692, 14728, 14764, 14792, 14832,
    15012, 15048, 15196, 15216, 15244, 17444, 17472, 17488, 17520, 17556,
    17572, 17588, 17608, 18644, 18664, 18676, 18696, 18712, 18732, 18752
);

# Store offets for each string in "REN.BIN;" into an array.
my @ren = (
    40, 68, 1072, 1096, 1128, 1160, 1196, 1216, 2096, 2112, 2124, 2136,
    2368, 2384, 2412, 2440, 2472, 2500, 2520, 2544
);

# Iterate through each input file.
foreach(@input_files)
{
	# Store full path to current file, as well as its contents.
	my $file_path = $input_folder . $_;
	my $file_data = &read_bytes($file_path);

	# Declare spreadsheet data hash.
	my %spreadsheet_data;

	# Copy corresponding array of offsets and set base address.
	my @offsets;
	my $base_address;

	if($_ eq "0KERNEL.BIN")
	{
		@offsets = @kernel;
		$base_address = 100679680;
	}
	else
	{
		@offsets = @ren;
		$base_address = 100925440;
	}

	# Status message.
	print "\n[ $_ ]\n";

	# Iterate through each offset.
	for(my $i = 0; $i < scalar(@offsets); $i ++)
	{
		# Set initial seek offset.
		my $seek_location = $offsets[$i] * 2;

		# Declare empty text byte array string to be appended.
		my $text_bytes;

		# Seek until null terminator (0x00) is found.
		while(substr($file_data, $seek_location, 2) ne "00")
		{
			# Append current byte.
			$text_bytes .= substr($file_data, $seek_location, 2);

			# Increase seek position by one byte.
			$seek_location += 2;
		}

		# Calculate offset address in Saturn's RAM.
		my $offset_saturn = $offsets[$i] + $base_address;

		# Status message.
		print "\nFile offset: $offsets[$i] (0x" . &decimal_to_hex($offsets[$i], 4) . ")\n";
		print "Saturn offset: $offset_saturn (0x" . &decimal_to_hex($offset_saturn, 4) . ")\n";
		print "Text: " . Encode::decode("shiftjis", pack "H*", $text_bytes) . "\n";

		$spreadsheet_data{$offsets[$i]}{'Type'} = "Text";
		$spreadsheet_data{$offsets[$i]}{'Pointer'} = &decimal_to_hex($offset_saturn, 4);
		$spreadsheet_data{$offsets[$i]}{'Japanese Text'} = Encode::decode("shiftjis", pack "H*", $text_bytes);
	}

	# Status message.
	print "\nWriting spreadsheet...\n";

	# Write spreadsheet.
	&write_spreadsheet($_, \%spreadsheet_data);

	# Statue message.
	print "Done!\n";
}




# Subroutine to read a specified number of bytes (starting at the beginning) of a specified file,
# returning hexadecimal representation of data.
#
# 1st parameter - Full path of file to read.
# 2nd parameter - Number of bytes to read (omit parameter to read entire file).
sub read_bytes
{
	my $input_file = $_[0];
	my $byte_count = $_[1];

	if($byte_count eq "")
	{
		$byte_count = (stat $input_file)[7];
	}

	open my $filehandle, '<:raw', $input_file or die $!;
	read $filehandle, my $bytes, $byte_count;
	close $filehandle;
	
	return unpack 'H*', $bytes;
}

# Subroutine to return hexadecimal representation of a decimal number.
#
# 1st parameter - Decimal number.
# 2nd parameter - Number of bytes with which to represent hexadecimal number (omit parameter for no
#                 padding).
sub decimal_to_hex
{
	if($_[1] eq "")
	{
		$_[1] = 0;
	}

	return sprintf("%0" . $_[1] * 2 . "X", $_[0]);
}

# Subroutine to write spreadsheet.
sub write_spreadsheet
{
	my $filename = $_[0];
	my %spreadsheet_data = %{$_[1]};

	my $workbook = Spreadsheet::WriteExcel->new($output_folder . "/" . $filename . ".xls");
	my $worksheet = $workbook->add_worksheet();
	my $header_bg_color = $workbook->set_custom_color(40, 191, 191, 191);

	my $header_format = $workbook->add_format();
	$header_format->set_bold();
	$header_format->set_border();
	$header_format->set_bg_color(40);

	my $cell_format = $workbook->add_format();
	$cell_format->set_border();
	$cell_format->set_align('left');
	$cell_format->set_text_wrap();

	$worksheet->set_column('A:A', 9);
	$worksheet->set_column('B:B', 9);
	$worksheet->set_column('C:C', 45);
	$worksheet->set_column('D:D', 45);
	$worksheet->set_column('E:E', 40);

	$worksheet->write(0, 0, "Pointer", $header_format);
	$worksheet->write(0, 1, "Type", $header_format);
	$worksheet->write(0, 2, "Japanese Text", $header_format);
	$worksheet->write(0, 3, "English Translation", $header_format);
	$worksheet->write(0, 4, "Notes", $header_format);

	my $row_count = 1;

	foreach my $string_number (sort {$a <=> $b} keys %spreadsheet_data)
	{
		$worksheet->write($row_count, 0, "'" . $spreadsheet_data{$string_number}{'Pointer'}, $cell_format);
		$worksheet->write($row_count, 1, $spreadsheet_data{$string_number}{'Type'}, $cell_format);
		$worksheet->write_utf16be_string($row_count, 2, Encode::encode("utf-16", $spreadsheet_data{$string_number}{'Japanese Text'}), $cell_format);
		$worksheet->write($row_count, 3, "", $cell_format);
		$worksheet->write($row_count, 4, "", $cell_format);

		$row_count ++;
	}

	$workbook->close();
}
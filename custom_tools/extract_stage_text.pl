#!/usr/bin/perl
#
# extract_stage_text.pl
# Stage text extractor for the SEGA Saturn game "Jung Rhythm".
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
my @input_files = ("STG1.BIN;", "STG2.BIN;", "STG3.BIN;", "STG4.BIN;",
                   "STG5.BIN;", "STG6A.BIN;", "STG6B.BIN;");

# Store input/output paths.
my $input_folder = "/mnt/z/saturn/__projects/jung/disc_image_original_extracted/";
my $output_folder = "/mnt/z/saturn/__projects/jung/custom_tools/xls/";

# Iterate through each input file.
foreach(@input_files)
{
	# Store length of current file's text chunk at 0x16 (decimal 22).
	my $chunk_length = hex(&read_bytes_at_offset($input_folder . $_, 2, 22));

	# Store hex representation of all text chunk data into flat string starting at 0x18 (decimal 24).
	my $byte_string = &read_bytes_at_offset($input_folder . $_, $chunk_length, 24);

	# Create byte array from flat string.
	my @byte_array = ($byte_string =~ m/../g);

	# Status message.
	print "\n[ $_ ]\n";
	print "$chunk_length bytes according to header.\n";
	print scalar(@byte_array) . " bytes read.\n";

	# Initialize empty string for storing flat string of bytes containing individual text chunk.
	my $text_bytes = "";

	# Initialize string counter to one.
	my $string_number = 1;

	# Declare spreadsheet data hash.
	my %spreadsheet_data;

	# Initialize rolling offset to start at 0x18 (decimal 24).
	my $rolling_offset = 24;

	# Initialize flag to zero by deefault (false).
	my $ram_found = 0;

	# Iterate through each byte in array in order to store separate text chunks.
	for(my $i = 0; $i < scalar(@byte_array); $i ++)
	{
		# Current byte is not null terminator, append it.
		if($byte_array[$i] ne "00")
		{
			$text_bytes .= $byte_array[$i];
		}
		# Current byte is null terminator, store collected chunk.
		else
		{
			# Ensure collected chunk isn't empty (i.e., after iterating over null terminators).
			if($text_bytes ne "")
			{
				# Chunk represents a filename (.BIN or .PCM).
				if($text_bytes =~ /2e50434d/ || $text_bytes =~ /2e42494e/)
				{
					$spreadsheet_data{$string_number}{'Type'} = "Filename";
				}
				# Chunk represents Japanese text.
				else
				{
					$spreadsheet_data{$string_number}{'Type'} = "Text";
				}

				# Store original location of chunk in pointer format (base address 0x06040000 + rolling offset - length of chunk).
				$spreadsheet_data{$string_number}{'Pointer'} = &decimal_to_hex(100925440 + $rolling_offset - (length($text_bytes) / 2), 4);

				# Convert newline control code.
				$text_bytes =~ s/4040/0D0A/gi;

				# Store Shift-JIS text into hash key.
				$spreadsheet_data{$string_number}{'Japanese Text'} = Encode::decode("shiftjis", pack "H*", $text_bytes);

				# Increase string counter by one.
				$string_number ++;

				# Reset empty string.
				$text_bytes = "";
			}
			# If last five bytes are null terminators, add entry for data used in RAM.
			elsif($byte_array[$i] eq "00" && $byte_array[$i-1] eq "00" && $byte_array[$i-2] eq "00" &&
                  $byte_array[$i-3] eq "00" && $byte_array[$i-4] eq "00" && $ram_found == 0)
			{
				# Set flag to one (true).
				$ram_found = 1;

				# Calculate RAM pointer.
				my $ram_pointer = $i + 100925440 + 24;

				while($ram_pointer % 4 != 0)
				{
					$ram_pointer --;
				}

				$spreadsheet_data{$string_number}{'Type'} = "RAM";
				$spreadsheet_data{$string_number}{'Japanese Text'} = "N/A";
				$spreadsheet_data{$string_number}{'Pointer'} = &decimal_to_hex($ram_pointer, 4);

				# Increase string counter by one.
				$string_number ++;
			}
		}

		# Increase rolling offset by one byte.
		$rolling_offset ++;
	}

	# Status message.
	print ($string_number - 1);
	print " strings found.\n";
	print "Writing spreadsheet...\n";

	# Write spreadsheet.
	&write_spreadsheet($_, \%spreadsheet_data);

	# Status message.
	print "Done!\n";
}

# Status message.
print "\n" . scalar(@input_files) . " files processed.\n\n";




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

# Subroutine to read a specified number of bytes, starting at a specific offset (in decimal format), of
# a specified file, returning hexadecimal representation of data.
#
# 1st parameter - Full path of file to read.
# 2nd parameter - Number of bytes to read.
# 3rd parameter - Offset at which to read.
sub read_bytes_at_offset
{
	my $input_file = $_[0];
	my $byte_count = $_[1];
	my $read_offset = $_[2];

	if((stat $input_file)[7] < $read_offset + $byte_count)
	{
		die "Offset for read_bytes_at_offset is outside of valid range.\n";
	}

	open my $filehandle, '<:raw', $input_file or die $!;
	seek $filehandle, $read_offset, 0;
	read $filehandle, my $bytes, $byte_count;
	close $filehandle;
	
	return unpack 'H*', $bytes;
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
		
		if($spreadsheet_data{$string_number}{'Type'} eq "Filename")
		{
			$worksheet->write($row_count, 3, $spreadsheet_data{$string_number}{'Japanese Text'}, $cell_format);
		}
		elsif($spreadsheet_data{$string_number}{'Type'} eq "RAM")
		{
			$worksheet->write($row_count, 3, "N/A", $cell_format);
		}
		else
		{
			$worksheet->write($row_count, 3, "", $cell_format);
		}
		

		$worksheet->write($row_count, 4, "", $cell_format);

		$row_count ++;
	}

	$workbook->close();
}
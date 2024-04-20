#!/usr/bin/perl
#
# insert_all_text.pl
# Text inserter for the SEGA Saturn game "Jung Rhythm".
#
# Written by Derek Pascarella (ateam)

# Include necessary modules.
use utf8;
use strict;
use HTML::Entities;
use String::HexConvert ":all";
use Spreadsheet::ParseXLSX;
use Spreadsheet::Read "ReadData";
use experimental 'smartmatch';

# Set STDOUT encoding to UTF-8.
binmode(STDOUT, "encoding(UTF-8)");

# Define input/output paths.
my $spreadsheet_folder = "xlsx_translated/";
my $game_data_folder = "../disc_image_patched_extracted/";
my $game_data_folder_original = "../disc_image_original_extracted/";

# Generate custom single-byte encoding character map hash.
my %character_map = &generate_character_map_hash("character_table.txt");

# Declare empty hash for storing overflow text data.
my %overflow_map;

# Define text data overflow location and allotted space.
my $overflow_location = 124288;
my $overflow_size = 13040;

# Define base addresses for Saturn RAM (0x06004000 and 0x06040000, respectively).
my $base_address_main = 100679680;
my $base_address_alt = 100925440;

# Initialize global overflow, string, and pointer counters to zero.
my $overflow_count = 0;
my $string_count = 0;
my $pointer_count = 0;
my $pointer_missing_count = 0;

# Delete existing warning log.
unlink("warning.log");

# Store list of translated spreadsheets into array.
opendir(DIR, $spreadsheet_folder);
my @spreadsheets = grep !/^\.\.?$/, readdir(DIR);
closedir(DIR);

# Define hash containg map of all offsets to which text data can be written, along with the maximum
# number of bytes that can be stored there.
my %space_map = (
			'0KERNEL.BIN' => {
						12632 => 824,
						14404 => 32,
						14692 => 172,
						15012 => 52,
						15196 => 68,
						17444 => 204,
						18644 => 132
					 },
			'REN.BIN;' =>	{
						40    => 60,
						1072  => 168,
						2096  => 52,
						2368  => 204
					 },
			'STG1.BIN;' =>   {
						24    => 1336
					 },
			'STG2.BIN;' =>   {
						24    => 812
					 },
			'STG3.BIN;' =>   {
						24    => 760
					 },
			'STG4.BIN;' =>   {
						24    => 604
					 },
			'STG5.BIN;' =>   {
						24    => 1704
					 },
			'STG6A.BIN;' =>  {
						24    => 724
					 },
			'STG6B.BIN;' =>  {
						24    => 972
					 }
		);

# Status message.
print "\n[PRELIMINARY NULL BYTE PATCHING]\n";

# Iterate through the space map hash to patch all existing text data with null bytes (0x00)
# in preparation for text insertion.
for my $file (sort {$a <=> $b} keys %space_map)
{
	# Status message.
	print " -> $file\n";

	# Iterate through each location and size.
	for my $location (sort {$a <=> $b} keys %{$space_map{$file}})
	{
		# Store writable size of current location.
		my $size = $space_map{$file}->{$location};

		# Status message.
		print "	location: $location/0x" . &decimal_to_hex($location) . " ($size bytes)\n";

		# Generate null byte string according to size of current location.
		my $null_byte_string;

		for(1 .. $size)
		{
			$null_byte_string .= "00";
		}

		# Patch space with null data.
		&patch_bytes($game_data_folder . $file, $null_byte_string, $location);
	}
}

# Patch empty space in main executable with null bytes.
my $null_byte_string;

for($overflow_location .. $overflow_location + $overflow_size - 1)
{
	$null_byte_string .= "00";
}

&patch_bytes($game_data_folder . "0KERNEL.BIN", $null_byte_string, $overflow_location);

# Status message.
print "\n";

# Iterate through and process each translated spreadsheet.
for(my $i = 0; $i < scalar(@spreadsheets); $i ++)
{
	# Store base file name.
	(my $file = $spreadsheets[$i]) =~ s/\.xlsx//g;

	# Declare empty string hash.
	my %strings;

	# Read and store spreadsheet.
	my $spreadsheet = ReadData($spreadsheet_folder . $spreadsheets[$i]);
	my @spreadsheet_rows = Spreadsheet::Read::rows($spreadsheet->[1]);

	# Status message.
	print "[PROCESSING SPREADSHEET $spreadsheets[$i]]\n";

	# Iterate through each row of spreadsheet.
	for(my $j = 1; $j < scalar(@spreadsheet_rows); $j ++)
	{
		# Store data from current spreadsheet row.
		(my $pointer_original = $spreadsheet_rows[$j][0]) =~ s/'//g;
		my $type = $spreadsheet_rows[$j][1];
		my $translation = decode_entities($spreadsheet_rows[$j][3]);

		# Clean translated text of non-ASCII characters and extraneous whitespace.
		$translation =~ s/’/'/g;
		$translation =~ s/…/\.\.\./g;
		$translation =~ s/\P{IsPrint}//g;
		$translation =~ s/[^[:ascii:]]+//g;
		$translation =~ s/\r\n/ /g;
		$translation =~ s/\n/ /g;
		$translation =~ s/@/ @ /;
		$translation =~ s/^\s+|\s+$//g;
		$translation =~ s/\s+/ /g;

		# Status message.
		print " -> row $j: $translation\n";

		# Declare empty translated byte string.
		my $translated_bytes;

		# Processing a four-byte empty area for RAM use.
		if($type eq "RAM")
		{
			$translated_bytes = "00000000";
		}
		# Processing a reference to a file.
		elsif($type eq "Filename")
		{
			# Store ASCII representation of filename.
			$translated_bytes = ascii_to_hex($translation);

			# Pad byte string for four-byte alignment.
			$translated_bytes .= "00";

			while((length($translated_bytes) / 2) % 4 != 0)
			{
				$translated_bytes .= "00";
			}
		}
		# Processing text.
		else
		{
			# Declare and initialize variables for text wrapping.
			my @translation_wrapped_array;
			my $translation_wrapped_array_index = 0;

			# Iterate through each word and store each line in separate element of array.
			foreach my $translation_wrapped_word (split /\s+/, $translation)
			{
				# Automatically break to the next line if newline character encountered.
				if($translation_wrapped_word eq "@")
				{
					$translation_wrapped_array_index ++;
					$translation_wrapped_array[$translation_wrapped_array_index] = "";
					
					next;
				}
				
				# There's room on the current line to append the word, including an empty space in
				# between words.
				if(length($translation_wrapped_array[$translation_wrapped_array_index] . $translation_wrapped_word) +
                   		  ($translation_wrapped_array[$translation_wrapped_array_index] ? 1 : 0) <= 29)
				{
					$translation_wrapped_array[$translation_wrapped_array_index] .= ($translation_wrapped_array[$translation_wrapped_array_index] ? ' ' : '') . $translation_wrapped_word;
				}
				# Otherwise, move to the next line before appending the word.
				else
				{
					$translation_wrapped_array_index ++;

					$translation_wrapped_array[$translation_wrapped_array_index] = $translation_wrapped_word;
				}
			}

			# Throw warning if text exceeds two lines.
			if(scalar(@translation_wrapped_array) > 2)
			{
				print "!!! WARNING !!! ROW $i EXCEEDS TWO LINES!\n";
				system "echo \"$spreadsheets[$i] - row $i exceeds two lines\" >> warning.log";
			}

			# Process each line of text.
			for(my $k = 0; $k < scalar(@translation_wrapped_array); $k ++)
			{
				# Apply special processing for line one of text.
				if($k == 0)
				{
					# Start with required empty space.
					$translated_bytes .= "E0";
				}
				# Apply special processing for line two of text.
				else
				{
					# Perform manual line break.
					$translated_bytes .= "40E0";

					# Start new line with two additional empty spaces if processing training text.
					if($type eq "Text" && $file eq "REN.BIN;")
					{
						$translated_bytes .= "E0E0";
					}
					# Start new line with a custom 3-pixel tile (0xED) for certain stages.
					elsif($type eq "Text" && ($file eq "STG1.BIN;" || $file eq "STG5.BIN;" || $file eq "STG6B.BIN;"))
					{
						$translated_bytes .= "ED";
					}
					# Start new line with one empty space and a custom 10-pixel tile (0xF0) for
					# certain stages.
					elsif($type eq "Text" && ($file eq "STG2.BIN;" || $file eq "STG3.BIN;" || $file eq "STG4.BIN;" || $file eq "STG6A.BIN;"))
					{
						$translated_bytes .= "E0F0";
					}
				}
				
				# Process each individual character.
				my @characters = split("", $translation_wrapped_array[$k]);

				foreach(@characters)
				{
					# Replace underscores with empty spaces.
					$_ =~ s/_/ /g;

					$translated_bytes .= $character_map{$_};
				}
			}

			# Pad byte string for four-byte alignment.
			$translated_bytes .= "00";

			while((length($translated_bytes) / 2) % 4 != 0)
			{
				$translated_bytes .= "00";
			}
		}

		# Status message.
		print "	encoded text: $translated_bytes\n";
		print "	original pointer: $pointer_original\n";

		# Add elements to hash.
		$strings{$j}->{'Encoded Text'} = $translated_bytes;
		$strings{$j}->{'Text'} = $translation;
		$strings{$j}->{'Original Pointer'} = $pointer_original;
	}

	# Status message.
	print "\n[PROCESSING TEXT REALLOCATION AND POINTER UPDATES FOR $file]\n";

	# Iterate through each translated string to perform new pointer calculation.
	for my $string_number (sort {$a <=> $b} keys %strings)
	{
		# Store encoded text.
		my $byte_string = %strings{$string_number}->{'Encoded Text'};

		# Set successful text insertion flag to default of false.
		my $inserted = 0;

		# Iterate through each position in the space map.
		for my $location (sort {$a <=> $b} keys %{$space_map{$file}})
		{
			# Find space for text if not yet inserted on previous iteration.
			if(!$inserted)
			{
				# Store current location's total allotted size.
				my $size = %space_map{$file}->{$location};

				# Sufficient space exists to insert text data.
				if($size >= length($byte_string) / 2)
				{
					# Calculate new pointer using appropriate base address.
					my $pointer_new;

					if($file eq "0KERNEL.BIN")
					{
						$pointer_new = &decimal_to_hex($location + $base_address_main, 4);
					}
					else
					{
						$pointer_new = &decimal_to_hex($location + $base_address_alt, 4);
					}

					# Store new pointer, used later for patching data.
					$strings{$string_number}->{'New Pointer'} = $pointer_new;

					# Store new location for text, used later for patching data.
					$strings{$string_number}->{'New Location'} = $location;

					# Remove original location key, increase starting location, and reduce available
					# space based on size of inserted string.
					delete %space_map{$file}->{$location};
					$location += length($byte_string) / 2;
					%space_map{$file}->{$location} = $size - (length($byte_string) / 2);

					# Set successful text insertion flag to true.
					$inserted = 1;

					# Increase global string count by one.
					$string_count ++;
				}
			}

		}

		# If insufficient space was available to insert text, display message and add to overflow
		# area.
		if(!$inserted)
		{
			# Status message.
			print ".--!!! NOT INSERTED DUE TO SPACE LIMITATIONS, ADDED TO OVERFLOW !!!---.\n";
			print "`--string number $string_number (" . %strings{$string_number}->{'Text'} . ")\n";

			# Increase overflow counter by one.
			$overflow_count ++;

			# Add string to overflow hash map for processing later.
			$overflow_map{$file}->{$overflow_count}->{'Encoded Text'} = $byte_string;
			$overflow_map{$file}->{$overflow_count}->{'Text'} = %strings{$string_number}->{'Text'};
			$overflow_map{$file}->{$overflow_count}->{'Original Pointer'} = %strings{$string_number}->{'Original Pointer'};
		}
	}

	# Iterate through each translated string to perform text insertion.
	for my $string_number (sort {$a <=> $b} keys %strings)
	{
		# If no new pointer was calculated, current string belongs in overflow area and should be
		# ignored here.
		if($strings{$string_number}->{'New Pointer'} ne "")
		{
			# Store relevant hash elements.
			my $text = $strings{$string_number}->{'Text'};
			my $byte_string = $strings{$string_number}->{'Encoded Text'};
			my $pointer_original = $strings{$string_number}->{'Original Pointer'};
			my $pointer_new = $strings{$string_number}->{'New Pointer'};
			my $location = $strings{$string_number}->{'New Location'};

			# Status message.
			print " -> text: $text\n";
			print "	encoded text: $byte_string\n";
			print "	original pointer: $pointer_original\n";
			print "	new pointer: $pointer_new\n";
			print "	location: $location\n";

			# Read entirety of original file for purposes of pointer location identification.
			my $source_file_bytes = uc(&read_bytes($game_data_folder_original . $file));

			# Store array versions of source file and original pointer for purposes of pointer
			# replacement.
			my @source_file_byte_array = ($source_file_bytes =~ m/../g);
			my @pointer_original_byte_array = ($pointer_original =~ m/../g);

			# Initialize pointer update counter.
			my $pointer_update_count = 0;

			# Seek through every four bytes of target file to find matching original pointers.
			for(my $j = 0; $j < scalar(@source_file_byte_array); $j += 4)
			{
				# Old pointer found, update with new one.
				if(@source_file_byte_array[$j .. $j+3] ~~ @pointer_original_byte_array)
				{
					&patch_bytes($game_data_folder . $file, $pointer_new, $j);

					# Increase pointer update counter by one.
					$pointer_update_count ++;
				}
			}

			# Status message.
			print "	pointers updated: $pointer_update_count\n\n";

			# Update pointer counters.
			$pointer_count += $pointer_update_count;

			if($pointer_update_count == 0)
			{
				$pointer_missing_count ++;
			}

			# Patch text data.
			&patch_bytes($game_data_folder . $file, $byte_string, $location);
		}
	}
}

# If necessary, process overflow text data by writing it to the unused portion of the font sheet, 
# which is always present in RAM.
if($overflow_count > 0)
{
	# Status message.
	print "[PROCESSING OVERFLOW TEXT DATA]\n";

	# Initialize rolling overflow location to start of usable memory.
	my $rolling_overflow_location = $overflow_location;

	# Iterate through each file from overflow map.
	for my $file (sort {$a <=> $b} keys %overflow_map)
	{
		# Iterate through each text entry for current file.
		for my $string_number (sort {$a <=> $b} keys %{$overflow_map{$file}})
		{
			# Store relevant elements about the current string.
			my $text = $overflow_map{$file}->{$string_number}->{'Text'};
			my $byte_string = $overflow_map{$file}->{$string_number}->{'Encoded Text'};
			my $pointer_original = $overflow_map{$file}->{$string_number}->{'Original Pointer'};

			# Calculate and store new pointer based on current location in overflow area.
			my $pointer_new = &decimal_to_hex($rolling_overflow_location + $base_address_main, 4);

			# Status message.
			print " -> file: $file\n";
			print "	text: $text\n";
			print "	encoded text: $byte_string\n";
			print "	original pointer: $pointer_original\n";
			print "	new pointer: $pointer_new\n";

			# Read entirety of original file for purposes of pointer location identification.
			my $source_file_bytes = uc(&read_bytes($game_data_folder_original . $file));

			# Store array versions of source file and original pointer for purposes of pointer
			# replacement.
			my @source_file_byte_array = ($source_file_bytes =~ m/../g);
			my @pointer_original_byte_array = ($pointer_original =~ m/../g);

			# Initialize pointer update counter.
			my $pointer_update_count = 0;

			# Seek through every four bytes of target file to find matching original pointers.
			for(my $j = 0; $j < scalar(@source_file_byte_array); $j += 4)
			{
				# Old pointer found at current location.
				if(@source_file_byte_array[$j .. $j+3] ~~ @pointer_original_byte_array)
				{
					# Update original pointer with new one.
					&patch_bytes($game_data_folder . $file, $pointer_new, $j);
					#print "loop patch_bytes($game_data_folder" . $file . ", $pointer_new, $j)\n";

					# Increase pointer update counter by one.
					$pointer_update_count ++;
				}
			}

			# Status message.
			print "	pointers updated: $pointer_update_count\n\n";

			# Patch text data into appropriate file.
			&patch_bytes($game_data_folder . "0KERNEL.BIN", $byte_string, $rolling_overflow_location);

			# Update rolling location for overflow text data based on length of current byte string.
			$rolling_overflow_location += length($byte_string) / 2;
		}
	}
}

# Status message.
print "[PROCESS COMPLETE]\n";
print " -> strings: $string_count\n";
print "	overflow strings: $overflow_count\n";
print "	updated pointers: $pointer_count ($pointer_missing_count not found)\n\n";




# Subroutine to return hexadecimal representation of a decimal number.
#
# 1st parameter - Decimal number.
# 2nd parameter - Number of bytes with which to represent hexadecimal number (omit parameter for no
#				 padding).
sub decimal_to_hex
{
	if($_[1] eq "")
	{
		$_[1] = 0;
	}

	return sprintf("%0" . $_[1] * 2 . "X", $_[0]);
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

# Subroutine to write a sequence of hexadecimal values to a specified file.
#
# 1st parameter - Full path of file to write.
# 2nd parameter - Hexadecimal representation of data to be written to file.
sub write_bytes
{
	my $output_file = $_[0];
	(my $hex_data = $_[1]) =~ s/\s+//g;
	my @hex_data_array = split(//, $hex_data);

	open my $filehandle, '>:raw', $output_file or die $!;
	binmode $filehandle;

	for(my $i = 0; $i < scalar(@hex_data_array); $i += 2)
	{
		my($high, $low) = @hex_data_array[$i, $i + 1];
		print $filehandle pack "H*", $high . $low;
	}

	close $filehandle;
}

# Subroutine to write a sequence of hexadecimal values at a specified offset (in decimal format) into
# a specified file, as to patch the existing data at that offset.
#
# 1st parameter - Full path of file in which to insert patch data.
# 2nd parameter - Hexadecimal representation of data to be inserted.
# 3rd parameter - Offset at which to patch.
sub patch_bytes
{
	my $output_file = $_[0];
	(my $hex_data = $_[1]) =~ s/\s+//g;
	my @hex_data_array = split(//, $hex_data);
	my $patch_offset = $_[2];

	if((stat $output_file)[7] < $patch_offset + (scalar(@hex_data_array) / 2))
	{
		die "Offset for patch_bytes is outside of valid range.\n";
	}

	open my $filehandle, '+<:raw', $output_file or die $!;
	binmode $filehandle;
	seek $filehandle, $patch_offset, 0;

	for(my $i = 0; $i < scalar(@hex_data_array); $i += 2)
	{
		my($high, $low) = @hex_data_array[$i, $i + 1];
		print $filehandle pack "H*", $high . $low;
	}

	close $filehandle;
}

# Subroutine to generate hash mapping ASCII characters to custom hexadecimal values. Source character
# map file should be formatted with each character definition on its own line (<hex>|<ascii>). Example
# character map file:
#  ______
# |	  |
# | 00|A |
# | 01|B |
# | 02|C |
# |______|
#
# The ASCII key in the returned hash will contain the custom hexadecimal value (e.g., $hash{'C'} will
# equal "02").
#
# 1st parameter - Full path of character map file.
sub generate_character_map_hash
{
	my $character_map_file = $_[0];
	my %character_table;

	open my $filehandle, '<', $character_map_file or die $!;
	chomp(my @mapped_characters = <$filehandle>);
	close $filehandle;

	foreach(@mapped_characters)
	{
		$_ =~ s/\P{IsPrint}//g;
		$_ =~ s/[^[:ascii:]]+//g;

		$character_table{(split /\|/, $_)[1]} = (split /\|/, $_)[0];
	}

	return %character_table;
}

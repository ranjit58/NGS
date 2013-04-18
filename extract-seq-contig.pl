#!/usr/bin/perl
# extract_fasta - Extract a portion of a contig from a fasta sequence
# file and optionally the corresponding portion of a contig from a
# fasta qual file.  The output contig may be reversed and complemented.
# The output contig name may be shortened.
#
# Written by: James D. White, University of Oklahoma, Advanced Center for
#   Genome Technology
#
#
# 2010.07.22 JDW - Change option parsing to use Getopt::Std.  Add -a
#		   flag to output ALL contigs.  Add -V flag for per
#		   contig stats with -a.
# 2007.02.05 JDW - Add -L and -U flags
#Date Written: Dec 8, 1999
$Date_Last_Modified = "July 23, 2010";


######################## Customization Parameters ###########################

$all_contigs = 0;		# Output ALL contigs, instead of just 1? (-a)
$contig_name = '';		# default to first contig (-c)
$begin_base = 1;		# default to beginning of contig? (-b)
$end_base = -1;			# default to end of contig (-e)
$number_of_bases = 0;		# default to rest of contig (-n)
$shorten_contig_name = 0;	# Is contig name shortened? (See -s)
$preserve_comments = 0;		# Are contig header comments preserved? (See -p)
$get_qualities = 0;		# Is a fasta quality file to be used/created? (-q)
$DEFAULT_LINE_LENGTH = 50;	# Default length of fasta output sequence lines.
$output_line_len = $DEFAULT_LINE_LENGTH;# Length of fasta output sequence lines. (-l)
$MIN_LINE_LENGTH = 10;		# Mimimum allowed value for $output_line_len.
$Verbose_Mode = 0;		# Are some statistics listed? (see -v and -V)
$UpDown_Case = 0;		# Convert to lower case (<0), upper case (>0), or
				#   leave alone (0)

our $IN_OPEN = 0;		# Input files are open?
our $OUT_OPEN = 0;		# Output files are open?
$DEBUG = 1;			# For testing

##################### End of Customization Parameters #######################


($::my_name) = $0 =~ m"[\\/]?([^\\/]+)$";
$::my_name ||= 'extract_fasta';

# parse the command line arguments
use Getopt::Std;
our ($opt_a, $opt_b, $opt_c, $opt_e, $opt_h, $opt_l, $opt_L, $opt_n,
     $opt_p, $opt_q, $opt_s, $opt_U, $opt_v, $opt_V) = ('') x 14;
display_help("Invalid flag: $flag")
  unless( getopts('ab:c:e:hl:Ln:pqsUvV') );
display_more_help() if ($opt_h);				# -h

$Verbose_Mode = 1 if ($opt_v);					# -v
$Verbose_Mode = 2 if ($opt_V);					# -V
print STDOUT "$::my_name - Last Modified: $Date_Last_Modified\n\n"
  if $Verbose_Mode;

display_help("Cannot mix '-a' and '-c'")
  if ($opt_a ne '' && $opt_c ne '');
if ($opt_a ne '')						# -a
  {
  $all_contigs = 1;
  }
elsif ($opt_c ne '')					# -c contid_id
  {
  $contig_id = $opt_c;
  # check type of $contig_id
  if ($contig_id =~ /^\d+$/)
    {
    $contig_numeric = 0;
    $contig_id = ($contig_id);
    }
  else
    {
    $contig_numeric = 0;
    }
  }
else		# assume first contig
  {
  $contig_numeric = 1;
  $contig_id = 1;
  }

if ($opt_b ne '')					# -b begin_base
  {
  $begin_base = $opt_b;
  display_help("Invalid 'begin_base': -b $begin_base")
    if ($begin_base !~ /^-?\d+$/ || $begin_base == 0);
  }

display_help("Cannot mix '-e' and '-n'")
  if ($opt_e ne '' && $opt_n ne '');
if ($opt_e ne '')					# -e end_base
  {
  $end_base = $opt_e;
  display_help("Invalid 'end_base': -e $end_base")
    if ($end_base !~ /^-?\d+$/ || $end_base == 0);
  }
if ($opt_n ne '')					# -n number_of_bases
  {
  $number_of_bases = $opt_n;
  display_help("Invalid 'number_of_bases': -e $number_of_bases")
    if ($number_of_bases !~ /^-?\d+$/);
  }

if ($opt_f ne '')				# -l output_line_length
  {
  $output_line_len = $opt_l;
  display_help("Invalid 'output_line_length': -c $output_line_len")
    if (($output_line_len !~ /^\d+$/) ||
        ($output_line_len < $MIN_LINE_LENGTH));
  }
$shorten_contig_name = 1 if ($opt_s ne '');	# -s (short contig names)
$preserve_comments = 1 if ($pot_p ne ''); # -p (keep contig hdr comments)
$get_qualities = 1 if ($opt_q ne '');	# -q (get fasta qual file)
$UpDown_Case = -1 if ($opt_L ne '');		# -L	(lower case)
$UpDown_Case = 1 if ($opt_U ne '');		# -U	(upper case)


$fasta_input_file = shift @ARGV;
$fasta_input_file = '-' if (!$fasta_input_file);
if ($get_qualities && $fasta_input_file eq '-')
  {
  display_help("Missing 'fasta_input_file' name (and 'fasta_output_file' name),\n" .
		"  which are required when '-q' is specified.");
  }
open(FASTAIN, $fasta_input_file) ||
  die("Can't open fasta_input_file: '$fasta_input_file'\n  $!\n");
if ($get_qualities)
  {
  if (!open(QUALIN, "${fasta_input_file}.qual"))
    {
    close(FASTAIN);
    die("Can't open input fasta quality file: '${fasta_input_file}.qual'\n  $!\n");
    }
  }
$IN_OPEN = 1;

  $fasta_output_file = shift @ARGV;
  $fasta_output_file = '-' if (!$fasta_output_file);
  if ($get_qualities && $fasta_output_file eq '-')
    {
    display_help("Missing 'fasta_output_file' name, which is required when '-q' is specified.");
    }


$Num_Contigs = 0;
our $Output_Contigs = 0;
$header = '';
$contig = '';
$sequence = '';
$line_num = 0;
if ($get_qualities)
  {
  $Qline = <QUALIN>;
  $Qline_num = 1;
  $Qcontig = '';
  }
while (defined($line = <FASTAIN>))
  {
  chomp $line;
  $line_num++;
  if ($line =~ /^>/)
    {
    if ($contig)	# after first input line?
      {
      if ($get_qualities && length($sequence) != @Quality)
        {
        print STDERR "Lengths of fasta sequence and quality files do not match on\n  contig='$contig'\n";
        exit 2;
        }
      if (($all_contigs) ||
          ($contig_numeric && $contig_id > 0 && $contig_id == $Num_Contigs) ||
          (!$contig_numeric && $contig ==$contig_id))
        {
        process_contig($contig, $sequence);
	unless ($all_contigs)
	  {
          closem();
          exit 0;
	  }
        }
      }
    $Num_Contigs++;
    $header = $line;
    if ($header =~ m/^>(\S+)(.*)$/)
      {
      $contig = $1;
      $comment = $2;
      }
    else
      {
      print STDERR "Error: Invalid fasta_input_file format: '$fasta_input_file'\n" .
      		   "  Fasta input line number=$line_num\n";
      closem();
      exit 2;
      }
    $sequence = '';
    if ($get_qualities)
      {
      chomp($Qline);
      $Qheader = $Qline;
      if ($Qheader =~ m/^>(\S+)(.*)$/)
        {
        $Qcontig = $1;
        $Qcomment = $2;
        if ($contig ne $Qcontig)
          {
          print STDERR "Fasta sequence and quality files do not match on contig header number $Num_Contigs\n" .
		       "  Sequence contig='$contig', Quality contig='$Qcontig'\n";
	  closem();
          exit 2;
          }
        }
      else
        {
        print STDERR "Error: Invalid fasta_qual_input_file format: '${fasta_input_file}.qual'\n" .
		     "  Quality file input line number=$Qline_num,\n  Qline='$Qline'\n";
	closem();
        exit 2;
        }
      $Qline = <QUALIN>;
      $Qline_num++;
      $Quality = '';
      while (length($Qline) && $Qline !~ /^>/)
        {
        chomp($Qline);
        $Quality .= ' ' . $Qline;
        $Qline = <QUALIN>;
        $Qline_num++;
        }
      $Quality =~ s/^\s+//;
      $Quality =~ s/\s+$//;
      @Quality = split(' ', $Quality);
      } # end if ($get_qualities)
					# Remove Contig name prefix?
    $contig =~ s/^.*Contig/Contig/ if $shorten_contig_name;
    next;
    } # end if ($line =~ /^>/)

  if (!$contig)
    {
    print STDERR "Error: Invalid fasta_input_file format: '$fasta_input_file'\n";
    closem();
    exit 2;
    }
  $line =~ s/\s//g;
  $sequence .= $line;
  } # end while (defined($line = <FASTAIN>))

  if ($contig)
    {
    if (($all_contigs) ||
        ($contig_numeric && ($contig_id == 0 || $contig_id == $Num_Contigs)) ||
        (!$contig_numeric && $contig == $contig_id))
      {
      process_contig($contig, $sequence);
      }
    else
      {
      print STDERR "Error: Contig '$contig_id' not found\n";
      closem();
      exit 2;
      }
    }
  else
    {
    print STDERR "Error: Empty fasta_input_file: '$fasta_input_file'\n";
    }
closem();

if ($all_contigs && $Verbose_Mode)
  {
  print STDERR "\n$Num_Contigs sequences were read from input file\n";
  print STDERR "$Output_Contigs sequencess were written to output file\n";
  }
print STDERR "\n";
exit 0;



###########################################################################
# process_contig - output the ends of the contig into two files named
#                  ${contig}r and ${contig}f, corresponding to the reverse
#                  and forward extension directions.  If the contig is less
#                  than 1.5 * $end_length bases long after leading and
#                  trailing Ns and Xs are optionally removed, then the
#                  entire contig is output as one file.
###########################################################################

sub process_contig
  {
  my($contig, $sequence) = @_;
  my($len, $i);

  $len = length($sequence);
  $complement_contig = 0;	# Assume output contig not to be complemented

  $n_found = ($opt_n ne '') ? 1 : 0;

  # copy values so we can change them, but keep the original values
  #   (for next contig?)
  $begin_base2 = $begin_base;
  $end_base2 = $end_base;
  $number_of_bases2 = $number_of_bases;

  # Fixup $begin_base2: '+' => from left, '-' => from right, '0' => invalid
  $begin_base2 = $len	# use end of contig if no '-b' and '-n <0'
    if (($opt_b eq '') && ($opt_n ne '') && ($opt_n =~ /^-/));
  $begin_base2  = $len     if $begin_base2 > $len; # too long
  $begin_base2 += $len + 1 if $begin_base2 < 0;	 # negative => back from end
  $begin_base2  = 1        if $begin_base2 < 1;	 #   if still past beginning

  if ($opt_e ne '')
    {
    # Fixup $end_base2: '+' => from left, '-' => from right, '0' => invalid
    #   and calculate $number_of_bases2
    $end_base2  = $len     if ($end_base2 > $len); # too long
    $end_base2 += $len + 1 if ($end_base2 < 0);	 # negative => back from end
    $end_base2  = 1        if ($end_base2 < 1);	 #   if still past beginning
    $n_found = 1;
    $number_of_bases2 = $end_base2 - $begin_base2;
    $number_of_bases2 += ($number_of_bases2 >= 0) ? +1 : -1;
    if ($begin_base2 * $end_base2 < 0 &&	#/(b>0,e<0,\ or /(b<0,e>0,\
        $begin_base2 * $number_of_bases2 < 0)	#\ and b>e)/    \ and b<e)/
      {
      if ($all_contigs)
        {
	print STDERR "Contig $contig skipped, because -b $begin_base -e $end_base\n" .
		     "  was invalid for contig len=$len\n"
	  if ($Verbose_Mode > $all_contigs);
	return;
	}
      else
	{
        display_help("\nbegin_base='-b $begin_base' and " .
          "end_base='-e $end_base' specify an invalid range of bases,\n" .
          "because the contig length=$len is too short\n");
	}
      }
    }

  if ($n_found)		# Fixup $number_of_bases2 and determine direction
    {
    if ($number_of_bases2 =~ /^-/)
      {
      $complement_contig = 1;
      $number_of_bases2 = 0-($number_of_bases2);
      }
    $number_of_bases2 ||= $len; # '0' => set to max for now.  we'll fix it later
    }
  else			# $end_base2 and $number_of_bases2 not specified.
    {			#   Use rest of contig
    $number_of_bases2 = $len;	 # assume max for now.  we'll fix it later
    $complement_contig = 1 if ($begin_base2 == $len);
    }

  # check for maximum $number_of_bases2 and compute proper perl start position
  if ($complement_contig)
    {
    $number_of_bases2 = $begin_base2 if $number_of_bases2 > $begin_base2;
    $end_base2 = $begin_base2 - ($number_of_bases2 - 1);
    $start_base = $end_base2 - 1; # ("-1" is correction for Perl subscripting)
    }
  else
    {
    my($max_len) = $len - $begin_base2 + 1;
    $number_of_bases2 = $max_len if $number_of_bases2 > $max_len;
    $end_base2 = $begin_base2 + ($number_of_bases2 - 1);
    $start_base = $begin_base2 - 1; # ("-1" is correction for Perl subscripting)
    }

  $sequence2 = substr($sequence, $start_base, $number_of_bases2);
  $subset = '';
  if ($number_of_bases2 != $len)
    {
    $subset = " bases ${begin_base2}..$end_base2";
    }
  if ($complement_contig)
    {
    $sequence2 = reverse($sequence2);
    $sequence2 =~ tr/acgtACGT/tgcaTGCA/;
    $subset .= " complemented";
    }

  open_out($fasta_output_file);
  output_contig(">${contig}$subset", $sequence2);
  if ($get_qualities)
    {
    @Quality2 = splice(@Quality, $start_base, $number_of_bases2);
    @Quality2 = reverse(@Quality2) if $complement_contig;
    output_contig_qual(">${contig}$subset", @Quality2);
    }
  print STDERR "bases ${begin_base2}-$end_base2 (length=$number_of_bases2) of contig '$contig' extracted\n"
    if ($Verbose_Mode > $all_contigs);

  $Output_Contigs++;
  } # end process_contig


###########################################################################
# open_out - Open output files.
###########################################################################
sub open_out
  {
  my($out_file) = @_;
  return if ($OUT_OPEN);
  
  if (!open(FASTAOUT, ">$out_file"))
    {
    closem();
    die("Can't create fasta_output_file: '$out_file'\n");
    }
  if ($get_qualities)
    {
    if (!open(QUALOUT, ">${out_file}.qual"))
      {
      close(FASTAOUT);
      closem();
      die("Can't create output fasta quality file: '${out_file}.qual'\n");
      }
    }
  $OUT_OPEN = 1;
  } # end open_out


###########################################################################
# closem - Close files.
###########################################################################
sub closem
  {
  return unless ($IN_OPEN);
  close FASTAIN; 
  close FASTAOUT if ($OUT_OPEN);
  if ($get_qualities)
    {
    close QUALIN;
    close QUALOUT if ($OUT_OPEN);
    }
  $IN_OPEN = $OUT_OPEN = 0;
  } # end closem

  
###########################################################################
# output_contig - output a contig to standard output.
###########################################################################

sub output_contig
  {
  my($header, $sequence) = @_;
  if ($UpDown_Case > 0)			# Convert to upper case?
    {
    $sequence = "\U$sequence";
    }
  elsif ($UpDown_Case < 0)		# Convert to upper case?
    {
    $sequence = "\L$sequence";
    }
  my($len) = length($sequence);
  my($segment, $i);
  if ($preserve_comments)
    {
    $header .= $comment;	# Add contig comments back to header?
    }
  print FASTAOUT "$header\n";
  for ($i = 0; $i < $len; $i += $output_line_len)
    {
    $segment = substr($sequence, $i, $output_line_len);
    print FASTAOUT "$segment\n";
    } # end for ($i ... )
  } # end output_contig


###########################################################################
# output_contig - output a contig to standard output.
###########################################################################

sub output_contig_qual
  {
  my($header, @quals) = @_;
  my($len) = scalar @quals;
  my($i);
  my($segment);
  if ($preserve_comments)
    {
    $header .= $Qcomment;	# Add contig comments back to header?
    }
  print QUALOUT "$header\n";
  $segment = '';
  for ($i = 0; $i < $len; $i++)
    {
    if (length($segment) >= $output_line_len)
      {
      print QUALOUT "$segment\n";
      $segment = '';
      }
    $segment .= "$quals[$i] ";
    } # end for ($i ... )
  print QUALOUT "$segment\n" if (length($segment));
  } # end output_contig_qual


###########################################################################
# display_help
###########################################################################

sub display_help
  {
  my($msg) = @_;
  print STDERR "\n$msg\n" if $msg;
  print STDERR <<EOF;

USAGE: $my_name [-b begin_base] [[-n number_of_bases] or [-e end_base]]
                [[-c contig_id] or -a] [-l output_line_length]
		[-p] [-q] [-s] [-v or -V] [-L or -U]
		[fasta_input_file [fasta_output_file]]
              or
       $my_name -h

EOF
  closem();
  exit 2;
  } # end display_help


###########################################################################
# display_more_help
###########################################################################

sub display_more_help
  {
  print STDOUT <<EOF;

extract_fasta - Extract a portion of a contig from a fasta sequence
file.  The contig to be processed is specified with '-c', or the same
portion of all contigs are extracted if '-a' is specified;  otherwise,
the default is to use the first contig if neither '-a' or '-c' are
specified.  The output contig may be reversed and complemented if a
negative length is specified, or if the starting position is after the
ending position.

The contig names optionally may be shortened ('-s') by removing
everything before the word "Contig".  Contig header comments, located
after the contig name on the contig header line, will be removed,
unless '-p' is specified.  All output lines containing sequence bases
(not contig headers) are reformatted to be 'output_line_length' bases
long.  If '-q' is specified, then a fasta quality file named
"'fasta_input_file'.qual" also will be processed, creating an output
fasta quality file named "'fasta_output_file'.qual" from the matching
portion of the contig.

The default action is to extract a complete contig from the input file,
unless '-b', '-e', and/or '-n' are specified to provide limits.

NOTE: When the values for '-b', '-e', and/or '-n' exceed the ends of a
contig, either positive or negative, because the contig is shorter than
expected, then the program will attempt to change them to reasonable
values, but this may result in unexpected results, such as writing a
single base contig, without any special warning.  When the values for
'-b', '-e', and/or '-n' cannot be made into reasonable values, then
for a single contig specified via '-c' an error message is displayed,
but if '-a' was specified, then the contig is skipped.


USAGE: $my_name [-b begin_base] [[-n number_of_bases] or [-e end_base]]
                [[-c contig_id] or -a] [-l output_line_length]
		[-p] [-q] [-s] [-v or -V] [-L or -U]
		[fasta_input_file [fasta_output_file]]
              or
       $my_name -h           <== What you are reading

  where 'begin_base' is the number of the beginning base where extraction
            is to start.  The default is base 1, unless 'number_of_bases'
            is negative, then the default is the last base of the input
            contig.  'begin_base may be specified as '-b 1' or '-b -1' to
            indicate the first or last base, respectively, of the contig.
            '-b 101' would start at the 101st base.  '-b -100' would
            start at the 100th base from the end of the contig.  If the
            magnitude of 'begin_base' is too large, it will be reduced to
            a valid value.  '-b 0' and '-b -0' are invalid. 

        'number_of_bases' is the maximum length to extract.  Omit or
            use 'number_of_bases' = 0, to force output to the end of the
            contig.  If 'number_of_bases' is negative, then the magnitude
            is used to specify the number of bases to extract, but the
            direction is from 'begin_base' backwards towards the
            beginning of the input contig, and the output contig will be
            reversed and complemented from the input. A negative zero
            '-n -0' may be used to indicate that the first base will be
            the ending base and that the output contig will be reversed
            and complemented from the input.  If the magnitude of
            'number_of_bases' is too large, it will be reduced to a valid
            value.  Only one of '-n' and '-e' may specified.

        'end_base' is the number of the ending base where extraction
            is to end.  The default value is the last base of the contig.
            If 'end_base' is less than 'begin_base', then the output
            contig will be reversed and complemented from the input.
            'end_base may be specified as '-e 1' or '-e -1' to indicate
            the first or last base, respectively, of the contig.
            '-e 100' would end at the 100th base.  '-e -100' would
            end at the 100th base from the end of the contig.  If the
            magnitude of 'end_base' is too large, it will be reduced to
            a valid value.  '-e 0' and '-e -0' are invalid.  Only one of
            '-n' and '-e' may specified.

        'contig_id' is used to specify which contig is to be processed.
            If 'contig_id' is numeric, then 'contig-id' specifies the
            ordinal number of the contig in the file, i.e., '-c 2'
            specifies the second contig in the input file, which is not
            necessarily named "Contig2".  A 'contid_id' of zero '-c 0'
            is a special case to indicate the last contig in the input
            file is to be processed.  If 'contig_id' is not numeric,
            then 'contig-id' specifies a string to be contained within
            the contig name.  For example, '-c Contig2' indicates that
            the first contig which contains the string "Contig2" is to
            be processed, which may or may not be the second contig in
            the file.  '-c Contig2' will also match "Contig25",
            "Contig200", etc., but will process only the first contig
            that matches.  Note however that $my_name does check the
            preceding contigs to make sure that the file is properly
            formatted.  Note also that case does matter.  '-c Contig2'
            is not the same as '-c contig2'.

        'fasta_input_file' is the name of the input sequence file in Fasta
            format, which contains the contigs to be processed.  If
            'fasta_input_file' is omitted, standard input will be used.

        'fasta_output_file' is the name of the output sequence file in
            Fasta format.

        'output_line_length' is the length of the output sequence lines.
            If omitted, the default value is $DEFAULT_LINE_LENGTH.


OPTIONS:

  -a  Specifies that ALL contigs are to be processed.  Must not be used
      with '-c'.

  -b begin_base  Specify beginning base for extracting a partial contig.

  -c contig_id  Identify a single contig is to be processed.  Must not
      be used with '-a'.

  -e end_base  Specify ending base for extracting a partial contig.  Must
      not be used with '-n'.

  -l output_line_length  Specify length of output sequence lines.

  -L  Convert bases of extracted sequence to all lower case (acgtnx).

  -n number_of_bases  Specify number of bases to extract for extracting
      a partial contig.  Must not be used with '-e'.

  -p  Preserve contig header comments which are found after the contig name.

  -q  Also process a fasta quality file, as well as the sequence file.  If
      '-q' is specified, then both 'fasta_input_file' and 'fasta_output_file'
      MUST be specified.  Then the file "'fasta_input_file'.qual" will also
      be processed, to create an additional output file named
      "'fasta_output_file'.qual" from the matching portion of the contig.

  -s  The contig name may be shortened by removing any prefix before the
      word "Contig", i.e., "gono.fasta.screen.Contig26" becomes "Contig26".

  -U  Convert bases of extracted sequence to all upper case (ACGTNX).

  -v  Verbose mode - print out some statistics while running.

  -V  More verbose mode - also print out per contig statistics while
      running with '-a'.


EXAMPLES:

\$ $my_name fasta_in > fasta_first_contig_out
\$ $my_name -b 1 fasta_in fasta_first_contig_out
\$ $my_name -e -1 fasta_in fasta_first_contig_out
\$ $my_name -n 0 fasta_in fasta_first_contig_out
\$ $my_name -b 1 -e -1 fasta_in fasta_first_contig_out
\$ $my_name -b1 -n0 fasta_in fasta_first_contig_out
\$ cat fasta_in | $my_name | cat > fasta_first_contig_out

Any of the above will read the Fasta file 'fasta_in' and extract all of
the first contig, producing the file 'fasta_first_contig_out'.

\$ $my_name -b -1 fasta_in > fasta_complement_first_contig_out
\$ $my_name -n -0 fasta_in fasta_complement_first_contig_out
\$ $my_name -b -1 -n -0 fasta_in fasta_complement_first_contig_out
\$ $my_name -b -1 -e 1 fasta_in > fasta_complement_first_contig_out

Any of the above will read the Fasta file 'fasta_in', extract all of the
first contig, and reverse and complement it, producing the file
'fasta_complement_first_contig_out'.

\$ $my_name -e 100 fasta_in > first100_out
\$ $my_name -n 100 fasta_in first100_out
\$ $my_name -b 1 -e 100 fasta_in first100_out
\$ $my_name -b 1 -n 100 fasta_in first100_out

Any of the above will read the Fasta file 'fasta_in', extract the first
100 bases of the first contig, producing the file 'first100_out'.

\$ $my_name -b 100 -e 1 fasta_in > first100_out_complemented
\$ $my_name -b 100 -n -100 fasta_in first100_out_complemented
\$ $my_name -b 100 -n -0 fasta_in first100_out_complemented

Any of the above will read the Fasta file 'fasta_in', extract the first
100 bases of the first contig, and reverse and complement it, producing
the file 'first100_out_complemented'.

\$ $my_name -b 101 fasta_in > after_first100_out
\$ $my_name -b 101 -e -1 fasta_in after_first100_out
\$ $my_name -b 101 -n 0 fasta_in after_first100_out

Any of the above will read the Fasta file 'fasta_in', extract all
bases after the first 100 bases of the first contig, producing the file
'after_first100_out'.

\$ $my_name -b -1 -e 101 fasta_in > after_first100_out_complemented

The above will read the Fasta file 'fasta_in', extract all bases after
the first 100 bases of the first contig, and reverse and complement it,
producing the file 'after_first100_out_complemented'.

\$ $my_name -b 101 -e 200 -c 9 fasta_in second100_of9
\$ $my_name -c9 -b 101 -n 100 fasta_in second100_of9

Either of the above will read the Fasta file 'fasta_in', extract the
second 100 bases of the ninth contig found in the file (which may or may
not be Contig9), producing the file 'second100_of9'.

\$ $my_name -cContig8 -e 101 -b 200 fasta_in second100_reversed_ofC8
\$ $my_name -b 200 -c Contig8 -n -100 fasta_in second100_reversed_ofC8

Either of the above will read the Fasta file 'fasta_in', extract the
second 100 bases of the first contig whose name contains the string
"Contig8" (which may or may not be the eighth contig), and reverse and
complement it, producing the file 'second100_reversed_ofC8'.

\$ $my_name -q -n -100 -c g3 fasta_in last100_reversed_of_g3
\$ $my_name -b -1 -n -100 -q -cg3 fasta_in last100_reversed_of_g3

Either of the above will read the Fasta file 'fasta_in' and the Fasta
quality file 'fasta_in.qual', extract the last 100 bases and last 100
quality scores of the first contig containing the string "g3", and
reverse and complement them, producing the files 'last100_reversed_of_g3'
and 'last100_reversed_of_g3.qual'.

\$ $my_name -b 101 -e -101 fasta_in ends_stripped

The above will read the Fasta file 'fasta_in', strip off 100 bases from
each end of the first contig, producing the file 'ends_stripped'.

\$ $my_name -e 101 -b -101 fasta_in ends_stripped_reversed

The above will read the Fasta file 'fasta_in', strip off 100 bases from
each end of the first contig, and reverse and complement it, producing
the file 'ends_stripped_reversed'.

\$ $my_name -q -n -0 -c 0 fasta_in last_contig_reversed
\$ $my_name -q -b -1 -c 0 fasta_in last_contig_reversed
\$ $my_name -q -b -1 -n -0 -c 0 fasta_in last_contig_reversed
\$ $my_name -q -b -1 -e 1 -c 0 fasta_in last_contig_reversed

Any of the above will read the Fasta file 'fasta_in' and the Fasta
quality file 'fasta_in.qual', extract the last contig, reverse and
complement it, and create the files 'last_contig_reversed' and
'last_contig_reversed.qual'.

\$ $my_name -p -s -l 40 fasta_in > 40_base_lines

will read the Fasta file 'fasta_in' and output the whole first contig,
producing the file '40_base_lines'.  Because '-p' was specified, the
contig header comments are preserved.  The names of the contigs may
be shortened to remove any prefix before the string "Contig", i.e.,
"gono.fasta.screen.Contig26" becomes "Contig26".  The output lines
containing sequence data (not headers) will be 40 bases long, instead of
the default length of $DEFAULT_LINE_LENGTH.

\$ $my_name -b  21 -e  30 fasta_in fasta_first_21-30
\$ $my_name -b  21 -n  10 fasta_in fasta_first_21-30
\$ $my_name -b  21 -e -71 fasta_in fasta_first_21-30
\$ $my_name -b -80 -e -71 fasta_in fasta_first_21-30
\$ $my_name -b -80 -e  30 fasta_in fasta_first_21-30	<== error

Assuming that the first contig is exactly 100 bases long, any of the
above, except the last, will read the Fasta file 'fasta_in' and extract
bases 21-30 of the first contig, producing the file 'fasta_first_21-30'.
The last is an error, because the '-b -80' and '-e 30' overlap for this
contig, which is shorter than 111 bases, reversing the implied direction.

\$ $my_name -b  30 -e  21 fasta_in fasta_first_30-21
\$ $my_name -b  30 -n -10 fasta_in fasta_first_30-21
\$ $my_name -b -71 -n -10 fasta_in fasta_first_30-21
\$ $my_name -b -71 -e -80 fasta_in fasta_first_30-21
\$ $my_name -b  30 -e -80 fasta_in fasta_first_30-21	<== error

Assuming that the first contig is exactly 100 bases long, any of the
above, except the last, will read the Fasta file 'fasta_in' and extract
bases 21-30 of the first contig, reverse and complement it, producing the
file 'fasta_first_30-21'.  The last is an error, because the '-b 30' and
'-e -80' overlap for this contig, which is shorter than 111 bases,
reversing the implied direction.

\$ $my_name -a -v -b -26 -e 1 -q  fasta_in  fasta_out_rc_except_last_26
\$ $my_name -a -v -b -26 -n -0 -q  fasta_in  fasta_out_rc_except_last_26

Either of the above reads the Fasta sequence file 'fasta_in' and the
Fasta quality file 'fasta_in.qual', extracts all but the last 26 bases
and quality values of EACH contig, reverse-complements the sequences,
reverses the quality scores, and writes all output to the files
'fasta_out_rc_except_last_26' and 'fasta_out_rc_except_last_26.qual'.
The number of input and output contigs is written to STDERR (-v).


DATE LAST MODIFIED: $Date_Last_Modified

EOF
  exit 0;
  } # end display_more_help


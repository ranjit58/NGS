#FILE: random_sequence_sample.pl
#AUTH: Paul Stothard (paul.stothard@gmail.com)
#DATE: May 20, 2008
#VERS: 1.0

#USAGE: perl random-sample-fasta.pl [-arguments]
# -i [FILE]     : file containing sequences in FASTA format (Required).
# -o [FILE]     : output file (Required).
# -n [INTEGER]  : number of sequences to obtain (Required).
# -r            : sample with replacement (Optional. Default is to
#                 sample without replacement).
#
#perl random_sequence_sample.pl -i test/sample_in.fasta -o test/sample_out.fasta -n 10




use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;

my %options = (
    infile          => undef,
    outfile         => undef,
    n               => undef,
    with_replacment => undef
);

GetOptions(
    'i=s' => \$options{infile},
    'o=s' => \$options{outfile},
    'n=i' => \$options{n},
    'r'   => \$options{with_replacement}
);

$options{n} = get_integer( $options{n} );

if (   !( defined( $options{infile} ) )
    or !( defined( $options{outfile} ) )
    or !( defined( $options{n} ) ) )
{
    die( print_usage() . "\n" );
}

open( my $INFILE, $options{infile} )
    or die("Cannot open file '$options{infile}': $!");

#Determine how many sequences are in the input file
my $count = 0;
while (<$INFILE>) {
    if ( $_ =~ m/^>/ ) {
        $count++;
    }
}
close($INFILE) or die("Cannot close file : $!");

if ( ( $count < $options{n} ) && ( !$options{with_replacement} ) ) {
    die("$options{infile} contains less than $options{n} sequences--unable to obtain sample without replacement."
    );
}

#Decide which sequences to sample
my $chosen_count = 0;
my @chosen       = ();
for ( my $i = 0; $i < $count; $i++ ) {
    $chosen[$i] = 0;
}

while ( $chosen_count < $options{n} ) {
    my $random = int( rand($count) );
    if ( $options{with_replacement} ) {
        $chosen[$random]++;
        $chosen_count++;
    }
    elsif ( $chosen[$random] == 0 ) {
        $chosen[$random] = 1;
        $chosen_count++;
    }
}

#Write out sampled sequences
$count = 0;
local $/ = ">";
open( my $OUTFILE, '>', $options{outfile} )
    or die("Cannot open file '$options{outfile}': $!");

open( $INFILE, $options{infile} )
    or die("Cannot open file '$options{infile}': $!");

while (<$INFILE>) {
    if ( $_ =~ m/[^\s>]/ ) {
        my @lines    = split( /\n/, $_ );
        my $title    = $lines[0];
        my $sequence = $_;
        $sequence =~ s/\Q$title\E//;
        $sequence =~ s/[^a-zA-Z]//g;
        while ( $chosen[$count] > 0 ) {
            print {$OUTFILE} ">$title\n$sequence\n";
            $chosen[$count]--;
        }
        $count++;
    }
}
close($INFILE)  or die("Cannot close file : $!");
close($OUTFILE) or die("Cannot close file : $!");

print "Sequences have been written to '$options{outfile}'\n";

sub get_integer {
    my $value = shift;
    my $int   = undef;
    if ( ( defined($value) ) && ( $value =~ m/(\-*\d+)/ ) ) {
        $int = $1;
    }
    return $int;
}

sub print_usage {
    print <<BLOCK;
USAGE: perl random_sequence_sample.pl [-arguments]
 -i [FILE]     : file containing sequences in FASTA format (Required).
 -o [FILE]     : output file (Required).
 -n [INTEGER]  : number of sequences to obtain (Required).
 -r            : sample with replacement (Optional. Default is to
                 sample without replacement).

perl random_sequence_sample.pl -i test/sample_in.fasta \
-o test/sample_out.fasta -n 10
BLOCK
}




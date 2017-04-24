#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage qw(pod2usage);

# parse command line arguments

my $format = 'fasta';
my $file;
my $header = 0;
my $help =0;

GetOptions(
    'f|format:s' => \$format,
    'i|in:s'     => \$file,
    'e|header!' => \$header,
    'h|help|?'    => \$help,
);

# send message error output if no file given or empty STDIN
pod2usage( { -message => "$0: No file given", -exitval => 1, -verbose => 1})
    if ((@ARGV == 0) && (-t STDIN));

use Bio::SeqIO;
use Bio::Tools::SeqStats;

# define file as first argument if no file explicitly given
$file = shift unless $file;

# send error message if file given does not exists
my $seqin;
if ( defined $file ) {
    pod2usage("Could not open file [$file]\n") and exit unless -e $file;
    $seqin = new Bio::SeqIO(-format => $format, -file => $file);
} else {
    $seqin = new Bio::SeqIO(-format => $format, -fh => \*STDIN);
}


my ($total_base, $total_gc);

# print header if required
if ($header == 1) {
    print "Len\tGC1\tGC2\tGC3\tGC_0\tTotal_length\n";
}

# TODO calculate mean GC content for all CDS
while ( my $seq = $seqin->next_seq ) {
    next if( $seq->length == 0 );
    next if( $seq->length % 3 != 0);
    # check last codon to be a known codon stop
    next if( substr( $seq->seq, -3, 3) !~ /(TAA|TAG|TGA)/);

    my ($gc1, $gc2, $gc3) = calcgc($seq->seq);
    my $seq_stats = Bio::Tools::SeqStats->new('-seq'=>$seq);
    my $hash_ref = $seq_stats->count_monomers(); # for DNA sequence

    $total_base += $seq->length;
    $total_gc   += $hash_ref->{'G'} + $hash_ref->{'C'};

    my $gc_content = $total_gc / $total_base;

    # print $seq->display_id, "\t";
    print $seq->length, "\t";
    printf "%.4f\t%.4f\t%.4f\t%.4f\t", $gc1, $gc2, $gc3, $gc_content;
    print $total_base, "\n";
}

sub calcgc {
    my $seq = $_[0];
    my @seqarray = split('',$seq);
    my ($count, $gc1, $gc2, $gc3) = 0;

    if (length($seq) % 3 == 0) {
        for (my $i = 0; $i <= $#seqarray - 2; $i += 3) {
            $gc1++ if $seqarray[$i] =~ /[G|C]/i;
            $gc2++ if $seqarray[$i + 1] =~ /[G|C]/i;
            $gc3++ if $seqarray[$i + 2] =~ /[G|C]/i;
        }
    }

    my $len = $#seqarray + 1;
    $gc1 = $gc1 / ($len / 3);
    $gc2 = $gc2 / ($len / 3);
    $gc3 = $gc3 / ($len / 3);

    return ($gc1, $gc2, $gc3);
}


__END__

=head1 NAME

gc_contents - GC content of nucleotide sequences

=head1 SYNOPSIS

  -f  --format      format of file in input, defaults to FASTA
  -i  --in          input file.
  -e  --header      prints description of columns. defaults to false
      --no-header
  -h  --help        Print this help message.

=head1 DESCRIPTION

This scripts prints out the GC content for every nucleotide sequence
from the input file.

=head1 OPTIONS

The default sequence format is fasta.

The sequence input can be provided using any of the three methods:

=over 3

=item unnamed argument

  gc_contents filename

=item named argument

  gc_contents -i filename

=item standard input

  gc_contents < filename

=back

=head1 AUTHOR - Samuel Barreto


=cut

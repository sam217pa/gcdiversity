#!/usr/bin/env perl -w
# get_codon.pl --- extract N codon position from fasta sequence
# Author: Samuel Barreto <samuel.barreto8@gmail.com>
# Created: 24 Apr 2017
# Version: 0.01

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage qw(pod2usage);

my $position;
my $file;

GetOptions(
    'n|position=i' => \$position,
    'i|in:s'       => \$file,
);

# send message error output if no file given or empty STDIN
pod2usage( { -message => "$0: No file given", -exitval => 1, -verbose => 1})
    if ((@ARGV == 0) && (-t STDIN));

$file = shift unless $file;

pod2usage("Position should be between 0 and 2.") if $position !~ /[0-2]/;

use Bio::SeqIO;

# $file = shift unless $file;

# send error message if file given does not exists
my $seqin;
if ( defined $file ) {
    pod2usage("Could not open file [$file]\n") and exit unless -e $file;
    $seqin = new Bio::SeqIO(-format => "fasta", -file => $file);
} else {
    $seqin = new Bio::SeqIO(-format => "fasta", -fh => \*STDIN);
}

my $seq_out = Bio::SeqIO->new( -fh => \*STDOUT, -format => "fasta");

my $elim = 0;

while ( my $seq = $seqin->next_seq ) {
    if ( $seq->length == 0 ||
             $seq->length % 3 != 0 ||
             substr($seq->seq, -3, 3) !~ /(TAA|TAG|TGA)/
         ) {
        $elim++;
        next;
    }

    my @seqarray = split('', $seq->seq);
    my $_seqout;

    for (my $i = $position; $i <= $#seqarray - 2; $i += 3) {
        $_seqout .= $seqarray[$i];
    }

    print STDOUT ">" . $seq->id . "\n" . $_seqout . "\n";
}

print STDERR "Number of removed sequences: $elim \n";

__END__

=head1 NAME

get_codon.pl - Describe the usage of script briefly

=head1 SYNOPSIS

get_codon.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for get_codon.pl,

=head1 AUTHOR

Samuel Barreto, E<lt>samuel.barreto8@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Samuel Barreto

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

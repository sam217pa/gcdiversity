#!/usr/bin/env perl -w
# filter-seq.pl --- filter sequences with length multiple of 3 and good ending codons
# Author: Samuel Barreto <samuel.barreto8@gmail.com>
# Created: 24 Apr 2017
# Version: 0.01

use warnings;
use strict;

use Bio::SeqIO;

my $file = shift;

my $seqin;
if ( defined $file ) {
    pod2usage("Could not open file [$file]\n") and exit unless -e $file;
    $seqin = new Bio::SeqIO(-format => "fasta", -file => $file);
} else {
    $seqin = new Bio::SeqIO(-format => "fasta", -fh => \*STDIN);
}

my $seq_out = Bio::SeqIO->new( -fh => \*STDOUT, -format => "fasta");


while ( my $seq = $seqin->next_seq ) {
    next if( $seq->length == 0 );
    next if( $seq->length % 3 != 0);
    # check last codon to be a known codon stop
    next if( substr( $seq->seq, -3, 3) !~ /(TAA|TAG|TGA)/);

    $seq_out->write_seq($seq);
}

__END__

=head1 NAME

filter-seq.pl - Describe the usage of script briefly

=head1 SYNOPSIS

filter-seq.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for filter-seq.pl,

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

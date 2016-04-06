#!/usr/bin/perl

use strict;
use warnings;

package Spelling;

=pod

NAME B<Spelling> -

Spell checker based on Peter Norvigs code on http://norvig.com/spell-correct.html

=cut

our $NWORDS;
our @DICT;
our @alphabet = split //, 'abcdefghijklmnopqrstuvwxyz';

sub train
{
    my $filename = shift;
    open IN, $filename or die "Cannot open $filename: $!";
    while(<IN>) {
        chomp;
        foreach my $word (words($_)) {
            $NWORDS->{$word}++;
        }
    }
    close IN;
    @DICT = keys %$NWORDS;
    print "Learned ", scalar @DICT, " words\n";
}

sub words
{
    return map { split /[^a-z0-9]+/, lc $_} @_;
}

sub uniq
{
    my %cnt;
    return grep { ! $cnt{$_}++ } @_;
}

sub known
{
    return grep { $NWORDS->{$_} } @_;
}

sub edits1
{
    my $word = shift;
    my $n = length($word);
    my @edits;
    foreach (0..$n-1) { push @edits, substr($word, 0, $_) . substr($word, $_+1) };
    foreach (0..$n-2) { push @edits, substr($word, 0, $_) . substr($word, $_+1, 1) . substr($word, $_, 1) . substr($word, $_+2) };
    foreach my $c (@alphabet) { push @edits, map { substr($word, 0, $_). $c . substr($word, $_+1) } (0..$n-1) };
    foreach my $c (@alphabet) { push @edits, map { substr($word, 0, $_). $c . substr($word, $_) } (0..$n-1) };
    return uniq @edits;
}

sub edits2
{
    my $word = shift;
    return uniq map { edits1($_) } edits1($word);
}

sub dict
{
    return \@DICT;
}

sub mistakes
{
    shift;
    return grep { ! known($_) } words shift;
}

sub correct
{
    shift;
    my $word = shift;
    my @canidates;
    @canidates = known($word) or @canidates = known(edits1($word)) or @canidates = known(edits2($word)) or @canidates = qw($word);
    @canidates = sort { $NWORDS->{$b} <=> $NWORDS->{$a} } @canidates;
    return $canidates[0];
}

1;


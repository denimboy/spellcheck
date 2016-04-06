#!/usr/bin/perl

use strict;
use warnings;

package Spelling;

=pod

NAME B<Spelling> -

Spell checker based on Peter Norvigs code on http://norvig.com/spell-correct.html

=cut

our @alphabet = split //, 'abcdefghijklmnopqrstuvwxyz';

sub new
{
    my ($class) = @_;
    my $self = {};
    $self->{'NWORDS'} = {};
    bless $self, $class;
}

sub nwords
{
    my ($self) = @_;
    return $self->{'NWORDS'};
}

sub train
{
    my ($self, $filename) = @_;
    open IN, $filename or die "Cannot open $filename: $!";
    while(<IN>) {
        chomp;
        foreach my $word (words($_)) {
            $self->{'NWORDS'}->{$word}++;
        }
    }
    close IN;
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
    my ($self) = @_;
    return grep { $self->{'NWORDS'}->{$_} } @_;
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

sub correct
{
    my ($self, $word) = @_;
    my @canidates;
    @canidates = known($word) or @canidates = known(edits1($word)) or @canidates = known(edits2($word)) or @canidates = qw($word);
    @canidates = sort { $self->{'NWORDS'}->{$b} <=> $self->{'NWORDS'}->{$a} } @canidates;
    return $canidates[0];
}

1;


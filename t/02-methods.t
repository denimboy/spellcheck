#!/usr/bin/perl                                                                                                                                                                  

use strict;
use warnings;

use Test::More;

my $pkg = 'Spelling';
use_ok($pkg);

my $spell;
{
    $spell = Spelling->new();
    ok(defined $spell, "$pkg new() returns something") || diag("Actual: ", $spell);
    ok(ref $spell, "$pkg new() returns ref") || diag("Actual: ", $spell);
    ok(defined $spell->nwords, "$pkg nwords returns something") || diag("Actual: ", $spell);
    is(ref $spell->nwords, 'HASH', "$pkg nwords returns hashref") || diag("Actual: ", $spell);
}

{
    is(scalar keys %{$spell->nwords}, 0, "$pkg nwords is empty");
    $spell->train('big.txt');
    ok(scalar keys %{$spell->nwords}, "$pkg nwords has been filled")
}

done_testing;

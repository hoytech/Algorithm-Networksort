# This test checks bitonic networks in uni-directional (normal,
# arrowless) format.

use strict;

use Test::Simple tests => 6;

use Algorithm::Networksort qw(:all);

require "t/zero_one.pl";

my $algorithm = 'bitonic';
my @network;
my $status;

for my $inputs (4..9)
{
	my @bi_network = nw_comparators($inputs, algorithm=>$algorithm);
	my $bi_network_ref = make_network_unidirectional(\@bi_network);
	my @uni_network = @$bi_network_ref;

	$status = zero_one($inputs, \@uni_network);
	if ($status eq "pass")
	{
		ok(1, "$algorithm, N=$inputs");
	}
	else
	{
		ok(0, "$algorithm, N=$inputs, $status");
	}
}


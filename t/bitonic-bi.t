# This test checks bitonic networks in bi-directional (up and down
# arrows) format.

use strict;

use Test::Simple tests => 6;

use Algorithm::Networksort qw(:all);

require "t/zero_one.pl";

my $algorithm = 'bitonic';
my @network;
my $status;

for my $inputs (4..9)
{
	@network = nw_comparators($inputs, algorithm=>$algorithm);

	$status = zero_one($inputs, \@network);
	if ($status eq "pass")
	{
		ok(1, "$algorithm, N=$inputs");
	}
	else
	{
		ok(0, "$algorithm, N=$inputs, $status");
	}
}


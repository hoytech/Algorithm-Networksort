use Test::Simple tests => 7;

use Algorithm::Networksort qw(:all);

sub count_stages {
	my ($algorithm, $n) = @_;

	my @network = nw_comparators($n, algorithm => $algorithm);
	my @stages = nw_stages(\@network, $n);
	return scalar @stages;
}


ok(count_stages('bubble', 2) == 1, 'bubble 2');
ok(count_stages('bubble', 3) == 3, 'bubble 3');
ok(count_stages('bubble', 4) == 5, 'bubble 4');
ok(count_stages('bubble', 10) == 17, 'bubble 10');

ok(count_stages('batcher', 3) == 3, 'batcher 3');
ok(count_stages('batcher', 4) == 3, 'batcher 4');
ok(count_stages('batcher', 18) == 13, 'batcher 18');

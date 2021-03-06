package Algorithm::Networksort;

use 5.008003;

use integer;
use Carp;
use Exporter;
use vars qw(@ISA %EXPORT_TAGS @EXPORT_OK);
use strict;
use warnings;

#
# Three # for "I am here" messages, four # for variable dumps.
# Five # for nw_sort tracking.
#
#use Smart::Comments q(####);

@ISA = qw(Exporter);

%EXPORT_TAGS = (
	'all' => [ qw(
		nw_algorithms
		nw_algorithm_name
		nw_color
		nw_graph
		nw_group
		nw_comparators
		nw_format
		nw_sort
	) ],
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '1.30';

#
# Names for the algorithm keys.
#
my %algname = (
	bosenelson => "Bose-Nelson Sort",
	batcher => "Batcher's Mergesort",
	hibbard => "Hibbard's Sort",
	bubble => "Bubble Sort",
	bitonic => "Bitonic Sort",
	oddeventransposition => "Odd-Even Transposition Sort",
	balanced => "Balanced",
	oddevenmerge => "Batcher's Odd-Even Merge Sort",
);

#
# Parameters for SVG and EPS graphing.
#
my %graphset = (
	hz_sep => 12,
	hz_margin => 18,
	vt_sep => 12,
	vt_margin => 21,
	indent => 9,
	stroke_width => 2,
	title => undef,
	namespace => undef,
);

#
# Color parameters.
#
my %colorset = (
	foreground => undef,
	inputbegin => undef,
	inputline => undef,
	inputend => undef,
	compline=> undef,
	compbegin => undef,
	compend => undef,
	background => undef,
);

#
# Parameters for text 'graphing'.
#
my %textset = (
	inputbegin => "o-",
	inputline => "---",
	inputcompline => "-|-",
	inputend => "-o\n",
	compbegin => "-^-",
	compend => "-v-",
	gapbegin => "  ",
	gapcompline => " | ",
	gapnone => "   ",
	gapend => "  \n",
);

#
# Variables to track sorting statistics
#
my $swaps = 0;


#
# @algkeys = nw_algorithms();
#
# Return a list algorithm choices. Each one is a valid key
# for the nw_comparators() algorithm key.
#
sub nw_algorithms
{
	return keys %algname;
}

#
# nw_algorithm_name();
#
# Return the text-worthy name of the algorithm, given its key name.
#
sub nw_algorithm_name
{
	my $alg = shift;
	return $algname{$alg} if (defined $alg);
	return undef;
}

#
# @network = nw_comparators($input, %options);
#
# The function that starts it all.  Return a list of comparators (a
# two-item list) that will sort an n-item list.
#
sub nw_comparators
{
	my $inputs = shift;
	my %opts = @_;
	my @comparators;

	#
	### Generating the comparators...
	#
	#### $inputs
	#### %opts
	#
	return () if ($inputs < 2);
	return ([0, 1]) if ($inputs == 2);

	$opts{algorithm} = 'bosenelson' unless (defined $opts{algorithm});
	$opts{grouping} = 'none' unless (defined $opts{grouping});

	unless (exists $algname{$opts{algorithm}})
	{
		carp "Unknown algorithm '", $opts{algorithm}, "'\n";
		return ();
	}

	@comparators = bosenelson($inputs) if ($opts{algorithm} eq 'bosenelson');
	@comparators = hibbard($inputs) if ($opts{algorithm} eq 'hibbard');
	@comparators = batcher($inputs) if ($opts{algorithm} eq 'batcher');
	@comparators = bitonic($inputs) if ($opts{algorithm} eq 'bitonic');
	@comparators = bubble($inputs) if ($opts{algorithm} eq 'bubble');
	@comparators = oddeventransposition($inputs) if ($opts{algorithm} eq 'oddeventransposition');
	@comparators = balanced($inputs) if ($opts{algorithm} eq 'balanced');
	@comparators = oddevenmerge($inputs) if ($opts{algorithm} eq 'oddevenmerge');

	#
	# Instead of using the list as provided by the algorithms,
	# re-order it using the grouping for the graphs. This makes
	# use of parallelism (and less stalling when used in a pipeline).
	#
	if ($opts{grouping} eq 'group' or $opts{grouping} eq 'parallel')
	{
		my @grouped_comparators = nw_group(\@comparators, $inputs,
				grouping => $opts{grouping});
		@comparators = ();
		foreach my $group (@grouped_comparators)
		{
			push @comparators, @$group;
		}
	}

	return @comparators;
}

#
# @network = hibbard($inputs);
#
# Return a list of two-element lists that comprise the comparators of a
# sorting network.
#
# Translated from the ALGOL listed in T. N. Hibbard's article, A Simple
# Sorting Algorithm, Journal of the ACM 10:142-50, 1963.
#
# The ALGOL code was overly dependent on gotos.  This has been changed.
#
sub hibbard
{
	my $inputs = shift;
	my @comparators;
	my($bit, $xbit, $ybit);

	#
	# $t = ceiling(log2($inputs - 1)); but we'll
	# find it using the length of the bitstring.
	#
	my $t = unpack("B32", pack("N", $inputs - 1));
	$t =~ s/^0+//;
	$t = length $t;

	my $lastbit = 1 << $t;

	#
	# $x and $y are the comparator endpoints.
	# We begin with values of zero and one.
	#
	my($x, $y) = (0, 1);

	while (1 == 1)
	{
		#
		# Save the comparator pair, and calculate the next
		# comparator pair.
		#
		### hibbard() top of loop:
		#### @comparators
		#
		push @comparators, [$x, $y];

		#
		# Start with a check of X and Y's respective bits,
		# beginning with the zeroth bit.
		#
		$bit = 1;
		$xbit = $x & $bit;
	 	$ybit = $y & $bit;

		#
		# But if the X bit is 1 and the Y bit is
		# zero, just clear the X bit and move on.
		#
 		while ($xbit != 0 and $ybit == 0)
		{
			$x &= ~$bit;

			$bit <<= 1;
			$xbit = $x & $bit;
	 		$ybit = $y & $bit;
		}

 		if ($xbit != 0)		#  and $ybit != 0
		{
			$y &= ~$bit;
			next;
		}

		#
		# The X bit is zero if we've gotten this far.
		#
 		if ($ybit == 0)
		{
			$x |= $bit;
			$y |= $bit;
			$y &= ~$bit if ($y > $inputs - 1);
			next;
		}

		#
		# The X bit is zero, the Y bit is one, and we might
		# return the results.
		#
		do
		{
			return @comparators if ($bit == $lastbit);

			$x &= ~$bit;
			$y &= ~$bit;

			$bit <<= 1;	# Next bit.

			if ($y & $bit)
			{
				$x &= ~$bit;
				next;
			}

			$x |= $bit;
			$y |= $bit;
		} while ($y > $inputs - 1);

		#
		# No return, so loop onwards.
		#
		$bit = 1 if ($y < $inputs - 1);
		$x &= ~$bit;
		$y |= $bit;
	}
}

#
# @network = bosenelson($inputs);
#
# Return a list of two-element lists that comprise the comparators of a
# sorting network.
#
# The Bose-Nelson algorithm.
#
sub bosenelson
{
	my $inputs = shift;

	return bn_split(0, $inputs);
}

#
# @comparators = bn_split($i, $length);
#
# The helper function that divides the range to be sorted.
#
# Note that the work of splitting the ranges is performed with the
# 'length' variables.  The $i variable merely acts as a starting
# base, and could easily have been 1 to begin with.
#
sub bn_split
{
	my($i,  $length) = @_;
	my @comparators = ();

	#
	### bn_split():
	#### $i
	#### $length
	#

	if ($length >= 2)
	{
		my $mid = $length/2;

		push @comparators, bn_split($i, $mid);
		push @comparators, bn_split($i + $mid, $length - $mid);
		push @comparators, bn_merge($i, $mid, $i + $mid, $length - $mid);
	}

	#
	### bn_split() returns
	#### @comparators
	#
	return @comparators;
}

#
# @comparators = bn_merge($i, $length_i, $j, $length_j);
#
# The other helper function that adds comparators to the list, for a
# given pair of ranges.
#
# As with bn_split, the different conditions all depend upon the
# lengths of the ranges.  The $i and $j variables merely act as
# starting bases.
#
sub bn_merge
{
	my($i, $length_i, $j, $length_j) = @_;
	my @comparators = ();

	#
	### bn_merge():
	#### $i
	#### $length_i
	#### $j
	#### $length_j
	#
	if ($length_i == 1 && $length_j == 1)
	{
		push @comparators, [$i, $j];
	}
	elsif ($length_i == 1 && $length_j == 2)
	{
		push @comparators, [$i, $j + 1];
		push @comparators, [$i, $j];
	}
	elsif ($length_i == 2 && $length_j == 1)
	{
		push @comparators, [$i, $j];
		push @comparators, [$i + 1, $j];
	}
	else
	{
		my $i_mid = $length_i/2;
		my $j_mid = ($length_i & 1)? $length_j/2: ($length_j + 1)/2;

		push @comparators, bn_merge($i, $i_mid, $j, $j_mid);
		push @comparators, bn_merge($i + $i_mid, $length_i - $i_mid, $j + $j_mid, $length_j - $j_mid);
		push @comparators, bn_merge($i + $i_mid, $length_i - $i_mid, $j, $j_mid);
	}

	#
	### bn_merge() returns
	#### @comparators
	#
	return @comparators;
}

#
# @network = batcher($inputs);
#
# Return a list of two-element lists that comprise the comparators of a
# sorting network.
#
# Batcher's sort as laid out in Knuth, Sorting and Searching, algorithm 5.2.2M.
#
sub batcher
{
	my $inputs = shift;
	my @network;

	#
	# $t = ceiling(log2($inputs)); but we'll
	# find it using the length of the bitstring.
	#
	my $t = unpack("B32", pack("N", $inputs));
	$t =~ s/^0+//;
	$t = length $t;

	my $p = 1 << ($t -1);

	while ($p > 0)
	{
		my $q = 1 << ($t -1);
		my $r = 0;
		my $d = $p;

		while ($d > 0)
		{
			for my $i (0 .. $inputs - $d - 1)
			{
				push @network, [$i, $i + $d] if (($i & $p) == $r);
			}

			$d = $q - $p;
			$q >>= 1;
			$r = $p;
		}
		$p >>= 1;
	}

	return @network;
}



#
# @network = bitonic($inputs);
#
# Return a list of two-element lists that comprise the comparators of a
# sorting network.
#
# Batcher's Bitonic sort as described here:
# http://www.iti.fh-flensburg.de/lang/algorithmen/sortieren/bitonic/oddn.htm
#
sub bitonic
{
	my $inputs = shift;
	my @network;

	my ($sort, $merge);

	$sort = sub {
		my ($lo, $n, $dir) = @_;

		if ($n > 1) {
			my $m = $n/2;
			$sort->($lo, $m, !$dir);
			$sort->($lo + $m, $n - $m, $dir);
			$merge->($lo, $n, $dir);
		}
	};

	$merge = sub {
		my ($lo, $n, $dir) = @_;

		if ($n > 1) {
			#
			# $t = ceiling(log2($n - 1)); but we'll
			# find it using the length of the bitstring.
			#
			my $t = unpack("B32", pack("N", $n - 1));
			$t =~ s/^0+//;
			$t = length $t;

			my $m = 1 << ($t - 1);

			for my $i ($lo .. $lo+$n-$m-1)
			{
				push @network, ($dir)? [$i, $i+$m]: [$i+$m, $i];
			}

			$merge->($lo, $m, $dir);
			$merge->($lo + $m, $n - $m, $dir);
		}
	};

	$sort->(0, $inputs, 1);

	return @{ make_network_unidirectional(\@network) };
}


## This function "re-wires" a bi-directional sorting network
## and turns it into a normal, uni-directional network.

sub make_network_unidirectional
{
	my ($network_ref) = @_;

	my @network = @$network_ref;

	foreach my $i (0..$#network) {
		my $comparator = $network[$i];
		my ($x, $y) = @$comparator;

		if ($x > $y) {
			foreach my $j (($i+1)..$#network) {
				my $j_comparator = $network[$j];
				my ($j_x, $j_y) = @$j_comparator;

				$j_comparator->[0] = $y if $x == $j_x;
				$j_comparator->[1] = $y if $x == $j_y;
				$j_comparator->[0] = $x if $y == $j_x;
				$j_comparator->[1] = $x if $y == $j_y;
			}
			($comparator->[0], $comparator->[1]) = ($comparator->[1], $comparator->[0]);
		}
	}

	return \@network;
}

#
# @network = bubble($inputs);
#
# Simple bubble sort network, only for comparison purposes.
#
sub bubble
{
	my $inputs = shift;
	my @network;

	for my $j (reverse 0 .. $inputs - 1)
	{
		push @network, [$_, $_ + 1] for (0 .. $j - 1);
	}

	return @network;
}

#
# @network = bubble($inputs);
#
# Simple odd-even transposition network, only for comparison purposes.
#
sub oddeventransposition {
	my $inputs = shift;
	my @network;

	my $odd;

	for my $stage (0 .. $inputs - 1)
	{
		for (my $j = $odd ? 1 : 0; $j < $inputs - 1; $j += 2)
		{
			push @network, [$j, $j+1];
		}

		$odd = !$odd;
	}

	return @network;
}

#
# @network = balanced($inputs);
#
# "The Balanced Sorting Network" by M. Dowd, Y. Perl, M Saks, and L. Rudolph
# ftp://ftp.cs.rutgers.edu/cs/pub/technical-reports/pdfs/DCS-TR-127.pdf
#
sub balanced {
	my $inputs = shift;
	my @network;

	#
	# $t = ceiling(log2($inputs - 1)); but we'll
	# find it using the length of the bitstring.
	#
	my $t = unpack("B32", pack("N", $inputs - 1));
	$t =~ s/^0+//;
	$t = length $t;

	for (1 .. $t)
	{
		for (my $curr = 2**($t); $curr > 1; $curr /= 2)
		{
			for (my $i = 0; $i < 2**$t; $i += $curr)
			{
				for (my $j = 0; $j < $curr/2; $j++)
				{
					my $wire1 = $i+$j;
					my $wire2 = $i+$curr-$j-1;
					push @network, [$wire1, $wire2]
						if $wire1 < $inputs && $wire2 < $inputs;
				}
			}
		}
	}

	return @network;
}


#
# @network = oddevenmerge($inputs);
#
# Batcher's odd-even merge sort as described here:
# http://www.iti.fh-flensburg.de/lang/algorithmen/sortieren/networks/oemen.htm
# http://cs.engr.uky.edu/~lewis/essays/algorithms/sortnets/sort-net.html
#
sub oddevenmerge {
	my $inputs = shift;
	my @network;

	#
	# $t = ceiling(log2($inputs - 1)); but we'll
	# find it using the length of the bitstring.
	#
	my $t = unpack("B32", pack("N", $inputs - 1));
	$t =~ s/^0+//;
	$t = length $t;

	my ($add_elem, $sort, $merge);

	$add_elem = sub {
		my ($i, $j) = @_;

		push @network, [$i, $j]
			if $i < $inputs && $j < $inputs;
	};

	$sort = sub {
		my ($lo, $n) = @_;

		if ($n > 1)
		{
			my $m = int($n / 2);

			$sort->($lo, $m);
			$sort->($lo + $m, $m);
			$merge->($lo, $n, 1);
		}
	};

	$merge = sub {
		my ($lo, $n, $r) = @_;

		my $m = int($r * 2);

		if ($m < $n)
		{
			$merge->($lo, $n, $m); # even
			$merge->($lo + $r, $n, $m); # odd

			for (my $i=$lo + $r; $i + $r < $lo + $n; $i += $m)
			{
				$add_elem->($i, $i + $r);
			}
		}
		else
		{
			$add_elem->($lo, $lo + $r);
		}
	};

	$sort->(0, 2**$t);

	return @network;
}

#
# $array_ref = nw_sort(\@network, \@array);
#
# Use the network of comparators (in @network) to sort the elements
# in @array.  Returns the reference to the array, which is sorted
# in-place.
#
# This function is for testing purposes only, interpreting sorting
# pairs ad hoc in an interpreted language is going to be very slow.
#
sub nw_sort
{
	my($network, $array) = @_;

	#
	### nw_sort():
	#### $network
	#### $array
	#

	#
	# Variable $swaps is a global variable that reports back the
	# number of exchanges.
	#
	$swaps = 0;
	foreach my $comparator (@$network)
	{
		my($left, $right) = @$comparator;

		if (($$array[$left] <=> $$array[$right]) == 1)
		{
			@$array[$left, $right] = @$array[$right, $left];
			$swaps++;
		}

		#
		##### @$array
		#
	}

	return $array;
}

#
# %sortstats = nw_sort_stats();
#
# Return information on the sorting network.
#
sub nw_sort_stats
{
	return (swaps => $swaps,
		);
}

#
# $string = nw_format(\@network, $cmp_format, $swap_format, \@index_base);
#
# Return a string that represents the comparators.  Default format is
# an array of arrays, in standard perl form
#
sub nw_format
{
	my($network, $cmp_format, $swap_format, $index_base) = @_;
	my $string = '';

	if (scalar @$network == 0)
	{
		carp "No network to format.\n";
		return "";
	}

	if (defined $cmp_format)
	{
		foreach my $comparator(@$network)
		{
			@$comparator = @$index_base[@$comparator] if (defined $index_base);

			$string .= sprintf($cmp_format, @$comparator);
			$string .= sprintf($swap_format, @$comparator) if ($swap_format);
		}
	}
	else
	{
		$string = '[';
		foreach my $comparator (@$network)
		{
			@$comparator = @$index_base[@$comparator] if (defined $index_base);

			$string .= "[" . join(",", @$comparator) . "],";
		}

		substr($string, -1, 1) = "]";
	}

	return $string;
}

#
# @new_grouping = nw_group(\@network, $inputs);
#
# Take a list of comparators, and transform it into a list of a list of
# comparators, each sub-list representing a group that can be printed
# in a single column.  This makes it easier for the nw_graph routines to
# render a visual representation of the sorting network.
#
sub nw_group
{
	my $network = shift;
	my $inputs = shift;
	my %opts = @_;

	my @node_range_stack;
	my @node_stack;

	#
	# Group the comparator nodes into columns.
	#
	foreach my $comparator (@$network)
	{
		my($from, $to) = @$comparator;

		#
		# How much of a column becomes untouchable depends upon whether
		# we are trying to print out comparators in a single column, or
		# whether we are just trying to arrange comparators in a single
		# column without concern for overlap.
		#
		my @range = (exists $opts{grouping} and $opts{grouping} eq "parallel")?
				($from, $to):
				($from..$to);
		my $col = scalar @node_range_stack;

		#
		# Search back through the stack of columns to see if
		# we can fit the comparator in an existing column.
		#
		while (--$col >= 0)
		{
			last if (grep{$_ != 0} @{$node_range_stack[$col]}[@range]);
		}

		#
		# If even the top column can't fit it in, make a
		# new, empty top.
		#
		if (++$col == scalar(@node_range_stack))
		{
			push @node_range_stack, [(0) x $inputs];
		}

		@{$node_range_stack[$col]}[@range] = (1) x (scalar @range);

		#
		# Autovivification creates the [$col] array element
		# if it doesn't currently exist.
		#
		push @{$node_stack[$col]}, $comparator;
	}

	#push @node_stack, [sort {${$a}[0] <=> ${$b}[0]} splice @nodes, 0] if (@nodes);
	return @node_stack;
}

#
# %colors = nw_color(%coloroptions);
#
# Sets the colors for the graphical format of the sorting network.
# Returns a hash of the resulting set.
#
sub nw_color
{
	my %color_opts = @_;

	foreach my $key (keys %color_opts)
	{
		$colorset{$key} = $color_opts{$key} if (exists $color_opts{$key});
	}
	return %colorset;
}

#
# %svg_colorset = svg_color();
#
# Return the full list of colors used to make the SVG output.
#
# The default color for drawing is the foreground color.  Use
# it to fill in any unspecified colors in our local colorset.
#
sub svg_color
{
	my $dclr = (defined $colorset{foreground})? $colorset{foreground}: 'black';
	return map{$_ => (defined $colorset{$_})?
	    $colorset{$_}:
	    $dclr} keys %colorset;
}

sub text_segments
{
	my %print_opts = @_;

	return map{$_ => (defined $print_opts{$_})?
	    $print_opts{$_}:
	    $textset{$_}} keys %textset;
}

sub graph_segments
{
	my %print_opts = @_;

	return map{$_ => (defined $print_opts{$_})?
	    $print_opts{$_}:
	    $graphset{$_}} keys %graphset;
}

#
# Set up the horizontal coordinates.
#
sub hz_coords
{
	my($columns, %grset) = @_;

	my @hcoord = ($grset{hz_margin} + $grset{indent}) x $columns;

	for my $idx (0..$columns-1)
	{
		$hcoord[$idx] += $idx * ($grset{hz_sep} + $grset{stroke_width});
	}

	return @hcoord;
}

#
# Set up the vertical coordinates.
#
sub vt_coords
{
	my($inputs, %grset) = @_;

	my @vcoord = ($grset{vt_margin}) x $inputs;

	for my $idx (0..$inputs-1)
	{
		$vcoord[$idx] += $idx * ($grset{vt_sep} + $grset{stroke_width});
	}

	return @vcoord;
}

#
# $string = nw_graph(\@network, $inputs, %options);
#
# Returns a string that contains the sorting network in a graphical format.
#
sub nw_graph
{
	my($network, $inputs, %print_opts) = @_;

	if (scalar @$network == 0)
	{
		carp "No network to graph.\n";
		return "";
	}

	#
	# Text graph by default.
	#
	return nw_text_graph($network, $inputs, text_segments(%print_opts))
	    if (!exists $print_opts{graph} or $print_opts{graph} eq "text");


	return nw_svg_graph($network, $inputs, graph_segments(%print_opts))
	    if ($print_opts{graph} eq "svg");

	return nw_eps_graph($network, $inputs, graph_segments(%print_opts))
	    if ($print_opts{graph} eq "eps");

	carp "Unknown 'graph' type '" . $print_opts{graph} . "'.\n";
	return "";
}

#
# $string = nw_eps_graph(\@network, $inputs, %graphing_options);
#
# Returns a string that contains the sorting network in an EPS format.
#
sub nw_eps_graph
{
	my($network, $inputs, %grset) = @_;

	my @node_stack = nw_group($network, $inputs);
	my $columns = scalar @node_stack;

	#
	# Set up the vertical and horizontal coordinates.
	#
	my @vcoord = vt_coords($inputs, %grset);
	my @hcoord = hz_coords($columns, %grset);

	my $xbound = $hcoord[$columns - 1] + $grset{hz_margin} + $grset{indent};
	my $ybound = $vcoord[$inputs - 1] + $grset{vt_margin};
	my $title = $grset{title} || "N = $inputs Sorting Network.";

	#
	# A long involved piece to create the necessary DSC, the subroutine
	# definitions, arrays of vertical and horizontal coordinates, and
	# left and right margin definitions.
	#
	my $string =
		qq(%!PS-Adobe-3.0 EPSF-3.0\n%%BoundingBox: 0 0 $xbound $ybound\n%%CreationDate: ) .
		localtime() .
		qq(\n%%Creator: perl module ) . __PACKAGE__ . qq( version $VERSION.) .
		qq(\n%%Title: $title\n%%Pages: 1\n%%EndComments\n%%Page: 1 1\n) .
q(
% column inputline1 inputline2 draw-comparatorline
/draw-comparatorline {
    vcoord exch get 3 1 roll vcoord exch get
    3 1 roll hcoord exch get 3 1 roll 2 index exch % x1 y1 x1 y2
    newpath 2 copy currentlinewidth 0 360 arc gsave stroke grestore fill moveto
    2 copy lineto stroke currentlinewidth 0 360 arc gsave stroke grestore fill
} bind def

% inputline draw-inputline
/draw-inputline {
    vcoord exch get leftmargin exch dup rightmargin exch % x1 y1 x2 y1
    newpath 2 copy currentlinewidth 0 360 arc moveto
    2 copy lineto currentlinewidth 0 360 arc stroke
} bind def

) .
		"/vcoord [" .
		join("\n    ", semijoin(' ', 16, @vcoord)) . "] def\n/hcoord [" .
		join("\n    ", semijoin(' ', 16, @hcoord)) . "] def\n\n" .
		"/leftmargin $grset{hz_margin} def\n/rightmargin " .
		($xbound - $grset{hz_margin}) . " def\n\n";

	#
	# Save the current graphics state, then change the default line width,
	# and the drawing coordinates from (0,0) = lower left to an upper left
	# origin.
	#
	$string .= "gsave\n$grset{stroke_width} setlinewidth\n0 $ybound translate\n1 -1 scale\n";

	#
	# Draw the input lines.
	#
	$string .= "\n%\n% Draw the input lines.\n%\n0 1 " . ($inputs-1) . " {draw-inputline} for\n";

	#
	# Draw our comparators.
	# Each member of a group of comparators is drawn in the same column.
	#
	$string .= "\n%\n% Draw the comparator lines.\n%\n";
	my $hidx = 0;
	for my $group (@node_stack)
	{
		for my $comparator (@$group)
		{
			$string .= sprintf("%d %d %d draw-comparatorline\n", $hidx, @$comparator);
		}
		$hidx++;
	}

	$string .= "showpage\ngrestore\n% End of the EPS graph.";
	return $string;
}

#
# $string = nw_svg_graph(\@network, $inputs, %graphing_options);
#
# Return a graph of the sorting network in Scalable Vector Graphics.
# Measurements are in pixels. 0,0 is the upper left corner.
#
sub nw_svg_graph
{
	my($network, $inputs, %grset) = @_;

	my @node_stack = nw_group($network, $inputs);
	my $columns = scalar @node_stack;

	#
	# Get the colorset, using the foreground color as the default color
	# for drawing.
	#
	my %clrset = svg_color();
	my $ns =  (defined $grset{namespace})? $grset{namespace} . ":" : "";

	#
	# Set up the vertical and horizontal coordinates.
	#
	my @vcoord = vt_coords($inputs, %grset);
	my @hcoord = hz_coords($columns, %grset);

	my $xbound = $hcoord[$columns - 1] + $grset{hz_margin} + $grset{indent};
	my $ybound = $vcoord[$inputs - 1] + $grset{vt_margin};

	my $right_margin = $hcoord[$columns - 1] + $grset{indent};
	my $title = $grset{title} || "N = $inputs Sorting Network.";

	my $string = qq(<svg xmlns="http://www.w3.org/2000/svg" ) .
		qq(xmlns:xlink="http://www.w3.org/1999/xlink" ) .
		qq(width="$xbound" height="$ybound" viewbox="0 0 $xbound $ybound">\n) .
		qq(  <${ns}desc>\n    CreationDate: ) . localtime() .
		qq(\n    Creator: perl module ) . __PACKAGE__ .
		qq( version $VERSION.\n  </${ns}desc>\n) .
		qq(  <${ns}title>$title</${ns}title>\n);

	#
	# Set up the input line template.
	#
	my $b_clr = "stroke:$clrset{inputbegin}";
	my $l_clr = "stroke:$clrset{inputline}";
	my $e_clr = "stroke:$clrset{inputend}";

	$string .=
		qq(  <${ns}defs>\n) .
		qq(    <!-- Define the input line template. -->\n) .
		qq(    <${ns}g id="inputline" style="fill:none; stroke-width:$grset{stroke_width}" >\n) .
		qq(      <${ns}desc>Input line.</${ns}desc>\n) .
		qq(      <${ns}circle style="$b_clr" cx="$grset{hz_margin}" cy="0" r="$grset{stroke_width}" />\n) .
		qq(      <${ns}line style="$l_clr" x1="$grset{hz_margin}" y1="0" x2="$right_margin" y2="0" />\n) .
		qq(      <${ns}circle style="$e_clr" cx="$right_margin" cy="0" r="$grset{stroke_width}" />\n) .
		qq(    </${ns}g>\n\n);

	#
	# Set up the comparator templates.
	#
	$string .= qq(    <!-- Define the comparator lines, which vary in length. -->\n);

	my @cmptr = (0) x $inputs;
	for my $comparator (@$network)
	{
		my($from, $to) = @$comparator;
		my $clen = $to - $from;
		if ($cmptr[$clen] == 0)
		{
			my $endpoint = $vcoord[$to] - $vcoord[$from];
			$cmptr[$clen] = 1;

			#
			# Color the components in the group individually.
			#
			$b_clr = "fill:$clrset{compbegin}; stroke:$clrset{compbegin}";
			$l_clr = "fill:$clrset{compline}; stroke:$clrset{compline}";
			$e_clr = "fill:$clrset{compend}; stroke:$clrset{compend}";

			$string .=
			qq(    <${ns}g id="comparator$clen" style="stroke-width:$grset{stroke_width}" >\n) .
			qq(      <${ns}desc>Comparator size $clen.</${ns}desc>\n) .
			qq(      <${ns}circle style="$b_clr" cx="0" cy="0" r="$grset{stroke_width}" />\n) .
			qq(      <${ns}line style="$l_clr" x1="0" y1="0" x2="0" y2="$endpoint" />\n) .
			qq(      <${ns}circle style="$e_clr" cx="0" cy="$endpoint" r="$grset{stroke_width}" />\n) .
			qq(    </${ns}g>\n);
		}
	}

	#
	# End of definitions.  Draw the input lines as a group.
	#
	$string .= qq(  </${ns}defs>\n\n  <!-- Draw the input lines. -->\n);
	$string .= qq(  <${ns}g id="inputgroup">\n);
	$string .= qq(    <${ns}use xlink:href="#inputline" y = "$vcoord[$_]" />\n) for (0..$inputs-1);
	$string .= qq(  </${ns}g>\n);

	#
	# Draw our comparators.
	# Each member of a group of comparators is drawn in the same column.
	#
	$string .= qq(\n  <!-- Draw the comparator lines. -->\n);
	my $hidx = 0;
	for my $group (@node_stack)
	{
		for my $comparator (@$group)
		{
			my($from, $to) = @$comparator;
			my $clen = $to - $from;

			$string .= qq(  <!-- [$from, $to] --> <${ns}use xlink:href="#comparator$clen" x = ") .
					$hcoord[$hidx] . qq(" y = ") . $vcoord[$from] . qq(" />\n);
		}
		$hidx++;
	}

	$string .= qq(</svg>\n);
	return $string;
}

#
# $string = nw_text_graph(\@network, $inputs, %graphing_options);
#
# Return a graph of the sorting network in text.
#
sub nw_text_graph
{
	my($network, $inputs, %txset) = @_;

	my @node_stack = nw_group($network, $inputs);
	my @inuse_nodes;

	#
	# Set up a matrix of the begin and end points found in each column.
	# This will tell us where to draw our comparator lines.
	#
	for my $group (@node_stack)
	{
		my @node_column = (0) x $inputs;

		for my $comparator (@$group)
		{
			my($from, $to) = @$comparator;
			@node_column[$from, $to] = (1, -1);
		}
		push @inuse_nodes, [splice @node_column, 0];
	}

	#
	# Print that network.
	#
	my $column = scalar @node_stack;
	my @column_line = (0) x $column;
	my $string = "";

	for my $row (0..$inputs-1)
	{
		#
		# Begin with the input line...
		#
		$string .= $txset{inputbegin};

		for my $col (0..$column-1)
		{
			my @node_column = @{$inuse_nodes[$col]};

			if ($node_column[$row] == 0)
			{
				$string .= $txset{($column_line[$col] == 1)? 'inputcompline': 'inputline'};
			}
			elsif ($node_column[$row] == 1)
			{
				$string .= $txset{compbegin};
			}
			else
			{
				$string .= $txset{compend};
			}
			$column_line[$col] += $node_column[$row];
		}

		$string .= $txset{inputend};

		#
		# Now print the space in between input lines.
		#
		if ($row != $inputs-1)
		{
			$string .= $txset{gapbegin};

			for my $col (0..$column -1)
			{
				$string .= $txset{($column_line[$col] == 0)? 'gapnone': 'gapcompline'};
			}

			$string .= $txset{gapend};
		}
	}

	return $string;
}

#
# @newlist = semijoin($expr, $itemcount, @list);
#
# $expr      - A string to be used in a join() call.
# $itemcount - The number of items in a list to be joined.
#              It may be negative.
# @list      - The list
#
# Create a new list by performing a join on I<$itemcount> elements at a
# time on the original list. Any leftover elements from the end of the
# list become the last item of the new list, unless I<$itemcount> is
# negative, in which case the first item of the new list is made from the
# leftover elements from the front of the list.
#
sub semijoin
{
	my($jstr, $itemcount, @oldlist) = @_;
	my(@newlist);

	return @oldlist if ($itemcount <= 1 and $itemcount >= -1);

	if ($itemcount > 0)
	{
		push @newlist, join $jstr, splice(@oldlist, 0, $itemcount)
			while @oldlist;
	}
	else
	{
		$itemcount = -$itemcount;
		unshift @newlist, join $jstr, splice(@oldlist, -$itemcount, $itemcount)
		    while $itemcount <= @oldlist;
		unshift @newlist, join $jstr, splice( @oldlist, 0, $itemcount)
		    if @oldlist;
	}

	return @newlist;
}

1;
__END__

=head1 NAME

Algorithm::Networksort - Create Sorting Networks.

=head1 SYNOPSIS

  use Algorithm::Networksort qw(:all);

  my $inputs = 4;

  #
  # Generate the sorting network (a list of comparators).
  #
  my @network = nw_comparators($inputs);

  #
  # Print the list, and print the graph of the list.
  #
  print nw_format(\@network), "\n";
  print nw_graph(\@network, $inputs), "\n";

=head1 DESCRIPTION

This module will create sorting networks, a sequence of comparisons
that do not depend upon the results of prior comparisons.

Since the sequences and their order never change, they can be very
useful if deployed in hardware, or if used in software with a compiler
that can take advantage of parallelism. Unfortunately a sorting network cannot
be used for generic run-time sorting like quicksort, since the arrangement of
the comparisons is fixed according to the number of elements to be
sorted.

This module's main purpose is to create compare-and-swap macros (or
functions, or templates) that one may insert into source code. It may
also be used to create images of the sorting networks in either encapsulated
postscript (EPS), scalar vector graphics (SVG), or in "ascii art" format.

=head2 Export

None by default. There is only one available export tag, ':all', which
exports the functions to create and use sorting networks. The functions are
nw_algorithms(), nw_algorithm_name(), nw_comparators(), nw_format(), nw_graph(),
nw_color(), nw_group(), and nw_sort().

=head2 Functions

=head3 nw_algorithms()

Return a list algorithm choices. Each one is a valid value for the
L<nw_comparators()> algorithm key.

=head3 nw_algorithm_name()

Return the full text name of the algorithm, given its key name.

=head3 nw_comparators()

    @network = nw_comparators($inputs);

    @network1 = nw_comparators($inputs, algorithm => $alg);

    @network2 = nw_comparators($inputs, algorithm => $alg, grouping => $grouptype);

Returns a list of comparators that can sort B<$inputs>
items. The algorithm for generating the list may be chosen, but by default the
sorting network is generated by the Bose-Nelson algorithm. The different methods will
produce different networks in general, although in some cases the differences
will be in the arrangement of the comparators, not in their number.

Regardless of the algorithm you use, the order the comparators are returned in will
generally not be in the best order possible to prevent stalling in a CPU's pipeline.
You may use the option B<grouping => 'parallel'> or B<grouping => 'group'> to
arrange the comparators in an order optimized for parallelism.
See the documentation for L<nw_group()>.

The choices for the B<algorithm> key are

=over 3

=item 'bosenelson'

Use the Bose-Nelson algorithm to generate the network. This is the most
commonly implemented algorithm, recursive and simple to code.

=item 'hibbard'

Use Hibbard's algorithm. This iterative algorithm was developed after the
Bose-Nelson algorithm was published, and produces a different network
"... for generating the comparisons one by one in the order in which
they are needed for sorting," according to his article (see below).

=item 'batcher'

Use Batcher's Merge Exchange algorithm. Merge Exchange is a real sort, in
that in its usual form (for example, as described in Knuth) it can handle
a variety of inputs. But while sorting it always generates an identical set of
comparison pairs per array size, which lends itself to sorting networks.

=item 'bitonic'

Use Batcher's bitonic algorithm. A bitonic sequence is a sequence that
monotonically increases and then monotonically decreases. The bitonic sort
algorithm works by recursively splitting sequences into bitonic sequences
using so-called "half-cleaners". These bitonic sequences are then merged
into a fully sorted sequence. Bitonic sort is a very efficient sort and
is especially suited for implementations that can exploit network
parallelism.

=item oddevenmerge

Use Batcher's Odd-Even Merge algorithm. This sort works in a similar way
to a regular merge sort, except that in the merge phase the sorted halves
are merged by comparing even elements separately from odd elements. This
algorithm creates very efficient networks in both comparators and stages.

=item 'bubble'

Use a naive bubble-sort/insertion-sort algorithm. Since this algorithm
produces more comparison pairs than the other algorithms, it is only
useful for illustrative purposes.

=item 'oddeventransposition'

Use a naive odd-even transposition sort. This is a primitive sort closely
related to bubble sort except it is more parallel. Because other algorithms
are more efficient, this sort is included mostly for illustrative purposes.

=item balanced

This network is described in the 1983 paper "The Balanced Sorting Network"
by M. Dowd, Y. Perl, M Saks, and L. Rudolph. It is not a particularly
efficient sort but it has some interesting properties due to the fact
that it is constructed as a series of successive identical sub-blocks,
somewhat like with oddeventransposition.

=item 'best'

This is an obsolete option choice -- use Algorithm::Networksort::Best
for the networks discovered that are more efficient that those created
by the algorithms here.

=back

=head3 nw_format()

    $string = nw_format(\@network, $format1, $format2, \@index_base);

Returns a formatted string that represents the list of comparators.
There are two sprintf-style format strings, which lets you separate
the comparison and exchange portions if you want. The second format
string is optional.

The first format string may also be ignored, in which case the default
format will be used: an array of arrays as represented in perl.

The network sorting pairs are zero-based. If you want the pairs written out
for some sequence other than 0, 1, 2, ... then you can provide that in
an array reference.

B<Example 0: you want a string in the default format.>

    print nw_format(\@network);

B<Example 1: you want the output to look like the default format, but one-based instead of zero-based.>

    print nw_format(\@network,
                undef,
                undef,
                [1..$inputs]);

B<Example 2: you want a simple list of SWAP macros.>

    print nw_format(\@network, "SWAP(%d, %d);\n");

B<Example 3: as with example 2, but the SWAP values need to be one-based instead of zero-based.>

    print nw_format(\@network,
                "SWAP(%d, %d);\n",
                undef,
                [1..$inputs]);

B<Example 4: you want a series of comparison and swap statements.>

    print nw_format(\@network,
                "if (v[%d] < v[%d]) then\n",
                "    exchange(v, %d, %d)\nend if\n");

B<Example 5: you want the default format to use letters, not numbers.>

    my @alphabase = ('a'..'z')[0..$inputs];

    my $string = '[' .
            nw_format(\@network,
		"[%s,%s],",      # Note that we're using the string flag.
		undef,
		\@alphabase);

    substr($string, -1, 1) = ']';    # Overwrite the trailing comma.
    print $string;

=head3 nw_color()

Sets the colors of the svg graph parts (eps support will come later).
The parts are named.

=over 4

=item inputbegin

Opening of input line.

=item inputline

The input line.

=item inputend

Closing of the input line.

=item compbegin

Opening of the comparator.

=item compline

The comparator line.

=item compend

Closing of the comparator line.

=item foreground

Default color for the graph as a whole.

=item background

Color of the background.  Currently unimplemented in SVG.

=back

All parts not named are reset to 'undef', and will be colored with the
default 'foreground' color.  The foreground color itself has a default
value of 'black'.  The one exception is the 'background' color, which
has no default color at all.

=head3 nw_graph()

Returns a string that graphs out the network's comparators. The format
may be encapsulated postscript (graph=>'eps'), scalar vector graphics
(graph=>'svg'), or the default plain text (graph=>'text' or none). The 'text'
and 'eps' options produce output that is self-contained. The 'svg' option
produces output between E<lt>svgE<gt> and E<lt>/svgE<gt> tags, which needs
to be combined with XML markup in order to be viewed.

    my $inputs = 4;
    my @network = nw_comparators($inputs);

    print qq(<?xml version="1.0" standalone="no"?>\n),
          qq(<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" ),
          qq("http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n),
	  nw_graph(\@network, $inputs, graph => 'svg');

The 'graph' option is not the only one available. The graphing can be
adjusted to your needs using the following options.

=head4 Options for 'svg' only.

=over 3

=item namespace

I<Default value: undef.>
A tag prefix that allows programs to distinguish between different XML
vocabularies that have the same tag. If undefined, no tag prefix is used.

=back

=head4 Options for 'svg' and 'eps' graphs

=over 3

=item hz_margin

I<Default value: 18.>
The horizontal spacing between the edges of the graphic and the
sorting network.

=item hz_sep

I<Default value: 12.>
The spacing separating the horizontal lines (the input lines).

=item indent

I<Default value: 9.>
The indention between the start of the input lines and the placement of
the first comparator. The same value spaces the placement of the final
comparator and the end of the input lines.

=item stroke_width

I<Default value: 2.>
Width of the lines used to define comparators and input lines. Also
represents the radii of the endpoint circles.

=item title

I<Default value: "N = $inputs Sorting Network.">
Title of the graph. It should be a short one-line description.

=item vt_margin

I<Default value: 21.>
The vertical spacing between the edges of the graphic and the sorting network.

=item vt_sep

I<Default value: 12.>
The spacing separating the vertical lines (the comparators).

=back

=head4 Options for the 'text' graph

=over 3

=item inputbegin

I<Default value: "o-".>
The starting characters for the input line.

=item inputline

I<Default value: "---".>
The characters that make up an input line.

=item inputcompline

I<Default value: "-|-".>
The characters that make up an input line that has a comparator crossing
over it.

=item inputend

I<Default value: "-o\n".>
The characters that make up the end of an input line.

=item compbegin

I<Default value: "-^-".>
The characters that make up an input line with the starting point of
a comparator.

=item compend

I<Default value: "-v-".>
The characters that make up an input line with the end point of
a comparator.

=item gapbegin

I<Default value: "  " (two spaces).>
The characters that start the gap between the input lines.

=item gapcompline

I<Default value: " | " (space vertical bar space).>
The characters that make up the gap with a comparator passing through.

=item gapnone

I<Default value: "  " (three spaces).>
The characters that make up the space between the input lines.

=item gapend

I<Default value: "  \n" (two spaces and a newline).>
The characters that end the gap between the input lines.

=back

=head3 nw_group()

This is a function called by nw_graph() and optionally by nw_comparators(). The
function takes the comparator list and returns a list of comparator lists, each
sub-list representing a group of comparators that can be printed in a single
column. There is one option available, 'grouping', that will produce a grouping
that represents parallel operations of comparators. Its values may be:

=over 3

=item 'none'

Return the sequence as generated by the algorithm with no changes. This will
also happen if the B<grouping> key isn't present, or if an incorrect (or
misspelled) value for B<grouping> is used.

=item 'group'

Arrange the sequence as parallel as possible for printing.

=item 'parallel'

Arrange the sequence in parallel so that it has a minimum depth.

=back

The chances that you will need to use this function are slim, but the
following code snippet may represent an example:

    my $inputs = 8;
    my @network = nw_comparators($inputs, algorithm => 'batcher');
    my @grouped_network = nw_group(\@network, $inputs, grouping=>'parallel');

    print "There are ", scalar @network,
        " comparators in this network, grouped into\n",
        scalar @grouped_network, " parallel operations.\n\n";

    foreach my $group (@grouped_network)
    {
        print nw_format($group), "\n";
    }

    @grouped_network = nw_group(\@network, $inputs);
    print "\nThis will be graphed in ", scalar @grouped_network,
        " columns.\n";

This will produce:

    There are 19 comparators in this network, grouped into 6 parallel operations.

    [[0,4],[1,5],[2,6],[3,7]]
    [[0,2],[1,3],[4,6],[5,7]]
    [[2,4],[3,5],[0,1],[6,7]]
    [[2,3],[4,5]]
    [[1,4],[3,6]]
    [[1,2],[3,4],[5,6]]

    This will be graphed in 11 columns.

=head3 nw_sort()

Sort an array using the network. This is meant for testing purposes
only - looping around an array of comparators in order to sort an
array in an interpreted language is not the most efficient mechanism
for using a sorting network.

This function uses the C<< <=> >> operator for comparisons.

    my @digits = (1, 8, 3, 0, 4, 7, 2, 5, 9, 6);
    my @network = nw_comparators(scalar @digits, algorithm => 'batcher');
    nw_sort(\@network, \@digits);
    print join(", ", @digits);

=head3 nw_sort_stats()

Return statistics on the last nw_sort() call. Currently only "swaps",
a count of the number of exchanges, is returned.

    my(@d, %nw_stats);
    my @digits = (1, 8, 3, 0, 4, 7, 2, 5, 9, 6);
    my @network_batcher = nw_comparators(scalar @digits,
            algorithm => 'batcher');
    my @network_bn = nw_comparators(scalar @digits,
            algorithm => 'bosenelson');

    @d = @digits;
    nw_sort(\@network_batcher, \@d);
    %nw_stats = nw_sort_stats();
    print "The Batcher Merge-Exchange network took ",
        $nw_stats{swaps}, " exchanges to sort the array."

    @d = @digits;
    nw_sort(\@network_bn, \@d);
    %nw_stats = nw_sort_stats();
    print "The Bose-Nelson network took ",
        $nw_stats{swaps}, " exchanges to sort the array."

=head1 ACKNOWLEDGMENTS

L<Doug Hoyte|https://github.com/hoytech> provided the code for the bitonic sort algorithm and the bubble sort,
and the idea for what became the L<nw_sort_stats()> function.

=head1 SEE ALSO

=head2 Bose and Nelson's algorithm.

=over 3

=item

Bose and Nelson, "A Sorting Problem", Journal of the ACM, Vol. 9, 1962, pp. 282-296.

=item

Joseph Celko, "Bose-Nelson Sort", Doctor Dobb's Journal, September 1985.

=item

Frederick Hegeman, "Sorting Networks", The C/C++ User's Journal, February 1993.

=item

Joe Celko, I<Joe Celko's SQL For Smarties> (third edition). Implementing Bose-Nelson sorting network in SQL.

This material isn't in either the second or fourth edition of the book.

=item

Joe Celko, I<Joe Celko's Thinking in Sets: Auxiliary, Temporal, and Virtual Tables in SQL>.

The sorting network material removed from the third edition of I<SQL For Smarties> seems to have been moved to this book.

=back

=head2 Hibbard's algorithm.

=over 3

=item

T. N. Hibbard, "A Simple Sorting Algorithm", Journal of the ACM Vol. 10, 1963, pp. 142-50.

=back

=head2 Batcher's Merge Exchange algorithm.

=over 3

=item

Code for Kenneth Batcher's Merge Exchange algorithm was derived from Knuth's
The Art of Computer Programming, Vol. 3, section 5.2.2.

=back

=head2 Batcher's Bitonic algorithm

=over 3

=item

Kenneth Batcher, "Sorting Networks and their Applications", Proc. of the
AFIPS Spring Joint Computing Conf., Vol. 32, 1968, pp. 307-3114. A PDF of
this article may be found at L<http://www.cs.kent.edu/~batcher/sort.pdf>.

The paper discusses both the Odd-Even Merge algorithm and the Bitonic algorithm.

=item

Dr. Hans Werner Lang has written a detailed discussion of the bitonic
sort algorithm here:
L<http://www.iti.fh-flensburg.de/lang/algorithmen/sortieren/bitonic/bitonicen.htm>

=item

T. H. Cormen, E. E. Leiserson, R. L. Rivest, Introduction to Algorithms,
first edition, McGraw-Hill, 1990, section 28.3.

=item

T. H. Cormen, E. E. Leiserson, R. L. Rivest, C. Stein, Introduction to Algorithms,
2nd edition, McGraw-Hill, 2001, section 27.3.

=back

=head2 Non-algorithmic discoveries

=over 3

=item

Ian Parberry, "A computer assisted optimal depth lower bound for sorting
networks with nine inputs", L<http://www.eng.unt.edu/ian/pubs/snverify.pdf>.

=item

The Evolving Non-Determinism (END) algorithm has found more efficient
sorting networks: L<http://www.cs.brandeis.edu/~hugues/sorting_networks.html>.

=item

The 18 and 22 input networks found by Sherenaz Waleed Al-Haj Baddar
are described in her paper "Finding Better Sorting Networks" at
L<http://etd.ohiolink.edu/view.cgi?acc_num=kent1239814529>.

=back

=head2 Algorithm discussion

=over 3

=item

Donald E. Knuth, The Art of Computer Programming, Vol. 3: (2nd ed.)
Sorting and Searching, Addison Wesley Longman Publishing Co., Inc.,
Redwood City, CA, 1998.

=item

Kenneth Batcher's web site (L<http://www.cs.kent.edu/~batcher/>) lists
his publications, including his paper listed above.

=back

=head1 AUTHOR

John M. Gamble may be found at B<jgamble@cpan.org>

=cut

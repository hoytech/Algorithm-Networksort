package Algorithm::Networksort::Best;

use 5.008003;

use Algorithm::Networksort qw(nw_group);
use Carp;
use Exporter;
use vars qw(@ISA %EXPORT_TAGS @EXPORT_OK);
use strict;
use warnings;

@ISA = qw(Exporter);

%EXPORT_TAGS = (
	'all' => [ qw(
		nw_best_comparators
		nw_best_inputs_range
		nw_best_inputs
		nw_best_names
		nw_best_title
	) ],
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '1.30';

#
# The hashes represent each network, with a short, hopefully descriptive, key.
#
my %nw_best_by_name = (
	floyd09 => {
		inputs => 9,
		depth => 9,
		title => '9-input Network by Robert W. Floyd',
		comparators =>
		[[0,1], [3,4], [6,7], [1,2], [4,5], [7,8], [0,1], [3,4],
		[6,7], [0,3], [3,6], [0,3], [1,4], [4,7], [1,4], [2,5],
		[5,8], [2,5], [1,3], [5,7], [2,6], [4,6], [2,4], [2,3],
		[5,6]]},
	senso09 => {
		inputs => 9,
		depth => 8,
		title => '9-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[2,6], [0,5], [1,4], [7,8], [0,7], [1,2], [3,5], [4,6],
		[5,8], [1,3], [6,8], [0,1], [4,5], [2,7], [3,7], [3,4],
		[5,6], [1,2], [1,3], [6,7], [4,5], [2,4], [5,6], [2,3],
		[4,5]]},
	waksman10 => {
		inputs => 10,
		depth => 9,
		title => '10-Input Network by A. Waksman',
		comparators =>
		[[4,9], [3,8], [2,7], [1,6], [0,5], [1,4], [6,9], [0,3],
		[5,8], [0,2], [3,6], [7,9], [0,1], [2,4], [5,7], [8,9],
		[1,2], [4,6], [7,8], [3,5], [2,5], [6,8], [1,3], [4,7],
		[2,3], [6,7], [3,4], [5,6], [4,5]]},
	senso10 => {
		inputs => 10,
		depth => 8,
		title => '10-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[1,4], [7,8], [2,3], [5,6], [0,9], [2,5], [0,7], [8,9],
		[3,6], [4,9], [0,1], [0,2], [6,9], [3,5], [4,7], [1,8],
		[3,4], [5,8], [6,7], [1,2], [7,8], [1,3], [2,5], [4,6],
		[2,3], [6,7], [4,5], [3,4], [5,6]]},
	shapirogreen11 => {
		inputs => 11,
		depth => 9,
		title => '11-Input by G. Shapiro and M. W. Green',
		comparators =>
		[[0,1], [2,3], [4,5], [6,7], [8,9], [1,3], [5,7], [0,2],
		[4,6], [8,10], [1,2], [5,6], [9,10], [1,5], [6,10], [5,9],
		[2,6], [1,5], [6,10], [0,4], [3,7], [4,8], [0,4], [1,4],
		[7,10], [3,8], [2,3], [8,9], [2,4], [7,9], [3,5], [6,8],
		[3,4], [5,6], [7,8]]},
	senso11 => {
		inputs => 11,
		depth => 10,
		title => '11-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[0,9], [2,8], [3,7], [4,6], [1,5], [1,3], [2,4], [6,10],
		[7,8], [5,9], [0,6], [1,2], [8,10], [9,10], [0,1], [5,7],
		[3,4], [6,8], [2,6], [1,5], [7,8], [4,9], [2,3], [8,9],
		[1,2], [4,6], [3,5], [6,7], [7,8], [2,3], [4,6], [5,6],
		[3,4], [6,7], [4,5]]},
	shapirogreen12 => {
		inputs => 12,
		depth => 9,
		title => '12-Input by G. Shapiro and M. W. Green',
		comparators =>
		[[0,1], [2,3], [4,5], [6,7], [8,9], [10,11], [1,3], [5,7],
		[9,11], [0,2], [4,6], [8,10], [1,2], [5,6], [9,10], [1,5],
		[6,10], [5,9], [2,6], [1,5], [6,10], [0,4], [7,11], [3,7],
		[4,8], [0,4], [7,11], [1,4], [7,10], [3,8], [2,3], [8,9],
		[2,4], [7,9], [3,5], [6,8], [3,4], [5,6], [7,8]]},
	senso12 => {
		inputs => 12,
		depth => 9,
		title => '12-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[0,5], [2,7], [4,10], [3,6], [8,11], [1,9], [5,6], [1,8],
		[0,3], [2,4], [9,11], [7,10], [7,9], [10,11], [1,2], [6,11],
		[0,1], [4,8], [5,8], [1,4], [3,7], [2,5], [7,10], [6,9],
		[2,3], [4,6], [8,10], [1,2], [9,10], [6,8], [3,4], [8,9],
		[2,3], [5,7], [4,5], [6,7], [7,8], [5,6], [3,4]]},
	end13 => {
		inputs => 13,
		depth => 10,
		title => '13-Input Network Generated by the END algorithm, by Hugues Juill�',
		comparators =>
		[[1,7], [9,11], [3,4], [5,8], [0,12], [2,6], [0,1], [2,3],
		[4,6], [8,11], [7,12], [5,9], [0,2], [3,7], [10,11], [1,4],
		[6,12], [7,8], [11,12], [4,9], [6,10], [3,4], [5,6], [8,9],
		[10,11], [1,7], [2,6], [9,11], [1,3], [4,7], [8,10], [0,5],
		[2,5], [6,8], [9,10], [1,2], [3,5], [7,8], [4,6], [2,3],
		[4,5], [6,7], [8,9], [3,4], [5,6]]},
	senso13 => {
		inputs => 13,
		depth => 12,
		title => '13-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[4,8], [0,9], [3,7], [2,5], [6,11], [1,12], [0,6], [2,4],
		[5,8], [7,12], [1,3], [10,11], [9,11], [0,1], [8,12], [8,10],
		[2,8], [11,12], [0,2], [7,9], [5,9], [3,6], [3,5], [1,8],
		[4,6], [4,7], [10,11], [6,9], [3,4], [1,2], [9,11], [1,3],
		[6,10], [2,4], [2,3], [9,10], [6,8], [5,7], [5,6], [7,8],
		[3,5], [8,9], [4,5], [6,7], [5,6]]},
	green14 => {
		inputs => 14,
		depth => 10,
		title => '14-Input Network by M. W. Green',
		comparators =>
		[[0,1], [2,3], [4,5], [6,7], [8,9], [10,11], [12,13], [0,2],
		[4,6], [8,10], [1,3], [5,7], [9,11], [0,4], [8,12], [1,5],
		[9,13], [2,6], [3,7], [0,8], [1,9], [2,10], [3,11], [4,12],
		[5,13], [5,10], [6,9], [3,12], [7,11], [1,2], [4,8], [1,4],
		[7,13], [2,8], [2,4], [5,6], [9,10], [11,13], [3,8], [7,12],
		[6,8], [10,12], [3,5], [7,9], [3,4], [5,6], [7,8], [9,10],
		[11,12], [6,7], [8,9]]},
	senso14 => {
		inputs => 14,
		depth => 11,
		title => '14-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[0,6], [2,3], [8,12], [4,5], [1,10], [7,13], [9,11], [3,6],
		[4,7], [5,13], [1,8], [10,12], [0,2], [11,12], [0,9], [1,4],
		[6,13], [12,13], [0,1], [2,7], [3,5], [9,10], [3,8], [7,10],
		[5,8], [2,9], [6,11], [4,6], [8,12], [1,3], [10,11], [2,4],
		[11,12], [1,2], [8,10], [3,9], [3,4], [2,3], [10,11], [5,7],
		[7,8], [6,9], [5,6], [4,5], [8,9], [6,7], [9,10], [3,4],
		[5,6], [7,8], [6,7]]},
	green15 => {
		inputs => 15,
		depth => 10,
		title => '15-Input Network by M. W. Green',
		comparators =>
		[[0,1], [2,3], [4,5], [6,7], [8,9], [10,11], [12,13], [0,2],
		[4,6], [8,10], [12,14], [1,3], [5,7], [9,11], [0,4], [8,12],
		[1,5], [9,13], [2,6], [10,14], [3,7], [0,8], [1,9], [2,10],
		[3,11], [4,12], [5,13], [6,14], [5,10], [6,9], [3,12], [13,14],
		[7,11], [1,2], [4,8], [1,4], [7,13], [2,8], [11,14], [2,4],
		[5,6], [9,10], [11,13], [3,8], [7,12], [6,8], [10,12], [3,5],
		[7,9], [3,4], [5,6], [7,8], [9,10], [11,12], [6,7], [8,9]]},
	senso15 => {
		inputs => 15,
		depth => 10,
		title => '15-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[12,13], [5,7], [3,11], [2,10], [4,9], [6,8], [1,14], [11,14],
		[1,3], [7,10], [0,12], [4,6], [2,5], [8,9], [0,2], [9,14],
		[1,4], [0,1], [5,6], [7,8], [11,13], [3,12], [5,11], [9,10],
		[8,12], [2,4], [6,13], [3,7], [2,3], [12,14], [10,13], [1,5],
		[13,14], [1,2], [3,5], [10,12], [12,13], [2,3], [8,11], [4,9],
		[10,11], [6,7], [5,6], [4,8], [7,9], [4,5], [9,11], [11,12],
		[3,4], [6,8], [7,10], [9,10], [5,6], [7,8], [8,9], [6,7]]},
	green16 => {
		inputs => 16,
		depth => 10,
		title => '16-Input Network by M. W. Green',
		comparators =>
		[[0,1], [2,3], [4,5], [6,7], [8,9], [10,11], [12,13], [14,15],
		[0,2], [4,6], [8,10], [12,14], [1,3], [5,7], [9,11], [13,15],
		[0,4], [8,12], [1,5], [9,13], [2,6], [10,14], [3,7], [11,15],
		[0,8], [1,9], [2,10], [3,11], [4,12], [5,13], [6,14], [7,15],
		[5,10], [6,9], [3,12], [13,14], [7,11], [1,2], [4,8], [1,4],
		[7,13], [2,8], [11,14], [2,4], [5,6], [9,10], [11,13], [3,8],
		[7,12], [6,8], [10,12], [3,5], [7,9], [3,4], [5,6], [7,8],
		[9,10], [11,12], [6,7], [8,9]]},
	senso16 => {
		inputs => 16,
		depth => 10,
		title => '16-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[12,13], [5,7], [3,11], [2,10], [0,15], [4,9], [6,8], [1,14],
		[11,14], [1,3], [7,10], [0,12], [4,6], [2,5], [8,9], [13,15],
		[10,15], [0,2], [9,14], [1,4], [0,1], [14,15], [5,6], [7,8],
		[11,13], [3,12], [5,11], [9,10], [8,12], [2,4], [6,13], [3,7],
		[2,3], [12,14], [10,13], [1,5], [13,14], [1,2], [3,5], [10,12],
		[12,13], [2,3], [8,11], [4,9], [10,11], [6,7], [5,6], [4,8],
		[7,9], [4,5], [9,11], [11,12], [3,4], [6,8], [7,10], [9,10],
		[5,6], [7,8], [8,9], [6,7]]},
	senso17 => {
		inputs => 17,
		depth => 17,
		title => '17-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[5,11], [4,9], [7,12], [0,14], [2,16], [1,15], [3,8], [6,13],
		[3,10], [8,13], [4,7], [9,12], [0,2], [14,16], [1,6], [10,15],
		[3,5], [11,13], [0,4], [12,16], [1,3], [13,15], [0,1], [15,16],
		[2,9], [7,14], [5,10], [6,11], [5,7], [6,8], [8,10], [2,3],
		[8,14], [9,11], [12,13], [4,6], [10,14], [4,5], [7,9], [11,13],
		[1,2], [14,15], [1,8], [13,15], [1,4], [2,5], [11,14], [13,14],
		[2,4], [6,12], [9,12], [3,10], [3,8], [6,7], [10,12], [3,6],
		[3,4], [12,13], [10,11], [5,6], [11,12], [4,5], [7,8], [8,9],
		[6,8], [9,11], [5,7], [6,7], [9,10], [8,9], [7,8]]},
	sat17 => {
		inputs => 17,
		depth => 10,
		title => '17-Input Network by M. Codish, L. Cruz-Filipe, T. Ehlers, M. M�ller, P. Schneider-Kamp',
		comparators =>
		[[1,2], [3,4], [5,6], [7,8], [9,10], [11,12], [13,14], [15,16],
		[2,4], [6,8], [10,12], [14,16], [1,3], [5,7], [9,11], [13,15],
		[4,8], [12,16], [3,7], [11,15], [2,6], [10,14], [1,5], [9,13],
		[0,3], [4,7], [8,16], [1,13], [14,15], [6,12], [5,11], [2,10],
		[1,16], [3,6], [7,15], [4,14], [0,13], [2,5], [8,9], [10,11],
		[0,1], [2,8], [9,15], [3,4], [7,11], [12,14], [6,13], [5,10],
		[2,15], [4,10], [11,13], [3,8], [9,12], [1,5], [6,7], [1,3],
		[4,6], [7,9], [10,11], [13,15], [0,2], [5,8], [12,14], [0,1],
		[2,3], [4,5], [6,8], [9,11], [12,13], [14,15], [7,10], [1,2],
		[3,4], [5,6], [7,8], [9,10], [11,12], [13,14], [15,16]]},
	alhajbaddar18 => {
		inputs => 18,
		depth => 11,
		title => '18-Input Network by Sherenaz Waleed Al-Haj Baddar',
		comparators =>
		[[0,1], [2,3], [4,5], [6,7], [8,9], [10,11], [12,13], [14,15],
		[16,17], [0,2], [1,3], [4,6], [5,7], [8,10], [9,11], [12,17],
		[13,14], [15,16], [0,4], [1,5], [2,6], [3,7], [9,10], [8,12],
		[11,16], [13,15], [14,17], [7,16], [6,17], [3,5], [10,14], [11,12],
		[9,15], [2,4], [1,13], [0,8], [16,17], [7,14], [5,12], [3,15],
		[6,13], [4,10], [2,11], [8,9], [0,1], [1,8], [14,16], [6,9],
		[7,13], [5,11], [3,10], [4,15], [4,8], [14,15], [5,9], [7,11],
		[1,2], [12,16], [3,6], [10,13], [5,8], [11,14], [2,3], [12,13],
		[6,7], [9,10], [7,9], [3,5], [12,14], [2,4], [13,15], [6,8],
		[10,11], [13,14], [11,12], [9,10], [7,8], [5,6], [3,4], [12,13],
		[10,11], [8,9], [6,7], [4,5]]},
	senso18 => {
		inputs => 18,
		depth => 15,
		title => '18-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[4,12], [5,13], [0,7], [10,17], [2,3], [14,15], [6,8], [9,11],
		[1,16], [2,6], [11,15], [1,9], [8,16], [4,10], [7,13], [3,12],
		[5,14], [0,2], [15,17], [1,4], [13,16], [0,5], [12,17], [0,1],
		[16,17], [3,7], [10,14], [6,9], [8,11], [2,15], [3,8], [9,14],
		[4,5], [12,13], [6,10], [2,6], [7,11], [1,4], [13,16], [14,15],
		[2,3], [11,15], [15,16], [1,2], [11,14], [3,6], [13,14], [3,4],
		[14,15], [2,3], [5,6], [11,12], [7,9], [8,10], [9,10], [7,8],
		[5,11], [6,12], [10,12], [5,7], [12,14], [3,5], [10,13], [4,7],
		[12,13], [4,5], [8,9], [6,9], [8,11], [9,12], [5,8], [6,7],
		[10,11], [6,8], [9,11], [7,10], [9,10], [7,8]]},
	senso19 => {
		inputs => 19,
		depth => 15,
		title => '19-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[4,10], [3,12], [0,16], [7,14], [8,11], [6,13], [15,17], [1,5],
		[9,18], [2,5], [11,16], [7,9], [1,2], [6,15], [10,12], [3,4],
		[13,17], [0,8], [14,18], [5,16], [3,7], [17,18], [1,6], [4,15],
		[0,1], [12,16], [0,3], [16,18], [2,11], [9,10], [13,14], [6,8],
		[7,13], [2,9], [11,15], [1,7], [5,10], [12,17], [8,14], [4,6],
		[10,14], [3,4], [15,16], [1,2], [14,17], [1,3], [16,17], [5,7],
		[6,13], [5,6], [10,15], [2,4], [14,15], [2,5], [11,12], [15,16],
		[2,3], [8,9], [7,13], [9,12], [8,11], [9,10], [13,14], [5,8],
		[12,14], [14,15], [3,5], [4,6], [10,13], [4,8], [4,5], [13,14],
		[7,11], [6,11], [6,9], [7,8], [11,12], [6,7], [12,13], [5,6],
		[9,10], [10,11], [11,12], [8,9], [7,8], [9,10]]},
	senso20 => {
		inputs => 20,
		depth => 14,
		title => '20-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[2,11], [8,17], [0,10], [9,19], [4,5], [14,15], [3,6], [13,16],
		[1,12], [7,18], [3,14], [5,16], [0,1], [18,19], [4,13], [6,15],
		[7,9], [10,12], [2,8], [11,17], [4,7], [12,15], [0,3], [16,19],
		[0,2], [17,19], [0,4], [15,19], [1,14], [5,18], [8,10], [9,11],
		[6,13], [5,9], [10,14], [1,3], [16,18], [6,8], [11,13], [2,7],
		[12,17], [1,5], [1,2], [14,18], [4,6], [13,15], [17,18], [15,18],
		[1,4], [3,9], [10,16], [2,3], [16,17], [13,17], [2,6], [15,17],
		[2,4], [7,8], [11,12], [5,10], [9,14], [8,12], [7,11], [3,7],
		[12,16], [3,5], [14,16], [15,16], [3,4], [5,6], [13,14], [14,15],
		[4,5], [10,11], [8,9], [11,12], [7,8], [7,10], [9,12], [5,7],
		[12,14], [9,13], [6,10], [6,7], [10,11], [12,13], [8,9], [9,11],
		[11,12], [8,10], [7,8], [9,10]]},
	sat20 => {
		inputs => 20,
		depth => 11,
		title => '20-Input Network by M. Codish, L. Cruz-Filipe, T. Ehlers, M. M�ller, P. Schneider-Kamp',
		comparators =>
		[[0,1], [2,3], [4,5], [6,7], [8,9], [10,11], [12,13], [14,15],
		[16,17], [18,19], [1,3], [5,7], [9,11], [13,15], [17,19], [0,2],
		[4,6], [8,10], [12,14], [16,18], [3,7], [9,10], [15,19], [2,6],
		[14,18], [1,5], [13,17], [0,4], [12,16], [7,19], [6,18], [5,17],
		[4,16], [3,15], [2,14], [1,13], [0,12], [2,19], [3,8], [11,16],
		[17,18], [1,4], [5,15], [9,14], [10,13], [6,12], [0,19], [1,18],
		[2,6], [7,15], [16,17], [3,4], [8,14], [5,9], [10,11], [12,13],
		[1,3], [4,5], [9,12], [13,16], [17,18], [0,15], [7,14], [8,11],
		[6,10], [0,1], [3,6], [7,13], [14,17], [18,19], [2,4], [5,10],
		[11,12], [15,16], [8,9], [2,3], [4,8], [9,11], [12,15], [16,18],
		[1,17], [5,6], [7,10], [13,14], [1,3], [4,5], [7,9], [10,11],
		[12,13], [14,15], [16,17], [18,19], [0,2], [6,8], [1,2], [3,4],
		[5,6], [7,8], [9,10], [11,12], [13,14], [15,16]]},
	senso21 => {
		inputs => 21,
		depth => 20,
		title => '21-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[5,9], [11,15], [1,19], [2,14], [6,18], [0,17], [3,20], [4,8],
		[12,16], [7,13], [1,7], [13,19], [2,11], [9,18], [4,12], [8,16],
		[3,5], [15,17], [0,10], [10,20], [0,6], [14,20], [2,3], [17,18],
		[1,4], [16,19], [0,1], [19,20], [0,2], [18,20], [7,8], [12,13],
		[9,10], [4,11], [5,6], [14,15], [10,11], [5,12], [8,15], [6,13],
		[7,14], [16,17], [1,3], [4,9], [5,7], [13,15], [11,18], [17,19],
		[1,2], [18,19], [4,5], [1,4], [15,19], [13,17], [2,7], [11,17],
		[9,14], [4,5], [15,18], [17,18], [2,4], [6,10], [8,16], [3,12],
		[10,14], [12,16], [3,8], [6,9], [14,16], [8,12], [3,6], [4,5],
		[15,16], [16,17], [3,4], [11,13], [5,7], [13,15], [6,7], [15,16],
		[4,5], [10,11], [9,11], [8,9], [11,12], [12,14], [8,10], [6,8],
		[14,15], [5,6], [12,13], [13,14], [6,8], [7,9], [10,11], [7,10],
		[7,8], [9,13], [11,12], [9,12], [9,11], [9,10]]},
	alhajbaddar22 => {
		inputs => 22,
		depth => 12,
		title => '22-Input Network by Sherenaz Waleed Al-Haj Baddar',
		comparators =>
		[[0,1], [2,3], [4,5], [6,7], [8,9], [10,11], [12,13], [14,15],
		[16,17], [18,19], [20,21], [2,4], [1,3], [0,5], [6,8], [7,9],
		[10,12], [11,13], [14,16], [15,17], [18,20], [19,21], [6,10], [7,11],
		[8,12], [9,13], [14,18], [15,19], [16,20], [17,21], [3,5], [1,4],
		[0,2], [9,17], [7,15], [11,19], [8,16], [3,12], [0,10], [1,18],
		[5,20], [13,21], [6,14], [2,4], [0,7], [17,20], [3,15], [9,18],
		[2,11], [4,16], [5,10], [1,8], [12,19], [13,14], [20,21], [0,6],
		[3,8], [12,18], [2,13], [14,16], [5,9], [10,15], [4,7], [11,17],
		[16,20], [18,19], [15,17], [12,14], [10,11], [7,9], [8,13], [4,5],
		[1,3], [2,6], [19,20], [16,17], [15,18], [11,14], [9,13], [10,12],
		[7,8], [3,5], [4,6], [1,2], [18,19], [14,16], [13,15], [11,12],
		[8,9], [5,10], [6,7], [2,3], [17,19], [16,18], [14,15], [12,13],
		[9,11], [8,10], [5,7], [3,6], [2,4], [17,18], [15,16], [13,14],
		[11,12], [9,10], [7,8], [5,6], [3,4], [16,17], [14,15], [12,13],
		[10,11], [8,9], [6,7], [4,5]]},
	senso22 => {
		inputs => 22,
		depth => 15,
		title => '22-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[10,11], [2,8], [13,19], [3,15], [6,18], [1,16], [5,20], [0,17],
		[4,21], [7,9], [12,14], [0,4], [17,21], [3,12], [9,18], [1,2],
		[19,20], [7,13], [8,14], [5,6], [15,16], [5,7], [14,16], [1,10],
		[11,20], [0,3], [18,21], [0,5], [16,21], [0,1], [20,21], [6,8],
		[13,15], [2,4], [17,19], [9,11], [10,12], [2,7], [14,19], [3,9],
		[12,18], [6,13], [8,15], [4,11], [10,17], [5,10], [11,16], [3,6],
		[15,18], [1,2], [19,20], [1,3], [18,20], [1,5], [16,20], [2,6],
		[15,19], [11,18], [2,5], [16,19], [3,10], [2,3], [18,19], [9,12],
		[4,14], [7,17], [8,13], [12,17], [4,9], [13,14], [7,8], [4,7],
		[14,17], [4,5], [16,17], [17,18], [3,4], [6,10], [11,15], [5,6],
		[15,16], [4,5], [16,17], [9,12], [8,13], [10,13], [8,11], [7,9],
		[12,14], [7,8], [13,14], [14,16], [5,7], [9,10], [11,12], [6,9],
		[12,15], [14,15], [6,7], [8,11], [10,13], [8,9], [12,13], [7,8],
		[13,14], [10,11], [11,12], [9,10]]},
	senso23 => {
		inputs => 23,
		depth => 22,
		title => '23-Input Network via SENSO by V. K. Valsalam and R. Miikkulainen',
		comparators =>
		[[1,20], [2,21], [5,13], [9,17], [0,7], [15,22], [4,11], [6,12],
		[10,16], [8,18], [14,19], [3,8], [4,14], [11,18], [2,6], [16,20],
		[0,9], [13,22], [5,15], [7,17], [1,10], [12,21], [8,19], [17,22],
		[0,5], [20,21], [1,2], [18,19], [3,4], [21,22], [0,1], [19,22],
		[0,3], [12,13], [9,10], [6,15], [7,16], [8,11], [11,14], [4,11],
		[6,8], [14,16], [17,20], [2,5], [9,12], [10,13], [15,18], [10,11],
		[4,7], [20,21], [1,2], [7,15], [3,9], [13,19], [16,18], [8,14],
		[4,6], [18,21], [1,4], [19,21], [1,3], [9,10], [11,13], [2,6],
		[16,20], [4,9], [13,18], [19,20], [2,3], [18,20], [2,4], [5,17],
		[12,14], [8,12], [5,7], [15,17], [5,8], [14,17], [3,5], [17,19],
		[3,4], [18,19], [6,10], [11,16], [13,16], [6,9], [16,17], [5,6],
		[4,5], [7,9], [17,18], [12,15], [14,15], [8,12], [7,8], [13,15],
		[15,17], [5,7], [9,10], [10,14], [6,11], [14,16], [15,16], [6,7],
		[10,11], [9,12], [11,13], [13,14], [8,9], [7,8], [14,15], [9,10],
		[8,9], [12,14], [11,12], [12,13], [10,11], [11,12]]},
);

#
# The hash that will return the nw_best keys by input number.
#
my %nw_best_by_input;

#
# Set up %nw_best_by_input.
#
INIT
{
	for my $k (keys %nw_best_by_name)
	{
		my $inputs = ${$nw_best_by_name{$k}}{inputs};

		if (exists $nw_best_by_input{$inputs})
		{
			push @{$nw_best_by_input{$inputs}}, $k;
		}
		else
		{
			$nw_best_by_input{$inputs} = [$k];
		}
		#print STDERR "$inputs: " . join(", ", @{$nw_best_by_input{$inputs}}) . "\n";
	}
}

#
# Return a list of the available inputs.
#
sub nw_best_inputs_range
{
	return keys %nw_best_by_input;
}

#
# Return the inputs for a sorting network given its name.
#
sub nw_best_inputs
{
	my($name) = @_;

	unless (defined $name and exists $nw_best_by_name{$name})
	{
		carp "No 'best' sorting networks exist for name '$name'";
		return undef;
	}

	return $nw_best_by_name{$name}{inputs};
}

#
# Return a list of keys for the 'best' networks given
# the number of inputs needed to sort.
#
sub nw_best_names
{
	my($inputs) = @_;

	return keys %nw_best_by_name unless (defined $inputs);

	unless (exists $nw_best_by_input{$inputs})
	{
		carp "No 'best' sorting networks exist for size $inputs";
		return ();
	}

	return @{$nw_best_by_input{$inputs}};
}

#
# @network = nw_best_title($key);
#
# The function that finds the title of the network.
#
sub nw_best_title
{
	my $key = shift;
	
	unless (exists $nw_best_by_name{$key})
	{
		carp "Unknown 'best' name '$key'.";
		return ();
	}

	return $nw_best_by_name{$key}{title};
}

#
# @network = nw_best_comparators($key, %options);
#
# The function that finds the network.  Return a list of comparators (a
# two-item list) that will sort an n-item list.
#
sub nw_best_comparators
{
	my $key = shift;
	my(%opts) = @_;
	my @comparators;
	my $inputs;
	
	unless (exists $nw_best_by_name{$key})
	{
		carp "Unknown 'best' key '$key'.";
		return ();
	}

	@comparators = @{$nw_best_by_name{$key}{comparators}};
	$inputs = ${$nw_best_by_name{$key}}{inputs};

	#
	# Instead of using the list as provided by the algorithms,
	# re-order it using the grouping for the graphs. This makes
	# use of parallelism (and less stalling when used in a pipeline).
	#
	if (exists $opts{grouping} and
		($opts{grouping} eq 'group' or $opts{grouping} eq 'parallel'))
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


1;
__END__

=pod

=encoding UTF-8

=head1 NAME

Algorithm::Networksort::Best - Sorting Networks Created by Non-Heuristic Means.

=head1 SYNOPSIS

  use Algorithm::Networksort qw(:all);
  use Algorithm::Networksort::Best qw(:all);

  my $inputs = 9;
  my @network;

  #
  # First find if any networks exist for the size you want.
  #
  my @nwkeys = nw_best_names($inputs);

  #
  # Having selected an optimal sorting network, get the comparators.
  #
  @network = nw_best_comparators('floyd09');

  #
  # Print the list, and print the graph of the list.
  #
  print nw_format(\@network), "\n";
  print nw_graph(\@network, $inputs), "\n";

=head1 DESCRIPTION

For some inputs, sorting networks have been discovered that are more efficient
than those generated by rote algorithms. The "Best" module allows you to use
those networks instead.

In general, there is no guarantee that it will return the best network for
all cases. Usually "best" means that the module will return a lower number of
comparators for the number of inputs than the algorithms in Algorithm::Networksort
will return. Some will simply have a lower number of comparators, others may have
a smaller depth but an equal or greater number of comparators.

The current networks are:

=head2 9-Input Networks

=over 4

=item floyd09

A 9-input network of depth 9 discovered by R. W. Floyd.

=item senso09

A 9-input network of depth 8 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 10-Input Networks

=over 4

=item waksman10

a 10-input network of depth 9 found by A. Waksman.

=item senso10

A 10-input network of depth 8 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 11-Input Networks

=over 4

=item shapirogreen11

An 11-input network of depth 9 found by G. Shapiro and M. W. Green.

=item senso11

A 11-input network of depth 10 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 12-Input Networks

=over 4

=item shapirogreen12

A 12-input network of depth 9 found by G. Shapiro and M. W. Green.

=item senso12

A 12-input network of depth 9 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 13-Input Networks

=over 4

=item end13

A 13-input network of depth 10 generated by the END algorithm, by Hugues Juill�.

=item senso13

A 13-input network of depth 12 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 14-Input Networks

=over 4

=item green14

A 14-input network of depth 10 created by taking the 16-input network of M. W. Green and removing the
inputs 15 and 16.

=item senso14

A 14-input network of depth 11 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 15-Input Networks

=over 4

=item green15

A 15-input network of depth 10 created by taking the 16-input network of M. W. Green and removing the
16th input.

=item senso15

A 15-input network of depth 10 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 16-Input Networks

=over 4

=item green16

A 16-input network of depth 10 found by M. W. Green.

=item senso16

A 16-input network of depth 10 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 17-Input Networks

=over 4

=item senso17

A 17-input network of depth 17 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=item sat17

17-input network of depth 10 found by M. Codish, L. Cruz-Filipe, T. Ehlers, M. M�ller, P. Schneider-Kamp.

=back

=head2 18-Input Networks

=over 4

=item alhajbaddar18

18-input network of depth 11 found by Sherenaz Waleed Al-Haj Baddar.

=item senso18

A 18-input network of depth 15 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 19-Input Networks

=over 4

=item senso19

A 19-input network of depth 15 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 20-Input Networks

=over 4

=item sat20

20-input network of depth 11 found by M. Codish, L. Cruz-Filipe, T. Ehlers, M. M�ller, P. Schneider-Kamp.

=item senso20

A 20-input network of depth 14 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 21-Input Networks

=over 4

=item senso21

A 21-input network of depth 20 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 22-Input Networks

=over 4

=item alhajbaddar22

22-input network of depth 12 found by Sherenaz Waleed Al-Haj Baddar.

=item senso22

A 22-input network of depth 15 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 23-Input Networks

=over 4

=item senso23

A 23-input network of depth 22 found using the SENSO program by V. K. Valsalam and R. Miikkulaainen.

=back

=head2 Export

None by default. There is only one available export tag, ':all', which
exports the functions to create and use sorting networks. The functions are
nw_best() and nw_best_key().

=head2 Functions

=head3 nw_best_inputs_range

Returns the list of input values covered by the 'best' sorting networks.

=head3 nw_best_inputs

Returns the key names of the sorting networks, given an input size.
The keys are used to retrieve a sorting network from nw_best_comparators().

=head3 nw_best_names

Return the list of keys to access the individual networks by key name. The
keys are used to retrieve a sorting network from nw_best_comparators().

=head3 nw_best_title

Return a descriptive title for the network, given a key.

=head3 nw_best_comparators

Return the list of comparators, given a key. The list is
identical in form to a list returned by nw_comparator(), and like
nw_comparator(), it takes an option 'grouping'.

=head1 ACKNOWLEDGMENTS

L<Doug Hoyte|https://github.com/hoytech> pointed out Sherenaz Waleed Al-Haj Baddar's paper.

L<Morwenn|https://github.com/Morwenn> found for me the SAT and SENSO papers, and caught
documentation errors.

=head1 SEE ALSO

=over 4

=item

Donald E. Knuth, The Art of Computer Programming, Vol. 3: (2nd ed.)
Sorting and Searching, Addison Wesley Longman Publishing Co., Inc.,
Redwood City, CA, 1998.

=item

The Evolving Non-Determinism (END) algorithm by Hugues Juill� has found more efficient
sorting networks: L<http://www.cs.brandeis.edu/~hugues/sorting_networks.html>.

=item

The 18 and 22 input networks found by Sherenaz Waleed Al-Haj Baddar
are described in her paper "Finding Better Sorting Networks" at
L<http://etd.ohiolink.edu/view.cgi?acc_num=kent1239814529>.

=item

The Symmetry and Evolution based Network Sort Optimization (SENSO) found more
networks for inputs of 9 through 23.

=back

=head1 AUTHOR

John M. Gamble may be found at B<jgamble@cpan.org>

=cut


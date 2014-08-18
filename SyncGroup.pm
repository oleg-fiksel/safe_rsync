package SyncGroup;
use strict;
use warnings;
use diagnostics;

use FindBin qw($Bin);
use lib $Bin, $Bin.'/modules/lib/perl5';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
	
	my %vars = @_;
	
	die "Source must be defined (src => ...)!" if !defined $vars{src};
	die "Destination must be defined (dest => ...)!" if !defined $vars{dest};
	
	foreach my $k (keys(%vars)){
		$self->{config}->{$k} = $vars{$k};
	}
	
    return $self;
}

# http://www.perlmonks.org/?node_id=109872
#sub _gcd {
#	my $self = shift;
#	my ($a, $b) = @_;
#	($a,$b) = ($b,$a) if $a > $b;
#	while ($a) {
#		($a, $b) = ($b % $a, $a);
#	}
#	return $b;
#}

#sub _calcProportion{
#	my $self = shift;
#	
#	my $source = $self->{config}->{src}->{size};
#	my $destination = $self->{config}->{dest}->{size};
#	
#	if ($destination == 0) {
#		$self->{proportion}->{source} = 0;
#		$self->{proportion}->{destination} = 0;
#		return 0;
#	}
#	
#	my $gcd = $self->_gcd($source, $destination);
#	print "GCD: $gcd",$/ if $self->{config}->{debug};
#	$self->{proportion}->{gcd} = $gcd;
#	
#	$self->{proportion}->{source} = $source/$gcd;
#	$self->{proportion}->{destination} = $destination/$gcd;
#	
#	print "Proportion: source / destination: ",
#		$self->{proportion}->{source},
#		" / ",
#		$self->{proportion}->{destination},
#		$/
#			if $self->{config}->{debug};
#}

#sub getProportions{
#	my $self = shift;
#	
#	return ($self->{proportion}->{source},$self->{proportion}->{destination});
#}


sub _percentOf{
	my $self = shift;
	my $s = shift;
	my $d = shift;

	return int( $s / ($d / 100) );
}

sub isSourceUnderThreshold{
	my $self = shift;
	my $threshold = shift;
	
	return 0 if $self->{config}->{dest}->{size} == 0;
	return 1 if $self->{config}->{src}->{size} == 0;
	
	my $percent = $self->_percentOf($self->{config}->{src}->{size}, $self->{config}->{dest}->{size});
	print "Source is ".$percent."% of destination (threshold: $threshold)",$/
		if $self->{config}->{verbose};
	
	return 0 if $percent >= $threshold;
	return 1;
}

1;
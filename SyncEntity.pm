package SyncEntity;
use strict;
use warnings;
use diagnostics;

use FindBin qw($Bin);
use lib $Bin, $Bin.'/modules/lib/perl5';
use Filesys::DiskUsage qw/du/;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
	
	my %vars = @_;
	
	die "Directory must be defined (dir => '/dir')!" if !defined $vars{dir};
	foreach my $k (keys(%vars)){
		$self->{config}->{$k} = $vars{$k};
	}
	
	$self->_init();
    return $self;
}

sub getSize{
	my $self = shift;
	return $self->{size};
}

sub _init{
	my $self = shift;
	
	# get size
	$self->{size} = du($self->{config}->{dir});
}

1;
#!/usr/bin/perl -w
use strict;
use warnings;
use diagnostics;

use FindBin qw($Bin);

# custom modules
use lib $Bin, $Bin.'/modules/lib/perl5';
use Filesys::DiskUsage qw/du/;

# own modules
use SyncEntity;
use SyncGroup;

# core modules
use Getopt::Long;
use Data::Dumper;

my $source;
my $destination;
my $size_threshold = 80;
my @excludes;
my $rsyncCmd = 'rsync -aru -P --delete';
my $run = 0;
my $help = 0;
my $verbose = 0;
my $debug = 0;

GetOptions(
	"source=s" => \$source,
	"destination=s" => \$destination,
	"threshold=i" => \$size_threshold,
	"exclude=s" => \@excludes,
	"rsync-cmd=s" => \$rsyncCmd,
	"run" => \$run,
	"help" => \$help,
	"debug" => \$debug,
	"verbose" => \$verbose,
    ) or die "Error in command line arguments.";

die <<EOF
Usage:
$0 -source /path/to/your/source/ -destination /path/to/your/destination/ [-run] [-exclude blah] [-size-threshold $size_threshold] [-verbose] [-debug] [--help]

    -source         source path
    -destination    destination path
                    NOTICE: for synching two directories put "/" (backslash) after each one (rsync speciality)
    
    -threshold      threshold in % from which the sync will not be done
                    if destination will exceed in size to given % the rsync will not be done
                    default is $size_threshold
    -exclude        exclude path from sync
    -rsync-cmd      rsync command which will be used to sync directories (default: $rsyncCmd)
    -run            default ist a dry run, use this to actually run the sync

EOF
if $help;

die "Can't read source!" if !-r $source;
die "Can't read destination!" if !-r $destination;
die "-threshold must be >0 and <100 (currently: $size_threshold)" if $size_threshold <0 || $size_threshold >100;
$verbose = $debug if $debug;

main();
exit 0;

sub main{
	print "Calculating folder sizes...",$/ if $verbose;
	my $sourceObj = SyncEntity->new(
								 dir => $source,
								 verbose => $verbose,
								 debug => $debug,
								 );

	my $destinationObj = SyncEntity->new(
								 dir => $destination,
								 verbose => $verbose,
								 debug => $debug,
								 );
	print "Source size: ",$sourceObj->getSize(),$/ if $verbose;
	print "Destination size: ",$destinationObj->getSize(),$/ if $verbose;
	
	my $syncGroup = SyncGroup->new(
									src => $sourceObj,
									dest => $destinationObj,
									verbose => $verbose,
									debug => $debug,
								   );
	
	die "Source is < $size_threshold% of destination, exiting!"
		if $syncGroup->isSourceUnderThreshold($size_threshold);

	# generate rsync compatible exclude string
	my $exclude_string =  join " ", map("--exclude '".$_."'", @excludes);
	# build up a command to execute
	my $cmd=$rsyncCmd." $exclude_string \"$source\" \"$destination\"";
	print "Exec: ".$cmd.$/ if $verbose;
	system($cmd) if $run;
}

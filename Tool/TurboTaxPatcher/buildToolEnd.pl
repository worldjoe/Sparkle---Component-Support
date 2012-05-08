";

#require "DirCompare.pm";
my $encodedData = new IO::File(">$uutempdir/foo.uu");
print $encodedData $uuencode;
`cat $uutempdir/foo.uu | uudecode -o $uutempdir/foo.zip`;
`unzip -o $uutempdir/foo.zip -d $uutempdir/`;
if ($? != 0)
{
	print "Failed to extract Sparkle's BinaryDelta tool.";
	exit 1;
}


my $arguments;
my $action = shift @ARGV;
$arguments = join '" "', @ARGV;
$arguments = "$action \"$arguments\"";
#print "$uutempdir/BinaryDelta $arguments\n";
my $beforeTree = $ARGV[0];
my $afterTree = $ARGV[1];
my $patchFile = $ARGV[2];
`$uutempdir/BinaryDelta $arguments`;
if ($? != 0)
{
	print "Sparkle's BinaryDelta tool returned an error.";
	exit 1;
}

#print "$uutempdir/BinaryDelta $arguments\n";
if ($patchFile)
{
	
	print "Temp dir: $uutempdir\n";
	
	# pull the patcher out of here
	$encodedData = new IO::File(">$uutempdir/patcher.uu");
	print $encodedData $patcher;
	`cat $uutempdir/patcher.uu | uudecode -o $uutempdir/patcher.zip`;
	`unzip -o $uutempdir/patcher.zip -d $uutempdir/`;
	if ($? != 0)
	{
		print "Failed to extract TurboTaxPatcher.";
		exit 1;
	}

	my $patchFileName = basename($patchFile);
	
	`mv $patchFile  $uutempdir/TurboTaxPatcher.app/Contents/Resources/patch.delta`;
	if ($? != 0 || !-e "$uutempdir/TurboTaxPatcher.app/Contents/Resources/patch.delta")
	{
		print "Failed to create patch.delta";
		exit 1;
	}

	`cd $uutempdir/; tar zcfv $patchFileName TurboTaxPatcher.app/`;
	if ($? != 0)
	{
		print "Failed to create patch tar.gz.";
		exit 1;
	}
	`mv $uutempdir/$patchFileName $patchFile`;
	if ($? != 0)
	{
		print "Failed to move patch into place.";
		exit 1;
	}
}
exit;
";

#require "DirCompare.pm";

my $oldArchive = '';
my $archive = '';
my $dir = '';
my $version = '';
my $man = '';
my $help = '';
my $verbose;

GetOptions('oldprime=s' => \$oldArchive, 'archive=s' => \$archive, 'target=s' => \$dir, 'version' => \$version, 'verbose' => \$verbose, 'help' => \$help);

if ($version ne '')
{
	print "createPrime Version 4.5\n";
	exit;
}

print "Archive : $archive\n" if $verbose;
print "Directory name : $dir\n" if $verbose;

if ($dir eq '' || $archive eq '' || $help)
{
	print "Options:\n";
	print "--oldprime:	The directory of the old application.\n";
	print "		Skip this argument when their is no previous version.\n";
	print "\n";
	print "--archive:	The location of where the new prime file should be created\n";
	print "\n";
	print "--target:	The location of the target component files\n";
	print "\n";
	print "--help:		Print out this help message\n";
	print "\n";
	print "--verbose:	Print out verbose debug messages\n";
	print "\n";
	print "Example: \n";
	print " Create a prime patch of version 150, passing in the old version 130:\n";
	print "	./createPrime.pl --oldprime /Applications/TurboTax\ Deluxe\ 2009.app/ --archive /Users/jelwell/2to3.tar.gz --target /Users/jelwell/Desktop/junk/TurboTax2011.app/Contents/ --verbose/";
	print "\n";
	print " Create a prime patch of version 130, no previous builds, so not passing in an older version\n";
	print "	./createPrime.pl --archive=/Users/jelwell/Desktop/patching/130.tar.gz --target /Users/jelwell/Desktop/patching/TurboTax\\ Deluxe\\ 2010.app/Contents/\n";
	print "\n";
	print "Output:\n";
	print "	.prime file:\n";
	print "		This is actually a tar.gz file with two files inside:\n";
	print "		output.xml	- Listing of every file that should be deleted before applying\n";
	print "		version.tar.gz	- tar.gz of files that should be extracted ontop of application\n";
	exit;
}
$dir = "$dir/Contents/";
my $oldArchiveFileName = basename($oldArchive);
my $targetDirectory = dirname("$dir");
my $targetFileName = basename("$dir");

my $primeFilename = $archive;# . ".prime";
my $outputDirectory = dirname("$archive");
my $primeFilenameBase = basename($archive . ".prime");
print "Prime name : $primeFilename\n" if $verbose;

my $internalTarGzFileName = "patch.prime.tar.gz";
my $internalTarGzFileNameWithDirectory = "$outputDirectory/patch.prime.tar.gz";
my $internalFileName = "patch.prime";

my $xmlFilename = $archive . ".xml";
my $targzFilename = $archive . ".tar.gz";
my $targzFilenameBase = basename($targzFilename);

#check to make sure target prime file doesn't already exist
die "Oops! A file called '$primeFilename' already exists.\n"
if -e $primeFilename;

print "Archive name : $targzFilename\n" if $verbose;
print "Directory name : $dir\n" if $verbose;


print "cd \"$targetDirectory\"; tar cfvz \"$outputDirectory/$internalTarGzFileName\" \"$targetFileName\" 2>&1\n" if $verbose;
my $result = `cd \"$targetDirectory\"; tar cfvz \"$outputDirectory/$internalTarGzFileName\" \"$targetFileName\" 2>&1`;
print $result if $verbose;

#create the list of file deletions
#my $tempdir = tempdir( CLEANUP => 0 );
my $tempdir = tempdir( "com.intuit.TurboTaxXXXXXXXXXXXXXXXX", TMPDIR => 1, CLEANUP => 0);
print "Temp dir = $tempdir\n" if $verbose;

#first extract the old prime
if (-s $oldArchive)
{
	#	print $oldArchive;
	my $tempextractDir = tempdir(); # CLEANUP => 1 );
	#	print $tempextractDir;
	#`cp $oldArchive "$tempextractDir"`;
	my $fullPath = "$oldArchive/Contents";
	
	print "$fullPath\n" if $verbose;
	#my $result = `cd $tempextractDir ; tar xfvz $fullPath 2>&1; tar xfvz $internalFileName.tar.gz 2>&1`;
	#print $result if $verbose;
	#print "cd $tempextractDir ; rm $oldArchiveFileName $internalFileName.tar.gz\n" if $verbose;
	#`cd $tempextractDir ; rm $oldArchiveFileName $internalFileName.tar.gz`;
	
	
	
	#write out the xml file that lists the deletes
	#	print "cp $tempextractDir/output.xml  $tempdir/output.xml\n" if $verbose;
	#	`cp "$tempextractDir/output.xml"  "$tempdir/output.xml"`;
	`touch "$tempdir/output.xml"`;
	open (XMLFILE, ">$tempdir/output.xml");
	print XMLFILE "<total>\n";
	close (XMLFILE);
	my $xmlPath = "$tempdir/output.xml"; 
	print "xmlPath : $xmlPath\n" if $verbose;
	
	#delete the last </total> line from the file
	#	open (FH, "+< $xmlPath")               or die "can't update $xmlPath: $!";
	#	my $addr;
	#	while ( <FH> ) {
	#		$addr = tell(FH) unless eof(FH);
	#	}
	#	truncate(FH, $addr)                 or die "can't truncate $xmlPath: $!";
	#	close(FH);
	
	my $output = new IO::File(">>$xmlPath");
	my $writer = new XML::Writer(OUTPUT => $output, NEWLINES => 1);
	
	my $sourceDirectory = "/Users/jelwell/Downloads/patching/bar";
	#my $targetDirectory = "/Users/jelwell/Downloads/patching/foo";
	my @differences;
	#TODO JOEY
	#	The source directory name contains "TurboTax Deluxe 2010.app", that's too hard to figure out once it's extracted
	#	It needs to not be there when creating the prime in the first place.
	
	print "diff -r $tempextractDir/$targetFileName $dir\n" if $verbose;

	$sourceDirectory = quotemeta $fullPath;
	print "SourceDirectory: $sourceDirectory\n" if $verbose;
	#push @differences , `diff -r $tempextractDir $dir`;
	#push @differences , `diff -r $sourceDirectory $targetDirectory`;
	print "diff -r \"$fullPath\" \"$dir\"\n" if $verbose;
	push @differences , `diff -r "$fullPath" "$dir"`;
	#push @differences , `diff -r $sourceDirectory "/Users/jelwell/moving/sparkle/2"`;
	foreach (@differences) {
		#		print "$_\n";
		if ($_ =~ "Only in $sourceDirectory(.*): (.*)\n")
		{
#			print "Joey : $_\n" if $verbose;
			my $deletedFile = $2;
			my $deletedFolder = $1;
			# if an entire directory is deleted,
			# we need to list out the files in the directory
			# not just the folder, in case the folder is shared with
			# other components
			my $cpath = File::Spec->canonpath( "$fullPath$deletedFolder/$deletedFile" ) ;
			print "$cpath\n"; #$sourceDirectory$deletedFolder/$deletedFile\n";
			if (-d "$cpath")
			{
				print "Found a deleted folder\n";
#				find( sub {print "$File::Find::name$/"},$cpath);
				find( sub {my $recurseDeleteFile = File::Spec->abs2rel($File::Find::name, $fullPath); $writer->emptyTag("files", "delete" => "$recurseDeleteFile");$writer->end();},$cpath);
			}
			else
			{
				$writer->emptyTag("files", "delete" => "$deletedFolder/$deletedFile");
				$writer->end();
			}
		}
	}
	#$writer->endTag("total");
	$output->close();
	open (XMLFILE, ">> $xmlPath")               or die "can't update $xmlPath: $!";
	print XMLFILE "</total>";
	
	#
	#  File::DirCompare->compare($tempextractDir, "$dir", sub {
	#    my ($a, $b) = @_;
	#    if (! $b) {
	#      printf "Only in %s: %s\n", dirname($a), basename($a);
	##      $writer->emptyTag("files", "delete" => $a);
	##      $writer->end();
	#    } elsif (! $a) {
	##      $writer->emptyTag("files", "delete" => $a);
	##      $writer->end();
	#      printf "Only in %s: %s\n", dirname($b), basename($b);
	#    } else {
	#      print "Files $a and $b differ\n";
	#    }
	#  });
	
	#$output->close();
	
	
	#rename($xmlPath, $xmlFilename);
	print "cd \"$tempdir\"; mv \"$internalTarGzFileNameWithDirectory\" . ; tar cfv \"$primeFilenameBase\" \"$internalTarGzFileName\" output.xml\n" if $verbose;
	my $tarResult = `cd \"$tempdir\"; mv \"$internalTarGzFileNameWithDirectory\" . ; tar cfv \"$primeFilenameBase\" \"$internalTarGzFileName\" output.xml 2>&1`;
	print $tarResult if $verbose;
	rename("$tempdir/$primeFilenameBase", "$primeFilename");
	if (!-e "$primeFilename")
	{
		print "Failed to create patch.tar.gz";
		exit 1;
	}
	print "rename $tempdir/$primeFilenameBase $primeFilename\n" if $verbose;
	
	#TODO JOEY
	#cleanup
	#`cd \"$tempdir\"; mv \"$targzFilename\" . ; cd \"$targetDirectory\"; tar cfv \"$primeFilename\" \"$targzFilename\" \"$xmlPath\"`;
}
else
{
	
	#JOEY TODO
	#	this prime file needs an empty output.xml with the delete entries
	#for now just rename the tgz
	#rename($targzFilename, $primeFilename);
	print "empty old prime. First run?\n" if $verbose;
	print "cd \"$targetDirectory\"; tar cfvz \"$internalTarGzFileName\" \"$targetFileName\" 2>&1\n" if $verbose;
	my $result = `cd \"$targetDirectory\"; tar cfvz \"$internalTarGzFileName\" \"$targetFileName\" 2>&1`;
	`touch "$tempdir/output.xml"`;
	
	#need to encapsulate the file list to create valid XML
	#also need to seed the output.xml file with the encapsulation
	# so that future prime patches will alredy have the data
	open (XMLFILE, ">$tempdir/output.xml");
	print XMLFILE "<total>\n";
	print XMLFILE "</total>";
	close(XMLFILE);
	
	print "cd \"$tempdir\"; mv \"$internalTarGzFileNameWithDirectory\" . ; tar zcfv \"$primeFilenameBase\" \"$internalTarGzFileName\" output.xml 2>&1" if $verbose;
	my $tarResult = `cd \"$tempdir\"; mv \"$internalTarGzFileNameWithDirectory\" . ; tar zcfv \"$primeFilenameBase\" \"$internalTarGzFileName\" output.xml 2>&1`;
	print $tarResult if $verbose;
	rename("$tempdir/$primeFilenameBase", "$primeFilename");
	if (!-e "$primeFilename")
	{
		print "Failed to create patch.tar.gz";
		exit 1;
	}
}

#merge the list of file deletions into the tgz
# pull the patcher out of here
my $encodedData = new IO::File(">$tempdir/patcher.uu");
print $encodedData $patcher;
`cat $tempdir/patcher.uu | uudecode -o $tempdir/patcher.zip`;
`unzip -o $tempdir/patcher.zip -d $tempdir/`;
if ($? != 0)
{
	print "Failed to extract the Patcher";
	exit 1;
}

`mv $primeFilename  $tempdir/TurboTaxPatcher.app/Contents/Resources/patch.tar.gz`;
if ($? != 0)
{
	print "Failed to move patch.tar.gz into place";
	exit 1;
}
`cd $tempdir/; tar zcfv $primeFilenameBase TurboTaxPatcher.app/`;
if ($? != 0)
{
	print "Failed to tar up the TurboTaxPatcher.";
	exit 1;
}
`mv $tempdir/$primeFilenameBase $primeFilename`;
if ($? != 0)
{
	print "Failed to move Packaged patch into place";
	exit 1;
}
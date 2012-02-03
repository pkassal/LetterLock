#!C:/Perl/bin/perl

## perl script to:
## - take a file
## - produce a tag-style output file of derived information which is
##   hopfully of use in building related term info
## - pretend this works okay

$infile = $ARGV[0];
$outbase = $ARGV[1];

# slurp whole file
if ($infile =~ m/\.gz$/)
{
    open(IN, "zcat $infile| ") || die "Can't locate file $infile: $!\n";
}
else
{
    open(IN, "$infile") || die "Can't locate file $infile: $!\n";
}
$file = do {local $/, <IN>};
close IN;

# loop over xml files withing
while ($file =~ m|(<page>.*?</page>)(.*)|gs)
{
    $thisFile = $1;
    $file = $2;

    if ($thisFile =~ m|<title>(.*?)</title>|)
    {
	$thisTitle = $1;
    }
    else
    {
	die "no title!\n";
    }

    if ($thisTitle =~ m|(.)|)
    {
	$StartLetter = $1;
    }
    else
    {
	die "no start letter\n";
    }

    if ($StartLetter !~ m/[A-Z0-9]/)
    {
	print "Skipping $thisTitle\n";
	next;
    }
    # skip unfriendly chars
    if ($thisTitle !~ m/^[A-Za-z0-9 ]+$/)
    {
	print "Skipping $thisTitle\n";
	next;
    }

    # check for need dir:
    if (!(-d "$outbase/$StartLetter"))
    {
	mkdir "$outbase/$StartLetter";
    }

    # write out some shtuff
    $thisTitleFileName = $thisTitle;
    $thisTitleFileName =~ s/ /_/g;
    $outfile = "$outbase/$StartLetter/$thisTitleFileName";
    open(OUT, ">$outfile") || die "Can't locate file $outfile: $!\n";

    print OUT "title:$thisTitle\n";

    ## categories
    while ($thisFile =~ m|\n\[\[Category:(.*?)[\|\]]|gs)
    {
	$cat = $1;
	print OUT "category:$cat\n";
    }

    ## See alsos
    if ($thisFile =~ m|\n==See also==\n(.*?)\n\n|gs)
    {
	$seealsolist = $1;
	# mask off links not back into wikipedia
	$seealsolist =~ s/\{\{.*?\}\}//gs;
	#print "have it\n";
	while ($seealsolist =~ m|\[\[(.*?)\]\](.*)|s)
	{
	    $thisOne = $1;
	    $seealsolist = $2;
	    if ($thisOne =~ m/\|/)
	    {
		$thisOne =~ s/\|.*//;
	    }
	    print OUT "seealso:$thisOne\n";
	}
    }

    # tags in paragraphs:
    # endingish phrases: References, See also, External links
    $rest = "";
    # External links
    if (($rest eq "") &&
	($thisFile =~ m|<text (.*?)\n== ?External links|s))
    {
	$rest = $1;
    }
    if (($rest eq "") &&
	($thisFile =~ m|<text (.*?)\n== ?References|s))
    {
	$rest = $1;
    }
    if (($rest eq "") &&
	($thisFile =~ m|<text (.*?)\n== ?See also|s))
    {
	$rest = $1;
    }
    if (($rest eq "") &&
	($thisFile =~ m|<text (.*?)\n== ?References|s))
    {
	$rest = $1;
    }

    # mask off links not back into wikipedia
    $rest =~ s/\{\{.*?\}\}//gs;
    while ($rest =~ m|\[\[(.*?)\]\](.*)|s)
    {
	$theLink = $1;
	$rest = $2;
	if ($theLink =~ m/\|/)
	{
	    $theLink =~ s/\|.*//;
	}
	print OUT "link:$theLink\n";
    }

    close OUT;
}


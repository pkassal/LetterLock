#!C:/Perl/bin/perl

## perl script to:
## - slurp up category map info
## - pore over intermediate data
## - strip certain categories, based on frequency, delete status, etc.
## - build puzzle for each file
## - save out in dir structure for each chosen sample
## - constrain the number of samples per category by random sampling and
##   overwriting files
## - also load and use a link stop list
## - all this for the Japanese style puzzle formulation

## version stolen from is saving categories/hints first, then numbers,
## then the clues/answers/lines in reverse order. Up to seven shown right
## now in actual puzzle. I can shrink this to what I want here, and reverse
## the order with the understanding things go in the order given
## Keeps exactly 4 links, which in combination with the final answer produce
## 5 total words/phrases to guess

srand;

$catmapfile = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/stats/catmap.txt";
$linkstopfile = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/stats/linkstops.txt";
$classnamefile = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/stats/classnames.txt";
#$InBase = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/nicerout";
#$OutBase = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/puzzle1";
#$OutBase = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/puzzle2";
$MaxKeepCats = 5;
### now, from xml files:
$InBase = "/cygdrive/y/finance/wiqui/datasets/xml1/nicerout";
$OutBase = "/cygdrive/y/finance/wiqui/datasets/japanese/puzzle2";

$MinAnswersTotal = 5;
$MaxAnswersTotal = 5;

@colorlist = ("blue", "green", "red", "orange", "purple", "pink", "tan",
	      "brown", "yellow");
## make a fix assignment from colors to indexes which are used to convey
## info to output file. Need a steady mapping here so that the random usage
## of colors isn't washed out.
$UseColorIdxVal = 0;
foreach $color (@colorlist)
{
    $UseColorIdx{$color} = $UseColorIdxVal;
    $UseColorIdxVal++;
}
RandomSortColors();

$GlobalFreqs{"a"} = 5;
$GlobalFreqs{"b"} = 5;
$GlobalFreqs{"c"} = 5;
$GlobalFreqs{"d"} = 5;
$GlobalFreqs{"e"} = 5;
$GlobalFreqs{"f"} = 5;
$GlobalFreqs{"g"} = 5;
$GlobalFreqs{"h"} = 5;
$GlobalFreqs{"i"} = 5;
$GlobalFreqs{"j"} = 5;
$GlobalFreqs{"k"} = 5;
$GlobalFreqs{"l"} = 5;
$GlobalFreqs{"m"} = 5;
$GlobalFreqs{"n"} = 5;
$GlobalFreqs{"o"} = 5;
$GlobalFreqs{"p"} = 5;
$GlobalFreqs{"q"} = 5;
$GlobalFreqs{"r"} = 5;
$GlobalFreqs{"s"} = 5;
$GlobalFreqs{"t"} = 5;
$GlobalFreqs{"u"} = 5;
$GlobalFreqs{"v"} = 5;
$GlobalFreqs{"w"} = 5;
$GlobalFreqs{"x"} = 5;
$GlobalFreqs{"y"} = 5;
$GlobalFreqs{"z"} = 5;

# make primary subdirs
$ClassOutBase = "$OutBase/classes/";
if (! (-d $ClassOutBase))
{
    mkdir $ClassOutBase;
}
$CatOutBase = "$OutBase/categories/";
if (! (-d $CatOutBase))
{
    mkdir $CatOutBase;
}
$NumberOutBase = "$OutBase/number/";
if (! (-d $NumberOutBase))
{
    mkdir $NumberOutBase;
}

##@subs = split(//, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");
@subs = split(//, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");

# slurp cat map info
open(IN, "$linkstopfile") || die "Can't locate file $linkstopfile: $!\n";
while ($line = <IN>)
{
    $line =~ s/[\r\n]*//g;
    ($count, $rest) = split(/\t/, $line);
    $rest =~ s/link://;
    $LinkStop{$rest} = 1;
}
close IN;

# slurp cat map info
open(IN, "$catmapfile") || die "Can't locate file $catmapfile: $!\n";
while ($line = <IN>)
{
    $line =~ s/[\r\n]*//g;
    ($count, $class, $catinfo) = split(/\t/, $line);
    # skip delete cats
    if ($class eq "delete")
    {
	next;
    }
    # skip rare ones
    if ($count < 5)
    {
	next;
    }
    #print "Setting:$catinfo:\n";
    $ClassMap{$catinfo} = $class;
    $CountMap{$catinfo} = $count;
    $Seen{$catinfo} = 0;
    $Written{$catinfo} = 0;
}
close IN;

# allow some helper word repeats
$AllowedRepeats{"of"} = 1;
$AllowedRepeats{"in"} = 1;
$AllowedRepeats{"from"} = 1;
$AllowedRepeats{"the"} = 1;
$AllowedRepeats{"and"} = 1;
$AllowedRepeats{"by"} = 1;
$AllowedRepeats{"with"} = 1;
$AllowedRepeats{"to"} = 1;

$PuzzleIndex = 0;

## try for sample article:
#MakePuzzle("/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/nicerout/B/Baseball");
#MakePuzzle("/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/nicerout/B/Baseball_park");
#MakePuzzle("/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/nicerout/B/Basilosaurus");
#WriteClassMasterFile();
#WriteNumberMasterFile();
#PatchFilesRecursively($OutBase);

# need to also write total number of puzzles to a file?
#PatchFile("/cygdrive/y/finance/wiqui/datasets/japanese/puzzle1/number/0/0.txt");
#PatchFile("/cygdrive/y/finance/wiqui/datasets/japanese/puzzle1/number/0/1.txt");
#PatchFile("/cygdrive/y/finance/wiqui/datasets/japanese/puzzle1/number/0/2.txt");
#die "done!\n";

# now march over the dirs
foreach $sub (@subs)
{
    $thisIndir = "$InBase/$sub";
    opendir($dh, $thisIndir);
    while($fname = readdir $dh) 
    {
	if ($fname =~ m/^\./)
	{
	    next;
	}
	$inputfile = "$thisIndir/$fname";
	if ((rand 1.0) > 0.30)
	{
	    next;
	}
	print "Processing $inputfile\n";
	MakePuzzle($inputfile);
    }
    closedir $dh;
}

WriteClassMasterFile();
WriteNumberMasterFile();

# now march over the output dir and recursively call subdirs
PatchFilesRecursively($OutBase);

1;

sub PatchFilesRecursively {
    
    my $thisDir = shift;
    my $fname;
    my $dh;

    #print "process dir:$thisDir:\n";
    opendir($dh, $thisDir);
    while($fname = readdir $dh) 
    {
	if ($fname =~ m/^\./)
	{
	    next;
	}

	$fullname = "$thisDir/$fname";
	# process subdirs
	if (-d $fullname)
	{
	    PatchFilesRecursively($fullname);
	}
	else
	{
	    if (-f $fullname)
	    {
		if ($fname eq "master.txt")
		{
		    next;
		}
		#print "patch:$fullname:\n";
		PatchFile($fullname);
	    }
	}
    }
}

sub MakePuzzle {

    $thisInputFile = shift;
    print "processing $thisInputFile\n";
    open(IN, "$thisInputFile") || die "Can't locate file $thisInputFile: $!\n";
    $title = <IN>; $title =~ s/[\r\n]*//g;
    if ($title =~ m/title:(.*)/)
    {
	# map to lowers
	$title = lc($1);
    }
    # skip final answers which aren't all alpha plus spaces
    if ($title !~ m/^[A-Za-z ]+$/)
    {
	#print "return 1\n";
	return;
    }
    # do sloppy stemming
    %twhash = ();
    %cwhash = ();
    %KeepCats = ();
    $NumKeepCats = 0;
    %KeepLinks = ();
    $CurrentLinks= ();
    $NumKeepLinks = 0;
    @twords = split(/\s+/, $title);
    foreach $wd (@twords)
    {
	if (defined($AllowedRepeats{$wd}))
	{
	    next;
	}
	if (length($wd) > 5)
	{
	    $wd = substr($wd, 0, 5);
	}
	#print "Hashing:$wd:\n";
	$twhash{$wd} = 1;
    }
    # next get categories/links and only keep those which don't overlap
    # with stemmed answer words
    while ($line = <IN>)
    {
	$line =~ s/[\r\n]*//g;
	($type, $name) = split(/:/, $line);
	# category-specific checks: frequency, delete
	if ($type eq "category")
	{
	    # skip if too many categories
	    if ($NumKeepCats >= $MaxKeepCats)
	    {
		next;
	    }
	    # skip deleted, rare ones
	    if (!defined($ClassMap{$line}))
	    {
		#print "skippingrare:$line:\n";
		next;
	    }

	    # skip categories with commas or other undesirable chars
	    if ($name !~ m/^[a-zA-Z0-9\- ]*$/)
	    {
		#print "skippingcommas:$line:\n";
		next;
	    }
	    
	    $Result = CheckTitleOverlap(lc($name));
	    # if overlap test fails, move on to next category
	    if ($Result == 0)
	    {
		#print "skippingoverlap:$line:\n";
		next;
	    }
	    # see if have too many for this cat
	    if ($Written{$line} >= 100)
	    {
		#print "skippingtoomanycat:$line:\n";
		next;
	    }
	    # now we keep this category
	    $KeepCats{$NumKeepCats} = $name;
	    $NumKeepCats++;
	    #print "keep cat $name\n";
	    # add to cat word hash
	    # add lc words - but keep case on cat overall
	    @cwords = split(/\s+/, lc($name));
	    foreach $wd (@cwords)
	    {
		if (defined($AllowedRepeats{$wd}))
		{
		    next;
		}
		if (length($wd) > 5)
		{
		    $wd = substr($wd, 0, 5);
		}
		$cwhash{$wd} = 1;
	    }
	}
	else
	{
	    if ($type eq "link")
	    {
		#print "pursue $name\n";
		# make sure not too many taken
		if ($NumKeepLinks >= ($MaxAnswersTotal - 1))
		{
		    #print "skip 0\n";
		    next;
		}
		if ((length($name) < 3) ||
		    (defined($LinkStop{$name})) ||
		    ($name !~ m/^[A-Za-z ]+$/))
		{
		    #print "skip 1\n";
		    next;
		}
		$Result = CheckTitleOverlap(lc($name));
		$CatResult = CheckCategoryOverlap(lc($name));
		# if overlap test fails, move on to next category
		if (($Result == 0) || ($CatResult == 0))
		{
		    #print "skip 2\n";
		    next;
		}
		# map to lowers (let earlier stuff be case sensitive)
		$name = lc($name);
		# no repeats of links
		if (defined($CurrentLinks{$name}))
		{
		    #print "skip 3\n";
		    next;
		}
		$KeepLinks{$NumKeepLinks} = $name;
		$CurrentLinks{$name} = 1;
		#print "keep link $name\n";
		$NumKeepLinks++;
	    }
	    else
	    {
		# skip non-link/categories
		next;
	    }
	}
    }
    close IN;
    
    if (($NumKeepLinks < ($MinAnswersTotal - 1)) || ($NumKeepCats == 0))
    {
	#print "return 2:$NumKeepLinks,$NumKeepCats\n";
	return;
    }

    # try to build puzzle keys - if can't skip this one
    @OrderedList = ();
    $j = 0;
    for ($i = $NumKeepLinks - 1; $i >= 0; $i--)
    {
	$OrderedList[$j] = $KeepLinks{$i};
	$j++;
    }
    # title is the top term:
    $OrderedList[$j] = $title;
    $j++;

    #print "making keys:@OrderedList\n";
    $KeysResult = MakeLogicPuzzleKeys(@OrderedList);
    if ($KeysResult == 0)
    {
	#print "keys result is 0\n";
	return;
    }

    # see if an example of a class
    %theClasses = ();
    for ($i = 0; $i < $NumKeepCats; $i++)
    {
	$theCat = $KeepCats{$i};
	if (!defined($ClassMap{"category:$theCat"}))
	{
	    next;
	}
	$theClasses{$ClassMap{"category:$theCat"}} = 1;
    }

    # build the nonchanging output file - first line is puzzle index
    $OutString = "\"pindex\":$PuzzleIndex, \"cats\":[";
    for ($i = 0; $i < $NumKeepCats; $i++)
    {
	$thisCat = $KeepCats{$i};
	$OutString .= "\"$thisCat\"";
	if ($i < ($NumKeepCats - 1))
	{
	    $OutString .= ", ";
	}
    }
    $OutString .= "], \"index\":[";
    for ($i = 0; $i < $NumKeepCats; $i++)
    {
	$thisCat = $KeepCats{$i};
	$OutString .= $Written{"category:$thisCat"};
	if ($i < ($NumKeepCats - 1))
	{
	    $OutString .= ", ";
	}
    }
    $OutString .= "], ";
    # terms
    $OutString .= "\"answers\":[";
    for ($i = $NumKeepLinks - 1; $i >= 0; $i--)
    {
	$thisLink = $KeepLinks{$i};
	$OutString .= "\"$thisLink\", ";
    }
    # title is the top term:
    $OutString .= "\"$title\"],";

    # insert 3 solution maps
    $OutString .= " \"keys\":[";
    $OutString .= "\"$FateString1\", \"$FateString2\", \"$FateString3\"]"; 

    $OutString .= "}\n";

    # now loop over existing classes and save out if fits
    foreach $class (keys %theClasses)
    {
	# skip if too many samples already
	if ($ClassInstances{$class} >= 200)
	{
	    next;
	}
	if (defined($ClassInstances{$class}))
	{
	    $thisInstance = $ClassInstances{$class};
	}
	else
	{
	    $thisInstance = 0;
	}
	$ClassInstances{$class}++;
	$outdir = "$ClassOutBase/$class";
	if (! (-d $outfile))
	{
	    mkdir $outdir;
	}
	$outfile = "$outdir/$thisInstance.txt";
	open(OUT, ">$outfile") || die "Can't locate file $outfile: $!\n";
	print OUT $OutString;
	close OUT;
    }

    # now loop over kept categories and print puzzle
    for ($i = 0; $i < $NumKeepCats; $i++)
    {
	$thisCategory = $KeepCats{$i};
	# skip if too many samples already
	if ($Written{"category:$thisCategory"} >= 100)
	{
	    next;
	}
	if (defined($Written{"category:$thisCategory"}))
	{
	    $thisInstance = $Written{"category:$thisCategory"};
	}
	else
	{
	    $thisInstance = 0;
	}
	#print "Incrementing:$thisCategory:\n";
	$Written{"category:$thisCategory"}++;
	if (length($thisCategory) > 3)
	{
	    $subdir = substr($thisCategory, 0, 3);
	}
	else
	{
	    $subdir = $thisCategory;
	}
	$subdir = lc($subdir);
	$subdir =~ s/ /_/;
	$outdir = "$CatOutBase/$subdir";
	if (! (-d $outfile))
	{
	    mkdir $outdir;
	}
	$thisCategory =~ s/ /_/g;
	$outdir = "$outdir/$thisCategory";
	if (! (-d $outfile))
	{
	    mkdir $outdir;
	}
	$outfile = "$outdir/$thisInstance.txt";
	open(OUT, ">$outfile") || die "Can't locate file $outfile: $!\n";
	print OUT $OutString;
	close OUT;
    }

    # now save out puzzle by index
    $Subdir = int($PuzzleIndex / 100);
    $fname = $PuzzleIndex % 100;
    $outfile = "$NumberOutBase/$Subdir/$fname.txt";
    if (! (-d "$NumberOutBase/$Subdir"))
    {
	mkdir "$NumberOutBase/$Subdir";
    }
    open(OUT, ">$outfile") || die "Can't locate file $outfile: $!\n";
    print OUT $OutString;
    close OUT;

    $PuzzleIndex++;
}

# term overlap functions here
sub CheckTitleOverlap {
    my $maybe = shift;

    @mwords = split(/\s+/, $maybe);
    foreach $wd (@mwords)
    {
	if (defined($AllowedRepeats{$wd}))
	{
	    next;
	}
	if (length($wd) > 5)
	{
	    $wd = substr($wd, 0, 5);
	}
	#print "Checking:$wd:\n";
	if (defined($twhash{$wd}))
	{
	    #print "Got one!\n";
	    return 0;
	}
    }

    return 1;
}

sub CheckCategoryOverlap {
    my $maybe = shift;

    @mwords = split(/\s+/, $maybe);
    foreach $wd (@mwords)
    {
	if (defined($AllowedRepeats{$wd}))
	{
	    next;
	}
	if (length($wd) > 5)
	{
	    $wd = substr($wd, 0, 5);
	}
	if (defined($cwhash{$wd}))
	{
	    return 0;
	}
    }

    return 1;
}

sub WriteClassMasterFile {

    ## slurp up name mapping file
    open(IN, "$classnamefile") || die "Can't locate file $classnamefile: $!\n";
    while ($line = <IN>)
    {
	$line =~ s/[\r\n]*//g;
	($raw, $pretty) = split(/\s/, $line);
	$PrettyClass{$raw} = $pretty;
    }
    close IN;

    ## Write out file holding samples by class:
    $ThisOutFile = "$ClassOutBase/master.txt";
    open(OUT, ">$ThisOutFile") || die "Can't locate file $ThisOutFile: $!\n";
    @sorted = sort {$PrettyClass{$a} cmp $PrettyClass{$b}} (keys %PrettyClass);
    foreach $raw (@sorted)
    {
	# put potpourri at end
	if ($raw eq "potpourri")
	{
	    next;
	}
	$Pretty = $PrettyClass{$raw};
	$Count = $ClassInstances{$raw};
	print OUT "$Count, $Pretty\n";
    }
    # potpourri last:
    $Pretty = $PrettyClass{"potpourri"};
    $Count = $ClassInstances{"potpourri"};
    print OUT "$Count, $Pretty\n";

    close OUT;
}

sub WriteNumberMasterFile {

    ## Write out file holding samples by class:
    $ThisOutFile = "$NumberOutBase/master.txt";
    open(OUT, ">$ThisOutFile") || die "Can't locate file $ThisOutFile: $!\n";
    print OUT "$PuzzleIndex\n";
    close OUT;
}

sub PatchFile {

    $ThisFile = shift;
    
    open(IN, "$ThisFile") || die "Can't locate file $ThisFile: $!\n";
    # slurp all in one line
    $OutString = <IN>;
    if ($OutString =~ m/\"cats\":\[(.*?)\]/)
    {
	$CatLine = $1;
    }
    else
    {
	die "No cat line in $ThisFile: $OutString\n";
    }
    @theCats = split(/, /, $CatLine);
    # get total line
    $totalline = "\"totals\":[";
    for ($i = 0; $i < @theCats; $i++)
    {
	$cat = $theCats[$i];
	$cat =~ s/\"//g;
	$catTotal = $Written{"category:$cat"};
	$totalline .= $catTotal;
	if ($i < (@theCats - 1))
	{
	    $totalline .= ", ";
	}
    }
    $totalline .= "], ";

    # now open for write and save out to same location
    open(OUT, ">$ThisFile") || die "Can't locate file $ThisFile: $!\n";
    #print OUT "-----------------\n";
    print OUT "{";
    $OutString =~ s/\, \"index/\, $totalline\"index/;
    print OUT $OutString;
    close OUT;
}

sub MakeLogicPuzzleKeys {

    my @words = @_;
    %cfreqs = ();
    %cwdfreqs = ();

    ## Set up map from ints to vals - now we can randomly get a character
    ## based on global freq
    @alphabet = split(//, "abcdefghijklmnopqrstuvwxyz");
    $iMapIdx = 0;
    foreach $char (@alphabet)
    {
	for ($i = 0; $i < $GlobalFreqs{$char}; $i++)
	{
	    $GlobalRandMap{$iMapIdx} = $char;
	    $iMapIdx++;
	}
    }
    $GlobalTotalFreqs = $iMapIdx;

    ## Also want rank-based availability
    @SortedGlobalChars = sort {$GlobalFreqs{$b} <=> $GlobalFreqs{$a}} (keys %GlobalFreqs);

    ### Now, actually do something with the input data!
    # first collect up char freqs:
    foreach $wd (@words)
    {
	@chars = split(//, $wd);
	foreach $char (@chars)
	{
	    if ($char eq " ")
	    {
		next;
	    }
	    $cfreqs{$char}++;
	}
    }

    ## build up ability to locally sample chars freqs as well
    ## Set up map from ints to vals - now we can randomly get a character
    ## based on global freq
    $iMapIdx = 0;
    foreach $char (@alphabet)
    {
	for ($i = 0; $i < $cfreqs{$char}; $i++)
	{
	    $LocalRandMap{$iMapIdx} = $char;
	    $iMapIdx++;
	}
    }
    $LocalTotalFreqs = $iMapIdx;
    # now get char ranks as well
    @sortfreqs = sort { $cfreqs{$b} <=> $cfreqs{$a}} (keys %cfreqs);
    $uniquechars = @sortfreqs;
    #print "uniquechars:$uniquechars:\n";

    # collect up chars in multiple words
    $NumInMult = 0;
    foreach $char (@sortfreqs)
    {
	$thiswdcount = 0;
	foreach $wd (@words)
	{
	    if ($wd =~ m/$char/)
	    {
		$thiswdcount++;
	    }
	}
	if ($thiswdcount > 1)
	{
	    $cwdfreqs{$char} = $thiswdcount;
	    #print "cwdfreq:$char:$thiswdcount:\n";
	}
    }

    @sortedbywdfreq = sort { $cwdfreqs{$b} <=> $cwdfreqs{$a}} (keys %cfreqs);
    $numbywdcount = @sortedbywdfreq;

    if ($numbywdcount == 0)
    {
	#print "No luck - maybe ought to add another clue?\n";
	#die "No luck!\n";
	return 0;
    }

    # Start with 4 difficulty levels which assign fates
    # for starters, make char choice not state-dependent. Can get
    # more complex later as needed.

    # Now support 4 fates: shown in word, colored blank, shown at left,
    # omitted entirely
    # 1. Equal version - 1/3 probability for each of the non-omitted
    # 2. Equal all - 1/4 probability for all
    # 3. Tough - 10% in word, 10% at left, 40% missing, 40% colored
    # 4. Strict alternation as in the original prototype

    ## construction scheme: only the colored blank ones are painful since
    ## they can't be chosen for all characters. Set this number based on the
    ## number of unique chars/available chars which can serve this role.
    ## Assign this fate based on the sampling n lines randomly method, then
    ## fill in the rest of the chars with the other probabilities naturally

    ## Method 1. equal version, no non-omitted
    RandomSelectShareChars(0.3333);
    # now assign remaining fates equally - 50%
    SetRandomCharFates(0.5, 0.5, 0.0, 0.1);
    ## build key
    $FateString1 = SetFateString();
    if ($FateString1 eq "")
    {
	return 0;
    }
    # clear fates
    %fate = ();   
    ## End of method 1

    # Method 2: 25% equal probability each
    RandomSelectShareChars(0.25);
    # now assign remaining fates equally - 33%
    SetRandomCharFates(0.333, 0.333, 0.333, 0.1);
    ## build key
    $FateString2 = SetFateString();
    if ($FateString2 eq "")
    {
	return 0;
    }
    # clear fates
    %fate = ();    
    ## End of method 2

    # Method 3: varying probabilities
    RandomSelectShareChars(0.4);
    # now assign remaining fates in a weighted fashion
    # residuals are 2/3 missing 1/6 each in word, at left
    SetRandomCharFates(0.166, 0.166, 0.666, 0.1);
    ## build key
    $FateString3 = SetFateString();
    if ($FateString3 eq "")
    {
	return 0;
    }
    # clear fates
    %fate = ();    
    ## End of method 3

# ## Method 4: strict alternation
# # just alternate for starters
# $next{"share"} = "inwd";
# $next{"inwd"} = "side";
# $next{"side"} = "share";
# $state = "inwd";
# $coloridx = 0;
# foreach $char (@sortfreqs)
# {
#     if (($state eq "share") && (!defined($cwdfreqs{$char})))
#     {
# 	$thisuse = "inwd";
#     }
#     else
#     {
# 	$thisuse = $state;
#     }

#     #print "setting fate:$char:$thisuse:\n";
#     $fate{$char} = $thisuse;
#     if ($thisuse eq "share")
#     {
# 	$colorfate{$char} = $colorlist[$coloridx];
# 	$coloridx++;
#     }
#     $state = $next{$state};
# }
# ## print table part before reset
# #PrintPuzzleTable();
# # clear fates
# %fate = ();    
# ## End of method 4

    return 1; # just flag success - strings are in globals
}

# assumes all the globals are nicey nicey
sub RandomSelectShareChars {
    my $rate = shift;
    
    $TargetShare = int($rate * $uniquechars);
    # keep among the possible
    if ($TargetShare > $numbywdcount)
    {
	$TargetShare = $numbywdcount;
    }
    #print "uniquechars:$uniquechars, targetshare:$TargetShare\n";
    # limit to 9 at most for now - can add more colors later
    if ($TargetShare > 9)
    {
	$TargetShare = 9;
    }
    $TotalEncountered = 0;
    $SampleIdx = 0;
    %TheseSamples = ();
    foreach $char (keys %cwdfreqs)
    {
	#print STDERR "considering $char\n";
	$TotalEncountered++;
	if ($SampleIdx < $TargetShare)
	{
	    $TheseSamples{$SampleIdx} = $char;
	    $SampleIdx++;
	}
	else
	{
	    # Here's the idea: 
	    # Generate a random number from 1..total encountered
	    # If it's one of the first curr samples, it belongs in */
	    $idx = int(rand $TotalEncountered);
	    if ($idx < $TargetShare)
	    {
		$TheseSamples{$idx} = $char;
	    }
	}
    }
    RandomSortColors();
    $coloridx = 0;
    foreach $idx (keys %TheseSamples)
    {
	$thischar = $TheseSamples{$idx};
	#print STDERR "fate of $thischar is share\n";
	$fate{$thischar} = "share";
	$colorfate{$thischar} = $colorlist[$coloridx];
	$coloridx++;
    }
}

# sets random fates for non-set char fates, based on passed-in
# probabilities. Use probabilities to figure number of representatives,
# then assigns fates to avoid supposedly rare cases of extreme outcomes
# actually, add in a small amount of variational probability to each class
# to let things shift just a bit
sub SetRandomCharFates {
    my $InwdRate = shift;
    my $SideRate = shift;
    my $SkipRate = shift;
    my $Variation = shift;
    #print STDERR "Args: $InwdRate $SideRate $SkipRate $Variation\n";
    # jigger things up a bit plus or minus
    if ($InwdRate > 0)
    {
	$InwdRate += (rand $Variation) - $Variation / 2.0;
    }
    if ($SideRate > 0)
    {
	$SideRate += (rand $Variation) - $Variation / 2.0;
    }
    if ($SkipRate > 0)
    {
	$SkipRate += (rand $Variation) - $Variation / 2.0;
    }
    #print STDERR "Using probs: $InwdRate $SideRate $SkipRate\n";

    $ProbSum = $InwdRate + $SideRate + $SkipRate;
    # count remaining chars
    $StillNeed = 0;
    %TheseProbVals = ();
    foreach $char (@sortfreqs)
    {
	if ($fate{$char} eq "share")
	{
	    #print STDERR "fate of $char is share\n";
	    next;
	}
	#print STDERR "Adding $char\n";
	$TheseProbVals{$char} = rand 1.0;
	$StillNeed++;
    }
    $NumInwd = int($StillNeed * ($InwdRate / ($ProbSum + 0.0)));
    $NumSide = int($StillNeed * ($SideRate / ($ProbSum + 0.0)));
    $NumSkip = int($StillNeed * ($SkipRate / ($ProbSum + 0.0)));
    $sf = @sortfreqs;
    #print STDERR "StillNeed $StillNeed Total $sf\n";
    #print STDERR "Num: $NumInwd $NumSide $NumSkip\n";
    
    @TheseProbValsSorted = sort {$TheseProbVals{$a} <=> $TheseProbVals{$b}} 
    (keys %TheseProbVals);
    $HaveInwd = 0;
    $HaveSide = 0;
    $HaveSkip = 0;
    foreach $char (@TheseProbValsSorted)
    {
	#print STDERR "Consider $char\n";
	if ($HaveInwd < $NumInwd)
	{
	    $fate{$char} = "inwd";
	    #print STDERR "fate of $char is inwd\n";
	    $HaveInwd++;
	}
	else
	{
	    if ($HaveSide < $NumSide)
	    {
		$fate{$char} = "side";
		#print STDERR "fate of $char is side\n";
		$HaveSide++;
	    }
	    else
	    {
		if ($HaveSkip < $NumSkip)
		{
		    $fate{$char} = "skip";
		    #print STDERR "fate of $char is skip\n";
		    $HaveSkip++;
		}
		else
		{
		    # if have to force, pick between side/inwd
		    if ($InwdRate > $SideRate)
		    {
			$fate{$char} = "inwd";
			#print STDERR "fate of $char is inwd\n";
			$HaveInwd++;
		    }
		    else
		    {
			$fate{$char} = "side";
			#print STDERR "fate of $char is side\n";
			$HaveSide++;
		    }
		}
	    }
	}
    }
}

sub SetFateString {

    my $fs = "";
    foreach $char (@alphabet)
    {
	if (!defined($fate{$char}))
	{
	    $fs .= "m";
	    next;
	}
	if ($fate{$char} eq "side")
	{
	    $fs .= "s";
	    next;
	}
	if ($fate{$char} eq "skip")
	{
	    $fs .= "o";
	    next;
	}
	if ($fate{$char} eq "inwd")
	{
	    $fs .= "i";
	    next;
	}
	if ($fate{$char} eq "share")
	{
	    if (!defined($UseColorIdx{$colorfate{$char}}))
	    {
		return ""; # failure
	    }
	    $value = $UseColorIdx{$colorfate{$char}};
	    #print "colorfate of $char is $colorfate{$char}\n";
	    $fs .= "$value";
	    next;
	}	
	return ""; # failure
    }
    return $fs;
}

sub RandomSortColors {

    foreach $color (@colorlist)
    {
	$randval = rand 1.0;
	$ColorSort{$color} = $randval;
    }
    @colorlist = sort {$ColorSort{$a} <=> $ColorSort{$b}} (@colorlist);
}


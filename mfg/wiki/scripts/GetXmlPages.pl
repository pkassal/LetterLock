#!C:/Perl/bin/perl

## perl script to:
## - pore over ranked list of chosen page info
## - call wikipedia export method in batches

$infile = "/cygdrive/c/finance/wiqui/datasets/xml1/wikixmlpicks.sort";
$outbase = "/cygdrive/c/finance/wiqui/datasets/xml1/set";
$setsize = 50;
$totalsets = 100;
#$totalsets = 1;

$setidx = 0;
$numinset = 0;
$namestring = "pages=";
open(IN, "$infile") || die "Can't locate file $infile: $!\n";
while ($line = <IN>)
{
    $line =~ s/[\r\n]+//;
    @fields = split(/\t/, $line);
    $name = $fields[2];
    $name =~ s|/wiki/||;
    if ($numinset > 0)
    {
	$namestring .= "%0A";
    }
    $numinset++;
    $namestring .= $name;
    if ($numinset == $setsize)
    {
	$outfile = "$outbase$setidx.xml";
	print "$namestring\n";
	$command = "curl -d \"$namestring\" \"http://en.wikipedia.org/wiki/Special:Export/w/index.php?title=Special:Export&action=submit\" > $outfile";
	system($command);
	$numinset = 0;
	$setidx++;
	$namestring = "pages=";
	if ($setidx == $totalsets)
	{
	    last;
	}
    }
}
close IN;

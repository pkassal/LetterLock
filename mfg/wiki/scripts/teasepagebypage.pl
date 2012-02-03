#!C:/Perl/bin/perl

## perl script to:
## - pore over results from teasepopularpages.pl 
## - call curl repeatedly to get individual popular pages
## - for each result on each page, save out info for XML getting plus
##   assorted related info

$infile = "/cygdrive/c/finance/wiqui/datasets/xml1/wikiwant.txt";
$outfile = "/cygdrive/c/finance/wiqui/datasets/xml1/wikixmlraw.txt";
$wikibase = "http://en.wikipedia.org";

open(IN, "$infile") || die "Can't locate file $infile: $!\n";
open(OUT, ">$outfile") || die "Can't locate file $outfile: $!\n";
while ($line = <IN>)
{
    $line =~ s/[\r\n]*//;
    if ($line =~ m|href=\"(.*?)\"|)
    {
	$relativepath = $1;
    }
    else
    {
	die "no href for $line\n";
    }
    $command = "curl -s \"$wikibase$relativepath\"";
    print "$command\n";
    $page = `$command`;
    if ($page =~ m|<th>Rank</th>(.*?)</table>|gs)
    {
	$theTable = $1;
	while ($theTable =~ m|<tr>(.*?)</tr>(.*)|s)
	{
	    $thisRow = $1;
	    $theTable = $2;

	    if ($thisRow =~ m|<td>([0-9]+).*href=\"(.*?)\".*?<td>([0-9]+).*?<td>([0-9]+).*/wiki/Category:(.*?)\"|s)
	    {
		print OUT "$relativepath\t$1\t$2\t$3\t$4\t$5\n";
# 		print "rank:$1\n";
# 		print "link:$2\n";
# 		print "views:$3\n";
# 		print "aveviews:$4\n";
# 		print "type:$5\n";
	    }
	    
	}
    }
    
}
close OUT;
close IN;

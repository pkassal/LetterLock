#!C:/Perl/bin/perl

## perl script to:
## - pore over html for wiki popular pages web page 
##   (http://en.wikipedia.org/wiki/Wikipedia:Lists_of_popular_pages_by_WikiProject)
## - tease out page names to get

$infile = "/cygdrive/c/finance/wiqui/datasets/xml1/wikistart.htm";
$outfile = "/cygdrive/c/finance/wiqui/datasets/xml1/wikiwant.txt";

open(IN, "$infile") || die "Can't locate file $infile: $!\n";
$file = do {local $/, <IN>};
close IN;

open(OUT, ">$outfile") || die "Can't locate file $outfile: $!\n";
while ($file =~ m|<tr>\s*<td>(<a href=.*?</a>)|gs)
{
    print OUT "$1\n";
}
close OUT;

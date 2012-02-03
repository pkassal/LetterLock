#!C:/Perl/bin/perl

## perl script to:
## - pore over output from teasepagebypage.pl
## - thin it out based this that and the other

$infile = "/cygdrive/c/finance/wiqui/datasets/xml1/wikixmlraw.txt";
$outfile = "/cygdrive/c/finance/wiqui/datasets/xml1/wikixmlpicks.txt";

# skip certain article types - look at atypes.txt for freqs
$BadArticleType{"Low-importance_articles"} = 1;
$BadArticleType{"Bottom-importance_articles"} = 1;

open(IN, "$infile") || die "Can't locate file $infile: $!\n";
open(OUT, ">$outfile") || die "Can't locate file $outfile: $!\n";
while ($line = <IN>)
{
    $line =~ s/[\r\n]+//;
    @fields = split(/\t/, $line);
    # nothing past rank 500
    if ($fields[1] >= 500)
    {
	next;
    }
    # no dups
    if (defined($Have{$fields[2]}))
    {
	next;
    }
    # overall mass
    if ($fields[3] < 1000)
    {
	next;
    }
    # dispreferred article types
    if (defined($BadArticleType{$fields[5]}))
    {
	next;
    }
    # non-alpha chars in title:
    if ($fields[2] !~ m/^[A-Za-z_\/]+$/)
    {
	#print "skipping $line\n";
	next;
    }
    # certain dispreferred article types
    print OUT "$line\n";
    $Have{$fields[2]} = 1;
}
close IN;
close OUT;

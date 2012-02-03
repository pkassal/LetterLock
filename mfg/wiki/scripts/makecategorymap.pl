#!C:/Perl/bin/perl

## perl script to:
## - slurp up catwords.map info
## - pore over stats1.cats
## - make mapping of every cat to either a fake category name or potpourri

$wordmap = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/stats/catwords.map";
$cats = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/stats/stats1.cats";
$outfile = "/cygdrive/c/finance/wiqui/datasets/raw1/en.wikipedia.org/stats/catmap.txt";

open(IN, "$wordmap") || die "Can't locate file $wordmap: $!\n";
while ($line = <IN>)
{
    $line =~ s/[\r\n]*//g;
    if ($line =~ m/^\s/)
    {
	next;
    }
    @fields = split(/\s+/, $line);
    $fake = $fields[0];
    $raw = $fields[2];
    $WordMap{$raw} = $fake;
}
close IN;

open(IN, "$cats") || die "Can't locate file $cats: $!\n";
open(OUT, ">$outfile") || die "Can't locate file $outfile: $!\n";
while ($line = <IN>)
{
    $line =~ s/[\r\n]*//g;
    ($count, $rest) = split(/\t/, $line, 2);
    $rest =~ s/category://;
    @words = split(/\s+/, $rest);
    %thesecats = ();
    foreach $word (@words)
    {
	if (defined($WordMap{$word}))
	{
	    $thesecats{$WordMap{$word}} = 1;
	}
    }
    # force delete for bad words - even if other types encountered
    if (defined($thesecats{"delete"}))
    {
	print OUT "$count\tdelete\tcategory:$rest\n";
	next;
    }
    if ((keys %thesecats) != 1)
    {
	print OUT "$count\tpotpourri\tcategory:$rest\n";
	next;
    }
    foreach $term (keys %thesecats)
    {
	$usemap = $term;
    }
    print OUT "$count\t$usemap\tcategory:$rest\n";
}
close IN;
close OUT;



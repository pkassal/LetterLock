#!C:/Perl/bin/perl

## perl script to:
## - march over all sets from xml1 save
## - convert to nicerout format

$inbase = "/cygdrive/c/finance/wiqui/datasets/xml1/set";
$outbase = "/cygdrive/y/finance/wiqui/datasets/xml1/nicerout";
$numsets = 100;

for ($set = 0; $set < $numsets; $set++)
{
    print "processing set $set\n";
    $command = "perl teasefromxml1.pl $inbase$set.xml.gz $outbase";
    system($command) == 0 || die "failed on $command\n";
}

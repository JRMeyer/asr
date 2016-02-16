#!/usr/bin/env perl
#
# This script needs a completely cleaned corpus, ie no puncutation, no numbers
# it tokenizes the corpus and returns a file of word:pronunciation pairs
#

use warnings;
use strict;

my $infile = $ARGV[0];
my $outfile = $ARGV[1];

open INFILE, $infile, or die "Could not open $infile: $!";
open OUTFILE, ">>", $outfile, or die "Could not open $outfile: $!";

# the default lookup table - if our context dependent rules don't make a
# character, it gets replaced according to the table
my %phoneTable = ("а"=>"a ", # back vowels
                  "о"=>"o ",
                  "у"=>"u ",
                  "ы"=>"ih ",
                  "и"=>"i ", # front vowels
                  "е"=>"e ",
                  "э"=>"e ",
                  "ө"=>"oe ",
                  "ү"=>"y ",
                  "ю"=>"j u ", # glide vowels
                  "я"=>"j a ",
                  "ё"=>"j o ",
                  "п"=>"p ", # bilabials
                  "б"=>"b ",
                  "д"=>"d ", # coronals
                  "т"=>"t ",
                  "к"=>"k ", # velars
                  "г"=>"g ",
                  "х"=>"h ",
                  "ш"=>"sh ", # (alveo)(palatals)
                  "щ"=>"sh ",
                  "ж"=>"zh ",
                  "з"=>"z ", 
                  "с"=>"s ",
                  "ц"=>"ts ", # affricates
                  "ч"=>"ch ",
                  "й"=>"j ", # glides
                  "л"=>"l ",
                  "м"=>"m ", # nasals
                  "н"=>"n ",
                  "ң"=>"ng ",
                  "ф"=>"f ", # labiodentals
                  "в"=>"v ",
                  "р"=>"r ", # trill
                  "ъ"=>"",
                  "ь"=>"");

# Idk why, but the [abc] notation doesnt work here
my $consonant = "п|б|д|т|к|г|х|ш|щ|ж|з|с|ц|ч|й|л|м|н|ң|ф|в|р|ъ|ь";
my $frontVowel = "и|е|э|ө|ү";
my $backVowel = "а|о|у|ы";

# make a hash dictionary of token:pronunciation pairs
my %hash;
while (my $line = <INFILE>) {
    chomp $line;
    my @tokens = split / /, $line;
    while (my $token = <@tokens>) {
        if (exists $hash{$token}) {
            # we've seen this token already
            # so we just pass it
            last;
        } else {
            my $phones = $token;
            for($phones) {
                # syllable onset plosives followed by front/back vowels
                s/к($backVowel)/kh $1/g;
                s/к($frontVowel)/k $1/g;
                s/г($backVowel)/gh $1/g;
                s/г($frontVowel)/g $1/g;
                # syllable final plosives preceded by front/back vowels
                s/($backVowel)к($consonant)/$1kh $2/g;
                s/($frontVowel)к($consonant)/$1k $2/g;
                s/($backVowel)г($consonant)/$1gh $2/g;
                s/($frontVowel)г($consonant)/$1g $2/g;
                # word final plosives preceded by front/back vowels
                s/($backVowel)к$/$1kh/g;
                s/($frontVowel)к$/$1k/g;
                s/($backVowel)г$/$1gh/g;
                s/($frontVowel)г$/$1g/g;
            }
            $phones =~ s/(@{[join "|", keys %phoneTable]})/$phoneTable{$1}/g;
            $phones =~ s/^\s+//g;
            $phones =~ s/\s+$//g;
            $hash{$token} = $phones;
        }
    }
}

# print token:pronunciation pairs to text file
foreach my $key (keys %hash) {
    if ($key eq "<s>" || $key eq "</s>") {
        last;
    }
    else {
        print OUTFILE "$key $hash{$key}\n"
    }
}




#!/usr/bin/env perl
#
# Author: Josh Meyer 2016
#
# INPUT: (1) a cleaned text corpus
#
# OUTPUT: (1) a file of word:pronunciation pairs (a phonetic dict)
#         (2) a list of the phones used in the lookuptable
#
# FUNCTION:
#   The script tokenizes a corpus and returns a file of word:pronunciation pairs
#
#   This script requires a completely cleaned corpus, i.e. the text must have
#   *no* puncutation and *no* numbers.
#
#   HOWEVER, it won't break if you give it utterancess with <s>'s.
#

use warnings;
use strict;
use Getopt::Long;

# DEFAULT VALUES
my $clean_corpus = "clean.txt";
my $phoneticDict = "lexicon.txt";
my $phonesList = "phones.txt";
my $silence_word = "[silence]";
my $silence_phone = ".";
my $unknown_word = "<unk>";
my $unknown_phone = "@";
my $graphemes = 0;

# get args from command line if they exist
GetOptions (
    'clean_corpus=s' => \$clean_corpus,
    'phoneticDict=s' => \$phoneticDict,
    'phonesList=s' => \$phonesList,
    'silence_word=s' => \$silence_word,
    'silence_phone=s' => \$silence_phone,
    'unknown_word=s' => \$unknown_word,
    'unknown_phone=s' => \$unknown_phone,
    'graphemes' => \$graphemes,
    );

# open or create files
open CLEAN_CORPUS, $clean_corpus, or die "Could not open $clean_corpus: $!";
open PHONETICDICT, ">>", $phoneticDict, or die "Could not open $phoneticDict: $!";
open PHONELIST, ">>", $phonesList, or die "Could not open $phonesList: $!";

# the default lookup table - if our context dependent rules don't make a
# character or we're in 'grapheme-mode', letters gets replaced according to 
# the following table
my %phoneTable = ("а"=>"a", # back vowels
                  "о"=>"o",
                  "у"=>"u",
                  "ы"=>"I",
                  "и"=>"i", # front vowels
                  "е"=>"e",
                  "э"=>"e",
                  "ө"=>"O",
                  "ү"=>"y",
                  "ю"=>"ju", # glide vowels
                  "я"=>"ja",
                  "ё"=>"jo",
                  "п"=>"p", # bilabials
                  "б"=>"b",
                  "д"=>"d", # coronals
                  "т"=>"t",
                  "к"=>"k", # velars
                  "г"=>"g",
                  "х"=>"h",
                  "ш"=>"S", # (alveo)(palatals)
                  "щ"=>"S",
                  "ж"=>"Z",
                  "з"=>"z", 
                  "с"=>"s",
                  "ц"=>"c", # affricates
                  "ч"=>"C",
                  "й"=>"j", # glides
                  "л"=>"l",
                  "м"=>"m", # nasals
                  "н"=>"n",
                  "ң"=>"N",
                  "ф"=>"f", # labiodentals
                  "в"=>"v",
                  "р"=>"r", # trill
                  "ъ"=>"",
                  "ь"=>"");

# Idk why, but the [abc] notation doesnt work here
my $consonant = "п|б|д|т|к|г|х|ш|щ|ж|з|с|ц|ч|й|л|м|н|ң|ф|в|р|ъ|ь";
my $frontVowel = "и|е|э|ө|ү";
my $backVowel = "а|о|у|ы";

###
## MAKE pronunciations and store in dict
#

# make a hash dictionary of token:pronunciation pairs
my %hash;

# add our entries for unknown words and silence to the dictionary
$hash{$silence_word} = $silence_phone;
$hash{"<s>"} = $silence_phone;
$hash{"</s>"} = $silence_phone;
$hash{$unknown_word} = $unknown_phone;


while (my $line = <CLEAN_CORPUS>) {
    my @tokens = split(' ', $line);
    foreach my $token (@tokens) {
        if (exists $hash{$token}) {
            # we've seen this token already
            # so we just pass it
            next;
        } else {
            my $phones = $token;
            if (!$graphemes) {
                for($phones) {
                    # syllable onset plosives followed by front/back vowels
                    s/к($backVowel)/K$1/g;
                    s/к($frontVowel)/k$1/g;
                    s/г($backVowel)/G$1/g;
                    s/г($frontVowel)/g$1/g;
                    # syllable final plosives preceded by front/back vowels
                    s/($backVowel)к($consonant)/$1K$2/g;
                    s/($frontVowel)к($consonant)/$1k$2/g;
                    s/($backVowel)г($consonant)/$1G$2/g;
                    s/($frontVowel)г($consonant)/$1g$2/g;
                    # word final plosives preceded by front/back vowels
                    s/($backVowel)к$/$1K/g;
                    s/($frontVowel)к$/$1k/g;
                    s/($backVowel)г$/$1G/g;
                    s/($frontVowel)г$/$1g/g;
                }
            }
            $phones =~ s/(@{[join "|", keys %phoneTable]})/$phoneTable{$1}/g;
            $phones =~ s/^\s+//g;
            $phones =~ s/\s+$//g;
            $hash{$token} = $phones;
        }
    }
}

###
##  PRINT word:pronunciation pairs to text file
##    lexicon.txt 

# collect all phones from all words into one char string
my $allPhones = "";

foreach my $key (keys %hash) {
    $allPhones .= "$hash{$key}";
    print PHONETICDICT "$key $hash{$key}\n";
}




###
## PRINT UNIQUE PHONES TO FILE
#

# clean up phones
for ($allPhones) {
    # remove trailing whitespace
    s/^\s+//;
    s/\s+$//;
    # remove any newlines anywhere
    s/\n+/ /g;
    # remove all spaces
    s/ //g;
}

my %seen = ();
foreach my $item (split //, $allPhones) {
    if ($seen{$item}) {
        next;
    } else {
        $seen{$item} = 1;
        print PHONELIST "$item\n";
    }
}



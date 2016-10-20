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
my $phoneticDict_NOSIL = "lexicon_nosil.txt";
my $phonesList = "phones.txt";
my $silence_word = "<SIL>";
my $silence_phone = "SIL";
my $unknown_word = "<unk>";
my $unknown_phone = "SPOKEN_NOISE";
my $graphemes = 0;
my $stress = 0;

# get args from command line if they exist
GetOptions (
    'clean_corpus=s' => \$clean_corpus,
    'phoneticDict=s' => \$phoneticDict,
    'phoneticDict_NOSIL=s' => \$phoneticDict_NOSIL,
    'phonesList=s' => \$phonesList,
    'silence_word=s' => \$silence_word,
    'silence_phone=s' => \$silence_phone,
    'unknown_word=s' => \$unknown_word,
    'unknown_phone=s' => \$unknown_phone,
    'graphemes' => \$graphemes,
    'stress' => \$stress
    );

# open or create files
open CLEAN_CORPUS, $clean_corpus, or die "Could not open $clean_corpus: $!";
open PHONETICDICT, ">>", $phoneticDict, or die "Could not open $phoneticDict: $!";
open PHONETICDICT_NOSIL, ">>", $phoneticDict_NOSIL, or die "Could not open $phoneticDict_NOSIL: $!";
open PHONELIST, ">>", $phonesList, or die "Could not open $phonesList: $!";


# Idk why, but the [abc] notation doesnt work here
my $consonant = "п|б|д|т|к|г|х|ш|щ|ж|з|с|ц|ч|й|л|м|н|ң|ф|в|р|ъ|ь";
my $vowel = "и|е|э|ө|ү|а|о|у|ы";

###
## MAKE pronunciations and store in dict
#

while (my $line = <CLEAN_CORPUS>) {
    my @tokens = split(' ', $line);
    foreach my $token (@tokens) {
        my $letters = $token;
        if (!$graphemes) {
            for($letters) {
                # beginning of word is beginning of syllable
                s/^/^\@/g;

		# kyrgyz has max onset, so any consonant followed by a vowel
		# is automatically the onset
                s/($consonant)($vowel)/\@$1$2/g;

                # syllable final plosives preceded by vowels
                s/($vowel)($consonant)($consonant)/$1$2$3\@/g;

                # end of word is end of syllable
                s/$/$\@/g;
                }
            }
            print $letters;
        }
    }
}

###
##  PRINT word:pronunciation pairs to text files
##    lexicon.txt and nosil_lexicon.txt
#      and also save phones to char string

# get phones from lookup table
my $phones = "";

foreach my $key (keys %hash) {
    if ($key eq "<s>" || $key eq "</s>") {
        next;
    } else {
        print PHONETICDICT "$key $hash{$key}\n";
        $phones .= " $hash{$key} ";
        if ($key ne $silence_word && $key ne $unknown_word) {
            print PHONETICDICT_NOSIL "$key $hash{$key}\n";
        }
    }
}




###
## PRINT UNIQUE PHONES TO FILE
#

# clean up phones
for ($phones) {
    # remove trailing whitespace
    s/^\s+//;
    s/\s+$//;
    # remove any newlines anywhere
    s/\n+/ /g;
    # replace multiple spaces with just one
    s/ +/ /g;
}

my @phones = split / /, $phones;
my %seen = ();
foreach my $item (@phones) {
    if ($seen{$item}) {
        next;
    } else {
        $seen{$item} = 1;
        print PHONELIST "$item\n"
    }
}



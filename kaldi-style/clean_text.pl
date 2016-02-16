#!/usr/bin/env perl

# USE: ./clean_text.pl /path/to/corpus.txt

# FUNCTION:
#   Given a path to a text file, this script will:
#    (1) split file into lines where sentences should be (see regex object)
#    (2) tokenize each line (see function tokenize_line()
#    (3) print new, cleaned lines to output file

# OUTPUT: output.txt (text file with one sentence per line, no non-alphabetic
#                     characters, all lowercase words, only Kyrgyz characters)
#
# The script reads utterances/lines one by one and (1) will ignore them if they
# have singleton a mjakij znak or tvjordyj znak, then (2) delete <s> and </s>
# and then (3) if the remaining sentence has more than 3 words, print it to an
# output file

use warnings;
use strict;
use utf8;
use Encode;
use open ':std', ':encoding(UTF-8)';
binmode STDOUT, ":utf8";

my $infile = $ARGV[0];
my $outfile = $ARGV[1];

my $minSentenceLen = 0;

# open(OUTPUT,">>",$outfile), or die "Error: no file found.";

my @kyrgyzLetters = ('а','о','у','ы','и','е','э',
                     'ө','ү','ю','я','ё','п','б',
                     'д','т','к','г','х','ш','щ',
                     'ж','з','с','ц','ч','й','л',
                     'м','н','ң','ф','в','р','ъ',
                     'ь');

my $regex = join('|',@kyrgyzLetters);

# some singleton ъ's and ь's I'm seeing in the corpus. There are other
# singleton letters I see as well, but these jam up my pipeline because
# I am not giving them pronunciations in the lexicon
my $danglers = qr/ (ъ|ь) /;

# Read entire file into string:
local $/;
open(INPUT,$infile), or die "Error: no file found.";

my $fileContents = <INPUT>;
close INPUT;

for my $sentence (split /[.!?\n]+/, $fileContents) {
    $sentence = lc($sentence);
    $sentence =~ s/[\P{L}\d_]+/ /g;
    $sentence =~ s/[^($regex)]/ /g;

    if ($sentence =~ $danglers) {
        print "'$sentence' matches the pattern\n";
    } else {
        chomp $sentence;
        for($sentence) {
            s/<s>//g;
            s/<\/s>//g;
        }
        my @tokens = split / /, $sentence;
        my $numTokens = @tokens;
        if ($numTokens > $minSentenceLen) {
            my $goodLine = join(' ', @tokens);
            print "$goodLine\n";
        }
    }
}

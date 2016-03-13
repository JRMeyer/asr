#!/usr/bin/env perl

# USE: ./clean_text.pl /path/to/corpus.txt

# INPUT: (1) path to a messy corpus text file
#        (2) interger, minimum length of sentence
#        (3) Boolean True or False, add silence <s>

# OUTPUT: one clean sentence per line, no non-alphabetic
#         characters, all lowercase words, only Kyrgyz characters
#         must pipe it to a txt file

# FUNCTION:
#
#  Given a path to a text file, this script will:
#
#  Read utterances/lines one by one and clean the line
#  If the remaining sentence has more than N words, print it to an output file


use warnings;
use strict;
use utf8;
use Encode;
use open ':std', ':encoding(UTF-8)';
binmode STDOUT, ":utf8";

# perl trim function - remove leading and trailing whitespace
sub trim($)
{
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

# Get command line arguments
my $infile = $ARGV[0];
my $minSentenceLength = $ARGV[1];
my $addSilence = $ARGV[2];


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
my $danglers = qr/ (ъ|ь)+ /;

# Read entire file into string:
local $/;
open(INPUT,$infile), or die "Error: no file found.";

my $fileContents = <INPUT>;
close INPUT;

# split messy corpus on what we think delimit utterances
for my $sentence (split /[.!?\n]+/, $fileContents) {
    # make sentence lowercase
    $sentence = lc($sentence);
    # throw out all non alphabetic characters
    $sentence =~ s/[\P{L}\d_]+/ /g;
    # throw out all non-Kyrgyz letters
    $sentence =~ s/[^($regex)]/ /g;

    if ($sentence =~ $danglers) {
        next;
    } else {
        chomp $sentence;
        my @tokens = split / /, $sentence;
        my $numTokens = @tokens;
        if ($numTokens > $minSentenceLength) {
            my $goodLine = join(' ', @tokens);
            $goodLine = trim($goodLine);
            if ($addSilence){
                print "<s> $goodLine </s>\n";
            } else {
                print "$goodLine\n";
            }
        }
    }
}

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

# define trim function - remove leading and trailing whitespace
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



# Read entire file into string:
local $/;
open(INPUT,$infile), or die "Error: no file found.";

my $fileContents = <INPUT>;
close INPUT;

# split messy corpus on what we think delimit utterances
for my $sentence (split /[.!?\n]+/, $fileContents) {
    
    chomp $sentence;
    my @tokens = split / /, $sentence;

    # remove first token, because it's just a fileID for me now
    splice @tokens, 0, 1;
        
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

# !bin/bash

# USAGE : reformat_transcript_as_stm.sh transcripts.txt audio_dir

# INPUT: 
#     transcripts.txt: 2-column file such as <filename> <transcript>
#     audio_dir: a dir of audio files

# OUTPUT:
#     new-transcripts.stm
# 
#    formatted as such:
#    <filename> <channel> <speakerid> <begintime> <endtime> [<label>] transcript

in_transcripts=$1
audio_dir=$2
ext=".wav"

# make newlines the only separator
IFS=$'\n'

for line in `cat $in_transcripts`
do
    IFS=' ' read f transcription <<< "$line"
    echo $f "1" $f "0" `soxi -D ${audio_dir}${f}${ext}` "<,>" $transcription \
        >> new-transcripts.stm
done


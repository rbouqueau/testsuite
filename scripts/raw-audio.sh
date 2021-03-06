#test raw video

raw_audio_test ()
{

test_begin "raw-aud-$1"
if [ $test_skip  = 1 ] ; then
return
fi

rawfile=$TEMP_DIR/raw.$1
#test dumping to the given format
do_test "$GPAC -i $mp4file -o $rawfile" "dump-$1"

#on linux 32 bit we for now disable the hashes, they all differ due to different float/double precision
if [ $GPAC_OSTYPE != "lin32" ] ; then
do_hash_test_bin "$rawfile" "dump-$1"
fi

myinspect="inspect:fmt=@pn@-@cts@-@bo@@lf@"
insfile=$TEMP_DIR/dump.txt
do_test "$GPAC -i $rawfile:sr=48000:ch=2 $myinspect:log=$insfile" "inspect"
do_hash_test "$insfile" "inspect"

#test reading from the given format into pcm
rawfile2=$TEMP_DIR/raw2.pcm
do_test "$GPAC -i $rawfile -o $rawfile2" "dump-pcm"
if [ $GPAC_OSTYPE != "lin32" ] ; then
do_hash_test_bin "$rawfile2" "dump-pcm"
fi

#only do the reverse tests for pcm (same for the other formats)
if [ $1  = "pcm" ] ; then

#playback test at 10x speed - this exercices audio output
do_test "$GPAC -i $rawfile:sr=48000:ch=2 aout:speed=10:vol=0 -graph" "play"

myinspect="inspect:speed=-1:fmt=@pn@-@cts@-@bo@@lf@"
insfile=$TEMP_DIR/dumpns.txt
do_test "$GPAC -i $rawfile:sr=48000:ch=2 $myinspect:log=$insfile" "inspect_reverseplay"
do_hash_test "$insfile" "inspect_reverseplay"


#playback test at -10x speed - this exercices audio output
do_test "$GPAC -i $rawfile:sr=48000:ch=2 aout:speed=-10:vol=0" "reverse_play"

fi

case $1 in
"pcm" | "s24" | "s32" | "flt" |"dbl" )
#test isobmff pcm encapsulation
do_test "$GPAC -i $rawfile:sr=48000:ch=2 -o $TEMP_DIR/pcm.mp4:ase=v1" "isobmff-write"
if [ $GPAC_OSTYPE != "lin32" ] ; then
do_hash_test "$TEMP_DIR/pcm.mp4" "isobmff-write"
fi
insfile=$TEMP_DIR/dump_isopcm.txt
#disable crc test for lin32, only check isom structure
do_test "$GPAC -i $TEMP_DIR/pcm.mp4 inspect:deep:log=$insfile:test=nocrc" "isobmff-read"
do_hash_test "$insfile" "isobmff-read"
;;
esac



test_end
}

#we do a test with 0.4 seconds. using more results in higher dynamics in the signal which are not rounded the same way on all platforms
mp4file="$TEMP_DIR/aud.mp4"
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=0.4 -new $mp4file 2> /dev/null

#complete lists of audio formats extensions in gpac
afstr="pc8 pcm s24 s32 flt dbl pc8p pcmp s24p s32p fltp dblp"

for i in $afstr ; do
	raw_audio_test $i
done


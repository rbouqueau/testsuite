
svg_test()
{

 name=$(basename $1)
 name=${name%.*}

 #start our test, specifying all hash names we will check
 test_begin "svg-$name"
 if [ $test_skip  = 1 ] ; then
  return
 fi

 RGB_DUMP="$TEMP_DIR/$2-dump.rgb"
 PCM_DUMP="$TEMP_DIR/$2-dump.pcm"

 #for the time being we don't check hashes nor use same size/dur for our tests. We will redo the UI tests once finaizing filters branch
 dump_dur=5
 dump_size=192x192
 do_test "$GPAC -cfg=Validator:Mode=Play -cfg=Validator:Trace=$RULES_DIR/svg-tests-ui.xml -blacklist=vtbdec,nvdec -i $1 compositor:nojs:osize=$dump_size:vfr:dur=$dump_dur:asr=44100:ach=2$compopt @ -o $RGB_DUMP @1 -o $PCM_DUMP" "dump"

 v_args=""
 if [ -f $RGB_DUMP ] ; then
  do_hash_test_bin "$RGB_DUMP" "dump"
  v_args="$RGB_DUMP:size=$dump_size"
 else
  result="no output"
 fi

 a_args=""
 if [ -f $PCM_DUMP ] ; then
#  do_hash_test_bin "$PCM_DUMP" "$2-pcm"
  a_args="$PCM_DUMP:sr=44100:ch=2"
 fi

 do_play_test "$2-play" "$v_args" "$a_args"

test_end

}


#test all bifs
for i in $MEDIA_DIR/svg/*.svg ; do
svg_test $i
done



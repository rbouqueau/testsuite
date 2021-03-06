
test_inspect()
{
 name=$(basename $1)
 name=${name%.*}
 test_begin "inspect-$name"

if [ "$test_skip" = 1 ] ; then
 return
fi

inspect="$TEMP_DIR/inspect.xml"

do_test "$GPAC -i $1 inspect:deep:log=$inspect:analyze=on$2" "inspect"
do_hash_test $inspect "inspect"

if [ "$3" == "1" ] ; then

inspect="$TEMP_DIR/inspect_bs.xml"
do_test "$GPAC -i $1 inspect:deep:log=$inspect:analyze=full$2" "inspect-bs"
do_hash_test $inspect "inspect-bs"

fi

test_end

}

test_inspect $MEDIA_DIR/auxiliary_files/count_video.cmp "" "0"
test_inspect $MEDIA_DIR/auxiliary_files/count_english.mp3 "" "0"
test_inspect $MEDIA_DIR/auxiliary_files/enst_video.h264 "" "1"
test_inspect $MEDIA_DIR/auxiliary_files/enst_audio.aac "" "1"
test_inspect $MEDIA_DIR/auxiliary_files/counter.hvc "" "1"
test_inspect $MEDIA_DIR/auxiliary_files/video.av1 "" "1"
test_inspect $EXTERNAL_MEDIA_DIR/qt_prores/prores422.mov ":SID=#PID=11" "0"
test_inspect $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.ac3 "" "1"
test_inspect $MEDIA_DIR/auxiliary_files/enstvid.ivf "" "1"

test_begin "inspect-info"
if [ "$test_skip" != 1 ] ; then
inspect="$TEMP_DIR/inspect.txt"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/count_video.cmp inspect:deep:log=$inspect:info" "inspect"
do_hash_test $inspect "inspect"

fi
test_end


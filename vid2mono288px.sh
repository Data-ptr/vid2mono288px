#!/bin/bash

FPS=2
AR=24x12
DITHER='-sws_dither a_dither'


## getopts

OPTIND=1

while getopts ":hvcr:" opt; do
    case "$opt" in
    h)
        echo -e "\n ##########\n" '## VIDeo file -to- MONOchrome 288px array' "\n ##########\n"
        echo -e "\t" "USAGE: $0 [-hvc] [-r#] video_file"
        echo -e "\t" '-h' "\t\t" 'This help message'
        echo -e "\t" '-v' "\t\t" 'More output (mostly from `ffmpeg`)'
        echo -e "\t" '-c' "\t\t" 'Clean up `./tmpimgs` dir after completion'
        echo -e "\t" '-r' "\t\t" 'Frame rate (per second); Default: 2'
        echo -e "\t" 'video_file' "\t" 'A video to convert to `.js`' "\n\n"
        
        exit 2
        ;;
    v)
        VERBOSE=1
        ;;
    c)
        CLEAN=1
        ;;
    r)
        FPS=$OPTARG
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

INVIDEO=$1

if [ ! -f "$INVIDEO" ]; then
    echo "You need to provide a video file name to convert";
    exit 1;
fi

## end getopts


TAB='    '
NL="\n"
LITNL=$(echo -e "\n")
TMPDIR="./tmpimgs/"

mkdir "$TMPDIR"

echo "# Making frames"

if [ "1" = "$VERBOSE" ]; then
    ffmpeg -i $INVIDEO -r $FPS -s $AR $DITHER -sn -an -f image2 -pix_fmt monob ./tmpimgs/output%06d.bmp
else
    ffmpeg -i $INVIDEO -r $FPS -s $AR $DITHER -sn -an -f image2 -pix_fmt monob ./tmpimgs/output%06d.bmp 2> /dev/null
fi

echo "# Frames done!"
echo "# Dumping frames"

for frame in "$TMPDIR"*.bmp
    do
        txtframe=$TMPDIR$(basename "$frame" .bmp).txt
        xxd -b -s -48 -g 3 -c 4  $frame | cut -d' ' -f2 | tail -r > "$txtframe";
    done
    
echo "# Frames dumped!"
echo "# Converting dumps"

JSOUT="$INVIDEO.js"

printf "%s\n\n" "$(cat <<OPENINGCOMMENT
/*

    animationFrames = [ <-- the whole animation (an array of frames)
        [ <-- A frame
            [ <-- A line
*/


OPENINGCOMMENT)" > $JSOUT

printf "var animationFrames = [$NL" >> $JSOUT;

for binary in ./tmpimgs/*.txt
    do
        printf "$TAB[$NL" >> $JSOUT;
        
        sed -E -e "s/0/t/g" \
        -e "s/1/  0, /g"        \
        -e "s/t/100, /g"      \
        -e "s/(.*)/$TAB$TAB[ \1 ],$LITNL/" \
        $binary >> $JSOUT;
        
        printf "$TAB],$NL" >> $JSOUT;
    done

printf "];$NL$NL" >> $JSOUT;

echo "# Dumps converted!";

if [ "1" = "$CLEAN" ]; then
    echo "# Cleaning up";
    rm -rf ./tmpimgs;
fi

echo "# DONE!";

exit 0;

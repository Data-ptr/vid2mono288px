# VIDeo file -to- MONOchrome 288px array

## USAGE

```
    ./vid2mono288px.sh [-hvc] [-r#] video_file
```

* `-h` Help message
* `-v` More output (mostly from `ffmpeg`)
* `-c` Clean up `./tmpimgs` dir after completion
* `-r` Frame rate (per second); Default: 2
* `video_file` A video to convert to `.js`

## CREDITS:

* [288](http://inthecolorfield.com/prop/288/)

* [Slow Motion Flame](https://archive.org/details/SlowMotionFlame)
* [ffmpeg](https://www.ffmpeg.org/)
* [getopts](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/getopts.html)

wget https://github.com/asqel/SDL/archive/refs/heads/SDL2.zip
unzip -q SDL2.zip

prefix="SDL-SDL2"

profan_path="../../profanOS"
CFLAGS="-fPIC -ffreestanding -fno-exceptions -m32 -I$profan_path/include/zlibs -I$profan_path/include/addons -O1 -nostdinc -U_WIN32 -U__linux__ -I$prefix/include -Isrc -D__profanOS__=1"

LDFLAGS="-shared -nostdlib -m32"
LD=gcc
CC=gcc

bins="$prefix/bins"
rm -rf $bins/*

mkdir -p $bins

files="$prefix/src/*.c $prefix/src/atomic/*.c $prefix/src/audio/*.c $prefix/src/cpuinfo/*.c $prefix/src/events/*.c $prefix/src/file/*.c $prefix/src/haptic/*.c $prefix/src/joystick/*.c $prefix/src/power/*.c $prefix/src/render/*.c $prefix/src/render/software/*.c $prefix/src/stdlib/*.c $prefix/src/thread/*.c $prefix/src/timer/*.c $prefix/src/video/*.c $prefix/src/audio/disk/*.c $prefix/src/audio/dummy/*.c $prefix/src/filesystem/profanOS/*.c $prefix/src/video/profanOS/*.c $prefix/src/haptic/dummy/*.c $prefix/src/joystick/dummy/*.c $prefix/src/main/dummy/*.c $prefix/src/thread/generic/*.c $prefix/src/timer/profanOS/*.c $prefix/src/loadso/dummy/*.c"
count=0

for i in $files; do
    echo "Compiling $i..."
    $CC $CFLAGS -c $i -o $bins/$count.o
    if [ ! -f $bins/$count.o ]; then
        echo "Cannot compile $i"
        exit 1
    fi
    count=$((count + 1))
done

$LD $LDFLAGS -o ../../build/libSDL2.so $bins/*.o

rm -Rf SDL*

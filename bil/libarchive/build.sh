rm -Rf libarchive-3.7.7

tar -xf $LIBATRON_DL_PATH/libarchive.tar.gz

patch -p1 -d libarchive-3.7.7 < patch.diff
cd libarchive-3.7.7

cat << EOF > link.ld
STARTUP($PROFAN_PATH/out/make/entry_elf.o)
ENTRY(_start)

SECTIONS {
    . = 0xC0000000;

    .text : {
        *(.text)
        *(.text.*)
    }

    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }

    .data : {
        *(.data)
        *(.data.*)
    }

    .bss : {
        *(.bss)
        *(.bss.*)
    }
}
EOF

export CC="../mycc"
export CFLAGS="-m32 -ffreestanding -fno-exceptions -nostdlib -nostdinc -fno-stack-protector -I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons -Wall -D__profanOS__ -U__linux__ -Wno-unused-function"
export LDFLAGS="-Wl,-melf_i386 -nostdlib -L$PROFAN_PATH/out/zlibs -lc"

export PKG_CONFIG=/bin/false

./configure --prefix=/ \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            --enable-shared --disable-static \
            --enable-bsdtar=static --enable-bsdcpio=static \
            --enable-bsdcat=static --enable-bsdunzip=static \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            LDFLAGS="$LDFLAGS"

make -j$(nproc)

if [ $? -ne 0 ]; then
    exit 1
fi

cp .libs/libarchive.so   $LIBATRON_OUT_PATH/libarchive.so
cp .libs/libarchive_fe.a $LIBATRON_OUT_PATH/libarchive_fe.a

cp bsdtar   $LIBATRON_OUT_PATH/bsdtar.elf
cp bsdcpio  $LIBATRON_OUT_PATH/bsdcpio.elf
cp bsdcat   $LIBATRON_OUT_PATH/bsdcat.elf
cp bsdunzip $LIBATRON_OUT_PATH/bsdunzip.elf

cd ..
rm -Rf libarchive-3.7.7

rm -Rf libpng-1.6.47

tar -xf $LIBATRON_DL_PATH/v1.6.47.tar.gz

cd libpng-1.6.47

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
export CFLAGS="-m32 -Wno-discarded-qualifiers -ffreestanding -fno-exceptions -nostdinc -fno-stack-protector -D__profanOS__"
export CPPFLAGS="-I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons"
export LDFLAGS="-Wl,-melf_i386 -nostdlib -L$PROFAN_PATH/out/zlibs -lc"

./configure --prefix=/ \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            CPPFLAGS="$CPPFLAGS" \
            LDFLAGS="$LDFLAGS"

sed -i 's/#define HAVE_FEENABLEEXCEPT 1/#undef HAVE_FEENABLEEXCEPT/' config.h

make -j$(nproc)

cp .libs/libpng16.so $LIBATRON_OUT_PATH/libpng16.so
cp .libs/libpng16.a  $LIBATRON_OUT_PATH/libpng16.a

tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf $LIBATRON_OUT_PATH/libpng_headers.tar.gz png.h pngconf.h pnglibconf.h

cd ..
rm -Rf libpng-1.6.47

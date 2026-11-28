rm -Rf libxml2-2.15.2

tar -xf $LIBATRON_DL_PATH/libxml2-2.15.2.tar.xz

tmp_install=$(realpath tmp_install)
rm -Rf $tmp_install

cd libxml2-2.15.2


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
export LDFLAGS="-Wl,-melf_i386 -nostdlib -nostdlib -L$PROFAN_PATH/out/zlibs -lc"

./configure --prefix=$tmp_install \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            --without-threads \
            CC="$CC" \
            LD="$CC" \
            CFLAGS="$CFLAGS" \
            CPPFLAGS="$CPPFLAGS" \
            LDFLAGS="$LDFLAGS"

make libxml2.la

# some how I have to build the .so myself

cd .libs

gcc -m32 -shared -nostdlib -L$PROFAN_PATH/out/zlibs -o $LIBATRON_OUT_PATH/libxml2.so libxml2_la-*.o -lm

cd ..

make -C include/libxml install

cd $tmp_install/include/libxml2/libxml
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf $LIBATRON_OUT_PATH/libxml_headers.tar.gz *.h
cd ../../../..

rm -Rf $tmp_install libxml2-2.15.2

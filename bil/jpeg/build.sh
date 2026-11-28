rm -Rf ijg-jpeg-10

tmp_install=$(realpath tmp_install)

tar -xf $LIBATRON_DL_PATH/jpeg-10.tar.gz

cd ijg-jpeg-10

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

./configure --prefix=$tmp_install \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            CPPFLAGS="$CPPFLAGS" \
            LDFLAGS="$LDFLAGS"

make -j$(nproc) install

cd $tmp_install/include
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf $LIBATRON_OUT_PATH/libjpeg_headers.tar.gz *.h
cd ..

cp lib/libjpeg.so $LIBATRON_OUT_PATH/libjpeg.so
cp lib/libjpeg.a  $LIBATRON_OUT_PATH/libjpeg.a
cd ..

rm -Rf ijg-jpeg-10 $tmp_install link.ld

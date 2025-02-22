rm -Rf libpng-1.6.47

wget https://github.com/pnggroup/libpng/archive/refs/tags/v1.6.47.tar.gz
tar -xvf v1.6.47.tar.gz
rm -f v1.6.47.tar.gz

cd libpng-1.6.47

profan_path="../../../profanOS"

cat << EOF > link.ld
STARTUP($profan_path/out/make/entry_elf.o)
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
export CPPFLAGS="-I $profan_path/include/zlibs -I $profan_path/include/addons"
export LDFLAGS="-Wl,-melf_i386 -nostdlib -L$profan_path/out/zlibs -lc"

./configure --prefix=/ \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            CPPFLAGS="$CPPFLAGS" \
            LDFLAGS="$LDFLAGS"

sed -i 's/#define HAVE_FEENABLEEXCEPT 1/#undef HAVE_FEENABLEEXCEPT/' config.h

make -j$(nproc)

cp .libs/libpng16.so ../../../build/libpng16.so
cp .libs/libpng16.a  ../../../build/libpng16.a

tar -czf ../../../build/libpng_headers.tar.gz png.h pngconf.h pnglibconf.h

cd ..
rm -Rf libpng-1.6.47

rm -Rf ijg-jpeg-10

tmp_install=$(realpath tmp_install)
profan_path="$(realpath ../../profanOS)"

wget https://github.com/libjpeg-turbo/ijg/archive/refs/tags/jpeg-10.tar.gz
tar -xvf jpeg-10.tar.gz
rm -f jpeg-10.tar.gz

cd ijg-jpeg-10

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

./configure --prefix=$tmp_install \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            CPPFLAGS="$CPPFLAGS" \
            LDFLAGS="$LDFLAGS"

make -j$(nproc) install

cd $tmp_install/include
tar -czf ../../../../build/libjpeg_headers.tar.gz *.h
cd ..

cp lib/libjpeg.so ../../../build/libjpeg.so
cp lib/libjpeg.a  ../../../build/libjpeg.a
cd ..

rm -Rf ijg-jpeg-10 $tmp_install link.ld

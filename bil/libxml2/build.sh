rm -Rf libxml2-2.15.2

wget https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.2.tar.xz
tar -xf libxml2-2.15.2.tar.xz
rm -f libxml2-2.15.2.tar.xz

tmp_install=$(realpath tmp_install)
output_dir=$(realpath ../../build)
rm -Rf $tmp_install

cd libxml2-2.15.2

profan_path="/home/pf4/Documents/GitHub/profanOS"

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
export LDFLAGS="-Wl,-melf_i386 -nostdlib -nostdlib -L$profan_path/out/zlibs -lc"

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

gcc -m32 -shared -nostdlib -o $output_dir/libxml2.so libxml2_la-*.o -lm

cd ..

make -C include/libxml install

cd $tmp_install/include/libxml2/libxml
tar -czf $output_dir/libxml_headers.tar.gz *.h
cd ../../../..

rm -Rf $tmp_install libxml2-2.15.2

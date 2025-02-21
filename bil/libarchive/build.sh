profan_path="../../../profanOS"

rm -Rf libarchive-3.7.7

wget https://github.com/libarchive/libarchive/releases/download/v3.7.7/libarchive-3.7.7.tar.gz -O libarchive.tar.gz
tar -xf libarchive.tar.gz
rm libarchive.tar.gz

patch -p1 -d libarchive-3.7.7 < patch.diff
cd libarchive-3.7.7

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
export CFLAGS="-m32 -ffreestanding -fno-exceptions -nostdlib -nostdinc -fno-stack-protector -I $profan_path/include/zlibs -I $profan_path/include/addons -Wall -D__profanOS__ -U__linux__ -Wno-unused-function"
export LDFLAGS="-Wl,-melf_i386 -nostdlib -L$profan_path/out/zlibs -lc"

export PKG_CONFIG=/bin/false

./configure --prefix=/ \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            LDFLAGS="$LDFLAGS"

make -j$(nproc)

if [ $? -ne 0 ]; then
    exit 1
fi

cp .libs/libarchive.a ../../../build/libarchive.a
cp .libs/libarchive.so ../../../build/libarchive.so
cp .libs/libarchive_fe.a ../../../build/libarchive_fe.a

cp bsdtar ../../../build/bsdtar.elf
cp bsdcpio ../../../build/bsdcpio.elf
cp bsdcat ../../../build/bsdcat.elf
cp bsdunzip ../../../build/bsdunzip.elf

cd ..
rm -Rf libarchive-3.7.7

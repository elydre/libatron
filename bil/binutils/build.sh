profan_path=$(realpath ../../profanOS)

tempinstall=$(realpath tmpinstall)
mkdir -p $tempinstall

if [ ! -f binutils-2.44.tar.gz ]; then
    wget https://ftp.wayne.edu/gnu/binutils/binutils-2.44.tar.gz
fi

rm -Rf binutils-2.44
tar -xf binutils-2.44.tar.gz
rm binutils-2.44.tar.gz

# remove "include <sys/param.h>"
sed -i '25d' binutils-2.44/libctf/ctf-impl.h
sed -i '21d' binutils-2.44/libctf/ctf-create.c

# change "0x08048000" to "0xC0000000"
sed -i 's/0x08048000/0xC0000000/g' binutils-2.44/ld/emulparams/elf_i386.sh

# add LIB_PATH="/lib" to genscripts.sh
sed -i '287i\LIB_PATH="/lib"' binutils-2.44/ld/genscripts.sh

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

cat << EOF > mycc
#!/bin/bash

set -- -fno-exceptions "\$@"

# if -shared, -c, or -E is passed
if [[ "\$@" == *" -shared "* ]] || [[ "\$@" == *" -c "* ]] || [[ "\$@" == *" -E "* ]]; then
    gcc "\$@"
else
    gcc -Wl,-T $PWD/link.ld "\$@" 
fi
EOF

chmod +x mycc

export AR=ar

export CC=$(realpath mycc)
export CFLAGS="-m32 -march=i686 -ffreestanding -nostdlib -nostdinc -fno-stack-protector -D_Thread_local= -I $profan_path/include/zlibs -I $profan_path/include/addons -D__profanOS__"
export CPPFLAGS="--sysroot=useless -I $profan_path/include/zlibs -I $profan_path/include/addons"

export LDFLAGS="-m32 -nostdlib -L$profan_path/out/zlibs -lc"

SRC_PATH=$(realpath binutils-2.44)

mkdir -p $SRC_PATH/build
cd $SRC_PATH/build

$SRC_PATH/configure \
    --prefix=$tempinstall \
    --target=i686-elf \
    --host=i686-bsd \
    --build=x86_64-linux-gnu \
    --disable-gold \
    --disable-nls \
    --enable-warn-execstack=no \
    CC="$CC" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    CPPFLAGS="$CPPFLAGS"

# Compilation
make -j$(nproc)

if [ $? -ne 0 ]; then
    echo "Compilation failed"
    exit 1
else
    echo "Compilation successful !!!!!!!!!!!!"
fi

make install

cd $tempinstall/i686-elf/bin
rm ld.bfd
mv readelf gnu-readelf

for file in $(ls); do
    mv $file $file.elf
done

tar -czf ../../../../../build/binutils.tar.gz *
cd ../../../

rm -Rf $SRC_PATH $tempinstall mycc link.ld

rm -rf es-0.9.2
mkdir es-0.9.2
cd es-0.9.2

tar -xf $LIBATRON_DL_PATH/es-0.9.2.tar.gz

sed -i '55d' stdenv.h # useless include
sed -i '28d' stdenv.h # useless include

cp ../initial.c .

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

export CC="gcc"
export CFLAGS="-m32 -ffreestanding -fno-exceptions -nostdlib -nostdinc -fno-stack-protector -I $PROFAN_PATH/include/zlibs -Wall -D__profanOS__ -U__linux__ -Wno-unused-function -DBUILTIN_TIME=0 -DNSIG=64"
export LDFLAGS="-Wl,-melf_i386 -Wl,-T link.ld -nostdlib -L$PROFAN_PATH/out/zlibs -lc"

./configure --prefix=/ \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            LDFLAGS="$LDFLAGS" \
            es_cv_abused_getenv=no \

if [ $? -ne 0 ]; then
    exit 1
fi

sed -i '106d' Makefile
sed -i '105d' Makefile

make -j$(nproc)

cp es $LIBATRON_OUT_PATH/es.elf
cd ..
rm -rf es-0.9.2

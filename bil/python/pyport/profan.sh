rm config.status config.log config.h

profan_sysroot=$(pwd)/../python-profan
rm -rf $profan_sysroot
mkdir -p $profan_sysroot

cat << EOF > config.site
    ac_cv_enable_implicit_function_declaration_error=no
    ac_cv_file__dev_ptmx=no
    ac_cv_file__dev_ptc=no
EOF

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

export CONFIG_SITE=config.site
export OPT="-Wall -D__profanOS__ -U__linux__ -D_Py_FORCE_UTF8_LOCALE"

export CC="./mycc"
export CFLAGS="-m32 -ffreestanding -fno-exceptions -nostdlib -nostdinc -fno-stack-protector -I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons"
export LDFLAGS="-Wl,-m elf_i386 -nostdlib -L $PROFAN_PATH/out/zlibs -lc"
export CPPFLAGS="--sysroot=$profan_sysroot -I $PROFAN_PATH/include/zlibs"

./configure --prefix=/ \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            --with-build-python=$(pwd)/../python-linux/bin/python3 \
            --with-suffix=.elf \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            LDFLAGS="$LDFLAGS" \
            CPPFLAGS="$CPPFLAGS"

rm config.site

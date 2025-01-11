rm config.status config.log config.h

if [ $# -ne 1 ]; then
    echo "Usage: $0 <profan_path>"
    exit 1
fi

profan_path=$1

profan_sysroot=$(pwd)/../python-profan
rm -rf $profan_sysroot
mkdir -p $profan_sysroot

cat << EOF > config.site
    ac_cv_enable_implicit_function_declaration_error=no
    ac_cv_file__dev_ptmx=no
    ac_cv_file__dev_ptc=no
EOF

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

export CONFIG_SITE=config.site
export OPT="-Wall -D__profanOS__ -U__linux__ -D_Py_FORCE_UTF8_LOCALE"

export CC="./mycc"
export CFLAGS="-m32 -ffreestanding -fno-exceptions -nostdlib -nostdinc -fno-stack-protector -I $profan_path/include/zlibs -I $profan_path/include/addons"
export LDFLAGS="-Wl,-m elf_i386 -nostdlib -L $profan_path/out/zlibs -lc"
export CPPFLAGS="--sysroot=$profan_sysroot -I $profan_path/include/zlibs"

./configure --prefix=/ \
            --host=i686-linux-gnu \
            --build=x86_64-linux-gnu \
            --with-build-python=$(pwd)/../python-linux/bin/python3 \
            --with-suffix=.elf \
            --without-pymalloc \
            CC="$CC" \
            CFLAGS="$CFLAGS" \
            LDFLAGS="$LDFLAGS" \
            CPPFLAGS="$CPPFLAGS"

rm config.site

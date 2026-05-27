export PROFAN_PATH=$(realpath "../../profanOS")
export BUILD_BASE_PATH=$(realpath .)

tmplibcxx_install=$(realpath tmplibcxx)
gcc_install=$(realpath gccinstall)

rm -Rf $tmplibcxx_install $gcc_install

cc_opti="-Os"

set -e

# Download and prepare GCC sources
rm -f gcc-11.2.0.tar.gz
wget https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz

rm -Rf gcc-11.2.0
tar -xf gcc-11.2.0.tar.gz
rm gcc-11.2.0.tar.gz

cd gcc-11.2.0
./contrib/download_prerequisites
cd ..

libcxx_path=$(realpath gcc-11.2.0/libstdc++-v3)
gcc_src_path=$(realpath gcc-11.2.0)

# Apply some patches to the source code
find $libcxx_path -type f -exec sed -i 's/#include_next <\([^>]*\)>/#include <\1>/g' {} +
sed -i 's/#include "unwind.h"/#include "\/usr\/lib\/gcc\/x86_64-linux-gnu\/11\/include\/unwind.h"/g' $libcxx_path/libsupc++/unwind-cxx.h
sed -i '25d' $gcc_src_path/gcc/cp/mapper-client.cc
sed -i '24i\#include <sys/select.h>' $gcc_src_path/libcc1/connection.cc
sed -i '1182i\  if (!warn_if_not_align) return;' $gcc_src_path/gcc/stor-layout.c
sed -i '8017i\  char *n[argc+2];n[0]=argv[0];n[1]="-B/lib/gcc";for (int i=1;i<argc;i++){n[i+1]=argv[i];}n[++argc]=0;argv = n;' $gcc_src_path/gcc/gcc.c

mkdir -p useless # used as a sysroot


# ================ Stage 1: Build a minimal libstdc++ ================

mkdir -p $tmplibcxx_install

export AR=ar

export CXX="$(realpath exe/mycc++stage1) -m32 -march=i686"
export CXXFLAGS="-ffreestanding -fno-use-cxa-atexit -fno-exceptions -nostdlib -fno-stack-protector -I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons -D__profanOS__"

export CPPFLAGS="--sysroot=useless -I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons"

mkdir -p $libcxx_path/build
cd $libcxx_path/build

$libcxx_path/configure \
    --prefix=$tmplibcxx_install \
    --target=i686-elf \
    --host=i686-bsd \
    --build=x86_64-linux-gnu \
    --disable-multilib \
    --disable-nls \
    --disable-libstdcxx-pch \
    --with-newlib \
    AR="$AR" \
    CXX="$CXX" \
    CXXFLAGS="$CXXFLAGS" \
    CPPFLAGS="$CPPFLAGS"

# Compilation
make -j$(nproc)
make install

cd $BUILD_BASE_PATH

apply_libcxx_header_fixes() {
    for dir in $1/i686-bsd/*; do
        if [ -d "$dir" ]; then
            for file in "$dir"/*; do
                if [ -f "$file" ]; then
                    cp "$file" "$1/$(basename "$dir")/"
                fi
            done
        fi
    done
    rm -rf $1/i686-bsd
}

apply_libcxx_header_fixes $tmplibcxx_install/include/c++/11.2.0

# ================ Stage 2: Build the full GCC ===============

mkdir -p $gcc_install

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

cat << EOF > config.site
    ac_cv_c_bigendian=no
    ac_cv_sizeof_long_long=8
EOF

export CONFIG_SITE=$(realpath config.site)
export PATH=$PATH:$(realpath exe)

export AR=ar

export CC=$(realpath exe/i686-elf-cc)
export GCC_FOR_TARGET=$CC
export CFLAGS="-m32 $cc_opti -march=i686 -ffreestanding -fno-exceptions -fno-omit-frame-pointer -nostdlib -nostdinc -fno-stack-protector -I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons -D__profanOS__"
export CC_FOR_BUILD="$(realpath exe/mycc-host) gcc"
export CFLAGS_FOR_BUILD=""

export CXX="$(realpath exe/mycc++stage2) -m32 $cc_opti -march=i686 -ffreestanding -fno-exceptions -nostdlib -fno-stack-protector -I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons -D__profanOS__"
export CXX_FOR_TARGET=$CXX
export CXXFLAGS="-DCODY_NETWORKING=0 -fno-use-cxa-atexit -Dstrsignal=strsignal -fno-omit-frame-pointer"
export CXXFLAGS_FOR_TARGET=$CXXFLAGS
export CXX_FOR_BUILD="$(realpath exe/mycc-host) g++"

export LDFLAGS="-m32 -nostdlib -L$PROFAN_PATH/out/zlibs -lc"
export LDFLAGS_FOR_TARGET=$LDFLAGS
export LDFLAGS_FOR_BUILD=""

export CPPFLAGS="--sysroot=useless -I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons"


rm -Rf $gcc_src_path/build
mkdir -p $gcc_src_path/build
cd $gcc_src_path/build

$gcc_src_path/configure \
    --prefix=$gcc_install \
    --target=i686-elf \
    --host=i686-bsd \
    --build=x86_64-linux-gnu \
    --disable-multilib \
    --disable-bootstrap \
    --disable-libstdcxx-pch \
    --disable-threads \
    --disable-decimal-float \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --enable-libstdcxx \
    --with-newlib \
    --disable-nls \
    --disable-cet \
    --enable-languages=c,c++ \
    --with-sysroot=/ \
    --with-native-system-header-dir=/sys/include \
    --verbose \
    AR="$AR" \
    CC="$CC" \
    CC_FOR_BUILD="$CC_FOR_BUILD" \
    GCC_FOR_TARGET="$GCC_FOR_TARGET" \
    CFLAGS="$CFLAGS" \
    CFLAGS_FOR_BUILD="$CFLAGS_FOR_BUILD" \
    CXX="$CXX" \
    CXX_FOR_TARGET="$CXX_FOR_TARGET" \
    CXX_FOR_BUILD="$CXX_FOR_BUILD" \
    CXXFLAGS="$CXXFLAGS" \
    CXXFLAGS_FOR_TARGET="$CXXFLAGS_FOR_TARGET" \
    LDFLAGS="$LDFLAGS" \
    LDFLAGS_FOR_TARGET="$LDFLAGS_FOR_TARGET" \
    LDFLAGS_FOR_BUILD="$LDFLAGS_FOR_BUILD" \
    CPPFLAGS="$CPPFLAGS"

# Compilation

make -j$(nproc)
make install

cd $BUILD_BASE_PATH
rm -rf $gcc_src_path $tmplibcxx_install useless link.ld config.site

apply_libcxx_header_fixes $gcc_install/i686-elf/include/c++/11.2.0

output_dir=$(realpath ../../build)

cd $gcc_install

# copy gcc executable
cp bin/i686-elf-gcc $output_dir/gcc.elf

# copy c++ headers and libraries
cp i686-elf/lib32/libstdc++.a $output_dir/libstdc++.a
cp i686-elf/lib32/libsupc++.a $output_dir/libsupc++.a

cd i686-elf/include/c++/11.2.0
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf $output_dir/libstdc++_headers.tar.gz *

# copy /lib/gcc dir (internal GCC files)
cd $gcc_install/lib/gcc/i686-elf/11.2.0
rm -rf install-tools plugin
cp $gcc_install/libexec/gcc/i686-elf/11.2.0/cc1 cc1
cp $PROFAN_PATH/out/make/entry_elf.o crt0.o
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf $output_dir/libgcc_dir.tar.gz *
cp libgcc.a $output_dir/libgcc.a

cd $BUILD_BASE_PATH
rm -rf $gcc_install

echo "------------- SUCCESS -------------"

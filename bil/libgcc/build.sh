rm -Rf build
mkdir build

profan_path="../../profanOS"
cflags="-Werror -Wall -Wextra -nostdinc -m32 -Iheaders -Isrc/i386 -I$profan_path/include/zlibs -fno-builtin -fno-stack-protector -fno-exceptions -fPIC -DUNITS_PER_WORD=4"
pfff="-DL_absvsi2 -DL_addvsi3 -DL_ashrdi3 -DL_bswapsi2 -DL_clrsbsi2 -DL_clzsi2 -DL_cmpdi2 -DL_divdi3 -DL_divmoddi4 -DL_ffssi2 -DL_fixunsdfsi -DL_fixunssfsi -DL_floatdisf -DL_floatdixf -DL_floatundisf -DL_floatundixf -DL_lshrdi3 -DL_moddi3 -DL_muldi3 -DL_mulvsi3 -DL_negvsi2 -DL_paritysi2 -DL_popcountsi2 -DL_subvsi3 -DL_ucmpdi2 -DL_udivdi3"

dest="../../build"

for e in $(find src -name "*.c"); do
    output=build/$(basename $e .c).o
    echo $e
    gcc $cflags $pfff -c $e -o $output
    if [ $? -ne 0 ]; then
        echo "Error"
        exit 1
    fi
done

ar -rcs $dest/libgcc.a build/*.o
gcc -shared -nostdlib -m32 -o $dest/libgcc.so build/*.o

rm -Rf build

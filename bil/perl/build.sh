rm -rf build
mkdir build

cflag="-m32 -ffreestanding -fno-exceptions -nostdinc -fno-stack-protector -I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons -I extra -D__profanOS__ -DNO_LOCALE"
ldflag="-m elf_i386 -nostdlib -L $PROFAN_PATH/out/zlibs -T $PROFAN_PATH/tools/link_elf.ld -lc -lm"

for e in src/*.c; do
    n=$(basename $e .c)
    echo "CC $e"
    gcc $cflag -DPERL_CORE -c $e -o build/$n.o &
done

wait

gcc $cflag -I src -c src/DynaLoader/DynaLoader.c -o build/DynaLoader.o

ld $ldflag $PROFAN_PATH/out/make/entry_elf.o build/*.o -o $LIBATRON_OUT_PATH/perl.elf
rm -rf build

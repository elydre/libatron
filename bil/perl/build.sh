rm -rf build
mkdir build

profan_path=../../profanOS

cflag="-m32 -ffreestanding -fno-exceptions -nostdinc -fno-stack-protector -I $profan_path/include/zlibs -I $profan_path/include/addons -I extra -D__profanOS__ -DNO_LOCALE"
ldflag="-m elf_i386 -nostdlib -L $profan_path/out/zlibs -T $profan_path/tools/link_elf.ld -lc -lm"

for e in src/*.c; do
    n=$(basename $e .c)
    echo "CC $e"
    gcc $cflag -DPERL_CORE -c $e -o build/$n.o &
done

wait

gcc $cflag -I src -c src/DynaLoader/DynaLoader.c -o build/DynaLoader.o

ld $ldflag $profan_path/out/make/entry_elf.o build/*.o -o ../../build/perl.elf
rm -rf build

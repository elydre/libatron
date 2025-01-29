CFLAG="-m32 -ffreestanding -fno-exceptions -nostdinc -fno-stack-protector -DHAVE_CONFIG_H -I src -I lib -DLIBDIR=\"/lib\" -DLOCALEDIR=\"/idk\" -I ../../profanOS/include/zlibs -D__profanOS__"
LD_FLAGS="-m elf_i386 -nostdlib -L ../../profanOS/out/zlibs -T ../../profanOS/tools/link_elf.ld -lc"

rm -rf obj
mkdir obj

gcc $CFLAG -c -o obj/ar.o src/ar.c
gcc $CFLAG -c -o obj/arscan.o src/arscan.c
gcc $CFLAG -c -o obj/commands.o src/commands.c
gcc $CFLAG -c -o obj/default.o src/default.c
gcc $CFLAG -c -o obj/dir.o src/dir.c
gcc $CFLAG -c -o obj/expand.o src/expand.c
gcc $CFLAG -c -o obj/file.o src/file.c
gcc $CFLAG -c -o obj/function.o src/function.c
gcc $CFLAG -c -o obj/getopt.o src/getopt.c
gcc $CFLAG -c -o obj/getopt1.o src/getopt1.c
gcc $CFLAG -c -o obj/guile.o src/guile.c
gcc $CFLAG -c -o obj/hash.o src/hash.c
gcc $CFLAG -c -o obj/implicit.o src/implicit.c
gcc $CFLAG -c -o obj/job.o src/job.c
gcc $CFLAG -c -o obj/load.o src/load.c
gcc $CFLAG -c -o obj/loadapi.o src/loadapi.c
gcc $CFLAG -c -o obj/main.o src/main.c
gcc $CFLAG -c -o obj/misc.o src/misc.c
gcc $CFLAG -c -o obj/output.o src/output.c
gcc $CFLAG -c -o obj/read.o src/read.c
gcc $CFLAG -c -o obj/remake.o src/remake.c
gcc $CFLAG -c -o obj/rule.o src/rule.c
gcc $CFLAG -c -o obj/shuffle.o src/shuffle.c
gcc $CFLAG -c -o obj/signame.o src/signame.c
gcc $CFLAG -c -o obj/strcache.o src/strcache.c
gcc $CFLAG -c -o obj/variable.o src/variable.c
gcc $CFLAG -c -o obj/version.o src/version.c
gcc $CFLAG -c -o obj/vpath.o src/vpath.c
gcc $CFLAG -c -o obj/posixos.o src/posixos.c
gcc $CFLAG -c -o obj/remote-stub.o src/remote-stub.c

gcc $CFLAG -c -o obj/fnmatch.o lib/fnmatch.c
gcc $CFLAG -c -o obj/glob.o lib/glob.c

ld $LD_FLAGS -o ../../build/make.elf ../../profanOS/out/make/entry_elf.o obj/*.o
rm -rf obj

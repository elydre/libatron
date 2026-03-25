pdir="../../profanOS"

git clone https://github.com/limine-bootloader/limine.git --branch=v8.x-binary --depth=1
mkdir -p $pdir/zapps/c/limine
cp -r limine/limine.c limine/limine-bios-hdd.h $pdir/zapps/c/limine

cd limine
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf ../../../build/limine.tar.gz limine-bios-cd.bin limine-bios.sys
cd ..
rm -rf limine

echo "limine" >> ../../tocp.txt

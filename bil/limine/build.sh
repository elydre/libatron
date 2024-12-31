pdir="../../profanOS"

git clone https://github.com/limine-bootloader/limine.git --branch=v8.x-binary --depth=1
mkdir -p $pdir/zapps/cmd/limine
cp -r limine/limine.c limine/limine-bios-hdd.h $pdir/zapps/cmd/limine

cd limine
tar -czf ../../../build/limine.tar.gz limine-bios-cd.bin limine-bios.sys
cd ..
rm -rf limine

echo "limine" >> ../../tocp.txt

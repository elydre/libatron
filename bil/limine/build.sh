git clone https://github.com/limine-bootloader/limine.git --branch=v8.x-binary --depth=1
mkdir -p $PROFAN_PATH/zapps/c/limine
cp -r limine/limine.c limine/limine-bios-hdd.h $PROFAN_PATH/zapps/c/limine

cd limine
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf $LIBATRON_OUT_PATH/limine.tar.gz limine-bios-cd.bin limine-bios.sys
cd ..
rm -rf limine

echo "limine" >> $LIBATRON_TOCP_FILE

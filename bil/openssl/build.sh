profan_path="../../../profanOS"

install_dir=$(realpath tmp_install)
rm -Rf $install_dir openssl-3.6.2

wget https://github.com/openssl/openssl/releases/download/openssl-3.6.2/openssl-3.6.2.tar.gz
tar -xf openssl-3.6.2.tar.gz
rm openssl-3.6.2.tar.gz

cd openssl-3.6.2

export CC="../mycc"
export CFLAGS="-m32 -Wno-discarded-qualifiers -ffreestanding -fno-exceptions -nostdinc -fno-stack-protector -D__profanOS__ -DNO_SYS_PARAM_H -DNO_SYS_UN_H -DNO_SYSLOG -DOPENSSL_USE_IPV6=0"
export CPPFLAGS="-I $profan_path/include/zlibs -I $profan_path/include/addons"
export LDFLAGS="-Wl,-melf_i386 -nostdlib -L$profan_path/out/zlibs -lc"

./config \
    --prefix=$install_dir \
    no-tests \
    no-apps \
    no-docs \
    no-module \
    no-dso \
    no-threads \
    no-ui-console \
    no-autoload-config \
    no-deprecated \
    linux-x86

make -j$(nproc)
make install_dev # install_ssldirs install_sw

cd $install_dir/include/openssl
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf ../../../../../build/openssl_headers.tar.gz *.h
cd ../..

cp lib/libcrypto.so ../../../build/libcrypto.so
cp lib/libcrypto.a  ../../../build/libcrypto.a

cp lib/libssl.so ../../../build/libssl.so
cp lib/libssl.a  ../../../build/libssl.a

cd ..

rm -Rf $install_dir openssl-3.6.2

install_dir=$(realpath tmp_install)
rm -Rf $install_dir openssl-3.6.2

tar -xf $LIBATRON_DL_PATH/openssl-3.6.2.tar.gz

cd openssl-3.6.2

export CC="../mycc"
export CFLAGS="-m32 -Wno-discarded-qualifiers -ffreestanding -fno-exceptions -nostdinc -fno-stack-protector -D__profanOS__ -DNO_SYS_PARAM_H -DNO_SYS_UN_H -DNO_SYSLOG -DOPENSSL_USE_IPV6=0"
export CPPFLAGS="-I $PROFAN_PATH/include/zlibs -I $PROFAN_PATH/include/addons"
export LDFLAGS="-Wl,-melf_i386 -nostdlib -L$PROFAN_PATH/out/zlibs -lc"

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
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf $LIBATRON_OUT_PATH/openssl_headers.tar.gz *.h
cd ../..

cp lib/libcrypto.so $LIBATRON_OUT_PATH/libcrypto.so
cp lib/libcrypto.a  $LIBATRON_OUT_PATH/libcrypto.a

cp lib/libssl.so $LIBATRON_OUT_PATH/libssl.so
cp lib/libssl.a  $LIBATRON_OUT_PATH/libssl.a

cd ..

rm -Rf $install_dir openssl-3.6.2

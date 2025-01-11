profan_path=$(realpath ../../profanOS)
dest="../../build"

rm -rf Python-3.11.11 python-linux python-profan Python-3.11.11.tgz

wget https://www.python.org/ftp/python/3.11.11/Python-3.11.11.tgz
tar -xf Python-3.11.11.tgz

# compile first time for linux
cd Python-3.11.11

./configure --prefix=$(pwd)/../python-linux
make -j $(nproc) install

cd ..

rm -rf Python-3.11.11

# compile second time for profan

tar -xf Python-3.11.11.tgz
rm Python-3.11.11.tgz

patch -p1 -d Python-3.11.11 < pyport/python-profan.patch

cp pyport/profan.sh pyport/mycc Python-3.11.11
cd Python-3.11.11

chmod +x mycc
sh profan.sh $profan_path && make -j $(nproc) DESTDIR=$(pwd)/../python-profan

if [ $? -ne 0 ]; then
    echo "Error: Python build failed"
    cd ..
    exit 1
fi

cd ..

# copy files to a new directory

mkdir -p python-profan/lib/python3.11
mkdir -p python-profan/lib/python3.11/lib-dynload
mkdir -p python-profan/include/python3.11

cp -r Python-3.11.11/Lib/* python-profan/lib/python3.11
cp -r Python-3.11.11/build/lib.linux-*/* python-profan/lib/python3.11/lib-dynload
rm -Rf python-profan/lib/python3.11/test
cd python-profan/lib/python3.11
tar -czf ../../../$dest/python-lib.tar.gz *
cd ../../../

cp -r Python-3.11.11/Include/* python-profan/include/python3.11
cp -r Python-3.11.11/pyconfig.h python-profan/include/python3.11/pyconfig.h
cd python-profan/include/python3.11
tar -czf ../../../$dest/python-include.tar.gz *
cd ../../../

cp -r Python-3.11.11/python.elf      $dest/python.elf
cp -r Python-3.11.11/libpython3.11.a $dest/libpython3.11.a

# cp -r Python-3.11.11/build/scripts-3.11/* python-profan/bin
# cp -r Python-3.11.11/python-config python-profan/bin/python-config

rm -rf python-linux Python-3.11.11 python-profan

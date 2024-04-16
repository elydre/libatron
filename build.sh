git clone https://github.com/elydre/profanOS
rm -rf build

for e in bip/lib*; do
    cp -r $e profanOS/zlibs/
done

for e in cmd/*; do
    cp -r $e profanOS/zapps/cmd/
done

cp -r _headers profanOS/include/addons/

make -C profanOS disk
if [ $? -ne 0 ]; then
    echo "Error: make disk failed"
    exit 1
fi

mkdir -p build

for e in $(ls profanOS/out/zlibs/*.so); do
    cp $e build
done

for e in cmd/*; do
    e=$(basename $e .c)
    cp profanOS/out/zapps/cmd/$e.elf build
done

for e in bil/*; do
    echo "Building $e"
    cd $e
    sh build.sh
    cd ..
done

rm -rf profanOS

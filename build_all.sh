git clone https://github.com/elydre/profanOS
rm -rf build

mkdir -p profanOS/include/addons/
for e in $(find _headers -type f); do
    cp $e profanOS/include/addons/
done

for e in bip/lib*; do
    cp -r $e profanOS/zlibs/
done

git clone https://github.com/asqel/oeuf.git profanOS/zlibs/liboe/

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

for e in $(echo "profanOS/out/zlibs/lib*/"); do
    out=$(basename $e).a
    ar rcs build/$out $(find $e -name "*.o")
    if [ $? -ne 0 ]; then
        echo "Error: ar failed"
        exit 1
    fi
    echo "Created $out"
done

for e in $(echo profanOS/out/zlibs/*.so); do
    cp $e build
done

for e in cmd/*; do
    e=$(basename $e .c)
    cp profanOS/out/zapps/cmd/$e.elf build
done

for e in bil/*; do
    echo "Building $e..."
    cd $e
    bash build.sh
    cd ../..
done

bash build_extra.sh

rm -rf profanOS

git clone https://github.com/elydre/profanOS

for e in lib*; do
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

for e in lib*; do
    cp profanOS/out/zlibs/$e.so build
done

for e in cmd/*; do
    e=$(basename $e .c)
    cp profanOS/out/zapps/cmd/$e.elf build
done

rm -rf profanOS

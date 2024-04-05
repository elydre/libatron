git clone https://github.com/elydre/profanOS

libs=$(ls -d lib*)
echo $libs

for e in lib*; do
    cp -r $e profanOS/zlibs
done

make -C profanOS disk
mkdir -p build

for e in lib*; do
    cp profanOS/out/zlibs/$e.so build
done

rm -rf profanOS

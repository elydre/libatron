rm -rf profanOS build

export PROFANOS_KIND=1
export PROFANOS_OPTIM=2

git clone https://github.com/elydre/profanOS
make -C profanOS disk

# copy lib to build with profanOS
for e in bip/lib*; do
    cp -r $e profanOS/zlibs/
done

# copy cmd to build with profanOS
for e in cmd/*; do
    cp -r $e profanOS/zapps/cmd/
done

# copy headers to profanOS directory
mkdir -p profanOS/include/addons/
cp -r rsc/*/* profanOS/include/addons/

# build some libraries in linux
mkdir -p build profanOS/out/zlibs/

touch tocp.txt
for e in bil/*; do
    echo "Building $e..."
    cd $e
    bash build.sh
    cd ../..
done

cp -v build/*.so profanOS/out/zlibs/

# build profanOS disk
make -C profanOS disk
if [ $? -ne 0 ]; then
    echo "Error: make disk failed"
    exit 1
fi

# ar all libraries in profanOS directory
for e in $(echo "profanOS/out/zlibs/lib*/"); do
    out=$(basename $e).a
    ar -rcs build/$out $(find $e -name "*.o")
    if [ $? -ne 0 ]; then
        echo "Error: ar failed"
        exit 1
    fi
    echo "Created $out"
done

for e in $(echo profanOS/out/zlibs/*.so); do
    cp $e build
done

# copy compiled commands to build directory
for e in cmd/* $(cat tocp.txt); do
    e=$(basename $e .c)
    cp profanOS/out/zapps/cmd/$e.elf build
done

rm -rf profanOS tocp.txt
ls -gh build

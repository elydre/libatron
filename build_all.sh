rm -rf profanOS build

export PROFANOS_KIND=1
export PROFANOS_OPTIM=2

check() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

git clone https://github.com/elydre/profanOS
make -C profanOS disk
check "make disk"

# copy lib to build with profanOS
for e in lib/lib*; do
    cp -r $e profanOS/zlibs/
done

# copy headers to profanOS directory
mkdir -p profanOS/include/addons/
cp -r rsc/*/* profanOS/include/addons/

# make disk with extra libraries
make -C profanOS disk
check "make disk with libraries"

# cross compile stuff
mkdir -p build

touch tocp.txt
for e in bil/*; do
    echo "Building $e..."
    cd $e
    bash -e build.sh
    check "build $e"
    cd ../..
done

cp -v build/*.so profanOS/out/zlibs/

# copy commands to profanOS directory
for e in cmd/*; do
    cp -r $e profanOS/zapps/c/
done

# make disk with extra commands
make -C profanOS disk
check "make disk with commands"

# ar all libraries in profanOS directory
for e in $(echo "profanOS/out/zlibs/lib*/"); do
    out=$(basename $e).a
    ar -rcs build/$out $(find $e -name "*.o")
    check "ar $e"
    echo "Created $out"
done

for e in $(echo profanOS/out/zlibs/*.so); do
    cp $e build
done

# copy compiled commands to build directory
for e in cmd/* $(cat tocp.txt); do
    e=$(basename $e .c)
    cp profanOS/out/zapps/c/$e.elf build
done

rm -rf profanOS tocp.txt
ls -gh build

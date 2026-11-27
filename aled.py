

import subprocess
import sys
import os

PROFAN_INCLUDE_ADDONS = "profanOS/include/addons/"

def fatal(msg):
    print(f"build_all: fatal error: {msg}", file=sys.stderr)
    sys.exit(1)

def execcmd(cmd, capture=True, isfatal=True, etcmsg=""):
    if isinstance(cmd, str):
        cmd = cmd.split()

    print(" ".join(cmd))

    result = subprocess.run(cmd, capture_output=capture, text=True)

    if isfatal and result.returncode:
        fatal(f"command {' '.join(cmd)} failed with code {result.returncode}" + (f"\n[on {etcmsg}]" if etcmsg else "") + f"\nstderr: {result.stderr}")

    return result


def rm_stuff(l):
    if not l:
        return
    execcmd(["rm", "-rf"] + l)

def stuff_in_dir(path, filter):
    l = []
    for d in os.listdir(path):
        d = os.path.join(path, d)
        if filter(d):
            l.append(d)
    return l

rm_stuff(["profanOS", "build"])

os.environ["PROFANOS_KIND"]  = "1"
os.environ["PROFANOS_OPTIM"] = "2"

execcmd("git clone https://github.com/elydre/profanOS")
# execcmd("make -C profanOS disk", capture=False, etcmsg="make initial profanOS disk") # todo is it important ?

# copy lib to build with profanOS
for e in stuff_in_dir("lib", os.path.isdir):
    execcmd(["cp", "-r", e, "profanOS/zlibs/"])

# copy headers to profanOS directory
execcmd(f"mkdir -p {PROFAN_INCLUDE_ADDONS}")

for sub in stuff_in_dir("rsc/headers", os.path.isdir):
    for elm in os.listdir(sub):
        path = os.path.join(sub, elm)
        if os.path.isdir(path):
            if os.path.exists(os.path.join(PROFAN_INCLUDE_ADDONS, elm)):
                fatal(f"{elm} already exists in {PROFAN_INCLUDE_ADDONS}")
            execcmd(["cp", "-r", path, PROFAN_INCLUDE_ADDONS])
        elif os.path.isfile(path):
            execcmd(["cp", path, PROFAN_INCLUDE_ADDONS])
        else:
            fatal(f"unknow stuff is {sub} dirrectory")


# make disk with extra libraries
execcmd("make -C profanOS disk", etcmsg="make disk with extra libraries")

# cross compile stuff
execcmd("mkdir -p build")
execcmd("touch tocp.txt")

def compile_bils():
    bil_dico = {
        "aledlang":   [],
        "binutils":   [],
        "dash":       [],
        "es":         [],
        "gcc":        [],
        "jpeg":       [],
        "libarchive": [],
        "libpng":     [],
        "libsdl2":    [],
        "libxml2":    [],
        "limine":     [],
        "make":       [],
        "nasm":       [],
        "openlibm":   [],
        "openssl":    [],
        "perl":       [],
        "python":     ["openlibm"],
    }

    todo = list(bil_dico.keys())

    print(todo)

    while todo:
        buildable = todo
        for bil in todo:
            for dep in bil_dico[bil]:
                if dep in todo:
                    buildable.remove(bil)

        if not buildable:
            fatal("dependencies \"" + "'\", \"'".join(todo) + " are not buildable due to circular depandencies")

        print(buildable)
        return


compile_bils()



"""
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

# tar all headers in profanOS directory
cd profanOS/include/zlibs
tar --mtime='UTC 2026-01-01' --sort=name --owner=0 --group=0 --numeric-owner -czf ../../../build/profanOS_headers.tar.gz *
cd ../../..

rm -rf profanOS tocp.txt
ls -gh build
ls build | wc -l
"""
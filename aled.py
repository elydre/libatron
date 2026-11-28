import subprocess
import threading
import time
import sys
import os

PROFAN_PATH = "build/profanOS"
PROFAN_INCLUDE_ADDONS = f"{PROFAN_PATH}/include/addons/"

LIBATRON_DL_PATH  = "build/www"
LIBATRON_LOG_PATH = "build/log"
LIBATRON_OUT_PATH = "build/output"
LIBATRON_TOCP_FILE = "build/tocp.txt"


WGET_PATHS = {
    "profanOS.tar.gz": "https://github.com/elydre/profanOS/archive/refs/heads/main.tar.gz",
    "binutils-2.44.tar.gz": "https://ftp.wayne.edu/gnu/binutils/binutils-2.44.tar.gz",
    "es-0.9.2.tar.gz": "https://github.com/wryun/es-shell/releases/download/v0.9.2/es-0.9.2.tar.gz",
    "gcc-11.2.0.tar.gz": "https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz",
    "jpeg-10.tar.gz": "https://github.com/libjpeg-turbo/ijg/archive/refs/tags/jpeg-10.tar.gz",
    "libarchive.tar.gz": "https://github.com/libarchive/libarchive/releases/download/v3.7.7/libarchive-3.7.7.tar.gz",
    "v1.6.47.tar.gz": "https://github.com/pnggroup/libpng/archive/refs/tags/v1.6.47.tar.gz",
    "SDL2.tar.gz": "https://github.com/elydre/sdl2-profan/archive/refs/heads/SDL2.tar.gz",
    "aledlang.tar.gz": "https://github.com/elydre/aledlang/archive/refs/heads/main.tar.gz",
    "libxml2-2.15.2.tar.xz": "https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.2.tar.xz",
    "openssl-3.6.2.tar.gz": "https://github.com/openssl/openssl/releases/download/openssl-3.6.2/openssl-3.6.2.tar.gz",
    "Python-3.11.11.tgz": "https://www.python.org/ftp/python/3.11.11/Python-3.11.11.tgz"
}

def fatal(msg):
    print(f"build_all: fatal error: {msg}", file=sys.stderr)
    sys.exit(1)

def execcmd(cmd, capture=True, isfatal=True, etcmsg=""):
    if isinstance(cmd, str):
        cmd = cmd.split()

    if etcmsg:
        print(etcmsg)
    else:
        print(" ".join(cmd))

    result = subprocess.run(cmd, capture_output=capture, text=True, encoding="utf-8", errors="replace")

    if isfatal and result.returncode:
        fatal(f"command {' '.join(cmd)} failed with code {result.returncode}\nstderr: {result.stderr}")

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

def wget_all():
    execcmd(["mkdir", "-p", LIBATRON_DL_PATH])

    for k, e in WGET_PATHS.items():
        path = os.path.join(LIBATRON_DL_PATH, k)
        if os.path.exists(path):
            continue
        execcmd(["wget", e, "-O", path])

wget_all()

rm_stuff([PROFAN_PATH, LIBATRON_OUT_PATH, LIBATRON_LOG_PATH, LIBATRON_TOCP_FILE])

os.environ["PROFANOS_KIND"]  = "1"
os.environ["PROFANOS_OPTIM"] = "2"
os.environ["LIBATRON_DL_PATH"] = os.path.abspath(LIBATRON_DL_PATH)
os.environ["LIBATRON_OUT_PATH"] = os.path.abspath(LIBATRON_OUT_PATH)
os.environ["PROFAN_PATH"] = os.path.abspath(PROFAN_PATH)
os.environ["LIBATRON_TOCP_FILE"] = os.path.abspath(LIBATRON_TOCP_FILE)

execcmd(["mkdir", "-p", os.path.dirname(PROFAN_PATH)])
execcmd(["tar", "-xf", os.path.join(LIBATRON_DL_PATH, "profanOS.tar.gz")])
execcmd(["mv", "profanOS-main", PROFAN_PATH])

# copy lib to build with profanOS
for e in stuff_in_dir("lib", os.path.isdir):
    execcmd(["cp", "-r", e, os.path.join(PROFAN_PATH, "zlibs")])

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
execcmd(["make", "-C", PROFAN_PATH, "disk"], etcmsg="make -C profanOS disk // build extra libraries")

# cross compile stuff
execcmd(["mkdir", "-p", LIBATRON_OUT_PATH, LIBATRON_LOG_PATH])
execcmd(["touch", LIBATRON_TOCP_FILE])

def compile_bils():
    print(end = "\033[s")

    class Bil:
        STATUS_WATING  = 0
        STATUS_INBUILD = 1
        STATUS_ERROR   = 2
        STATUS_SUCCES  = 3
    
        def __init__(self, name, deps = []):
            self.name = name
            self.deps = deps
            self.status = Bil.STATUS_WATING

    def build_bil(bil: Bil):
        bil.status = Bil.STATUS_INBUILD
        
        logfile = os.open(os.path.join(LIBATRON_LOG_PATH, f"{bil.name}.txt"), os.O_WRONLY | os.O_CREAT)
        if logfile == -1:
            fatal(f"failed to create logfile for {bil.name}")
        result = subprocess.run(["bash", "-e", "build.sh"], cwd=os.path.join("bil", bil.name), stdout=logfile, stderr=subprocess.STDOUT)
        os.write(logfile, f"\n{'=' * 60}\nbuild.sh exit with code {result.returncode}\n".encode("utf-8"))
        os.close(logfile)

        if result.returncode:
            bil.status = Bil.STATUS_ERROR
        else:
            bil.status = Bil.STATUS_SUCCES
        
    bils = [
        Bil("aledlang",   []),
        Bil("binutils",   ["openlibm"]),
        Bil("dash"),
        Bil("es"),
        Bil("gcc",        ["openlibm"]),
        Bil("jpeg"),
        Bil("libarchive"),
        Bil("libpng",     ["openlibm"]),
        Bil("libsdl2",    ["openlibm"]),
        Bil("libxml2",    ["openlibm"]),
        Bil("limine"),
        Bil("make"),
        Bil("nasm"),
        Bil("openlibm"),
        Bil("openssl"),
        Bil("perl",       ["openlibm"]),
        Bil("python",     ["openlibm"]),
    ]

    def draw_state():
        bar = "=" * 22
        print(f"\033[u{bar}")
        strstat = ""
        for e in bils:
            if e.status == Bil.STATUS_ERROR:
                strstat = "\033[101merror"
            elif e.status == Bil.STATUS_INBUILD:
                strstat = "\033[96mrunning"
            elif e.status == Bil.STATUS_WATING:
                strstat = "\033[93mwait"
            elif e.status == Bil.STATUS_SUCCES:
                strstat = "\033[92mdone!"
            else:
                strstat = "?"

            print(f"{e.name:15}{strstat}\033[0m    ")

        print(bar)


    def are_build_running():
        return any(e.status == Bil.STATUS_INBUILD for e in bils)

    while todo := [e for e in bils if e.status == Bil.STATUS_WATING]:
        buildable = []

        for t in todo:
            for dep in t.deps:
                if dep not in [e.name for e in bils]:
                    fatal(f"unknow dependency {dep}")
                if dep in [e.name for e in bils if e.status != Bil.STATUS_SUCCES]:
                    break
            else:
                buildable.append(t)

        if not buildable:
            if are_build_running():
                draw_state()
                time.sleep(0.2)
                continue

            fatal(f"dependencies {[e.name for e in todo]} cant be build...")

        for bil in buildable:
            threading.Thread(target = build_bil, args=(bil,)).start()

    while are_build_running():
        draw_state()
        time.sleep(0.2)

    draw_state()


compile_bils()

# copy shared libraries to profanOS directory
for lib in stuff_in_dir(LIBATRON_OUT_PATH, os.path.isfile):
    execcmd(["cp", lib, os.path.join(PROFAN_PATH, "out/zlibs/")])

# copy commands to profanOS directory
for cmd in os.listdir("cmd"):
    execcmd(["cp", "-r", os.path.join("cmd", cmd), os.path.join(PROFAN_PATH, "zapps/c/")])

# make disk with extra commands
execcmd(["make", "-C", PROFAN_PATH, "disk"], etcmsg="make -C profanOS disk // build extra commands")

# ar all libraries in profanOS directory
for lib in stuff_in_dir(
    os.path.join(PROFAN_PATH, "out/zlibs/"),
    lambda path: os.path.isdir(path) and os.path.basename(path).startswith("lib"),
):
    objects = []
    for root, _, files in os.walk(lib):
        objects.extend(
            os.path.join(root, filename)
            for filename in files
            if filename.endswith(".o")
        )

    archive = os.path.join(LIBATRON_OUT_PATH, os.path.basename(lib) + ".a")
    execcmd(["ar", "-rcs", archive] + objects, etcmsg=f"ar {lib}")

for lib in stuff_in_dir(
    os.path.join(PROFAN_PATH, "out/zlibs/"),
    lambda path: os.path.isfile(path) and path.endswith(".so"),
):
    execcmd(["cp", lib, LIBATRON_OUT_PATH])

# copy compiled commands to build directory
with open(LIBATRON_TOCP_FILE, encoding="utf-8") as tocp_file:
    commands = [
        name for name in os.listdir("cmd") if not name.startswith(".")
    ] + tocp_file.read().split()

for cmd in commands:
    name = os.path.basename(cmd)
    if name.endswith(".c"):
        name = name[:-2]
    execcmd(["cp", os.path.join(PROFAN_PATH ,"out/zapps/c", name + ".elf"), LIBATRON_OUT_PATH])

# tar all headers in profanOS directory
headers_dir = os.path.join(PROFAN_PATH, "include/zlibs")
headers = [name for name in os.listdir(headers_dir) if not name.startswith(".")]
execcmd([
    "tar",
    "--mtime=UTC 2026-01-01",
    "--sort=name",
    "--owner=0",
    "--group=0",
    "--numeric-owner",
    "-czf",
    os.path.join(LIBATRON_OUT_PATH, "profanOS_headers.tar.gz"),
    "-C",
    headers_dir,
] + headers)

build_files = os.listdir(LIBATRON_OUT_PATH)
print("\n".join(build_files))
print(len(build_files))

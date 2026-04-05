import os, sys

profan_path = "../../profanOS"
if sys.argv[1:]:
    profan_path = sys.argv[1]
if not os.path.exists(profan_path):
    print(f"path {profan_path} does not exist")
    exit(1)

CC      = "gcc"
LD      = "ld"

OUTPUT  = "dash"

CFLAGS  = "-m32 -ffreestanding -fno-exceptions -nostdinc -fno-stack-protector -O3 -fno-omit-frame-pointer "
CFLAGS += f"-Isrc -Ilocal -include config.h -DSHELL -DJOBS=0 -I {profan_path}/include/zlibs"

LDFLAGS = f"-nostdlib -T {profan_path}/tools/link_elf.ld -L{profan_path}/out/zlibs -lc"

OBJDIR  = "build"
SRCDIR  = ["src", "src/bltin"]

def execute_command(cmd):
    print(cmd)
    rcode = os.system(cmd)
    if rcode == 0: return
    print(f"Command failed with exit code {rcode}")
    exit(rcode if rcode < 256 else 1)

def compile_file(src, dir):
    obj = os.path.join(OBJDIR, f"{os.path.splitext(src)[0]}.o")
    cmd = f"{CC} -c {os.path.join(dir, src)} -o {obj} {CFLAGS}"
    execute_command(cmd)
    return obj

def link_files(entry, objs, output = OUTPUT):
    execute_command(f"{LD} {LDFLAGS} -o {output}.elf {entry} {' '.join(objs)}")

def main():
    execute_command(f"mkdir -p {OBJDIR}")

    objs = []
    for dir in SRCDIR:
        for file in os.listdir(dir):
            if file.endswith(".c"):
                objs.append(compile_file(file, dir))

    objs.append(compile_file("bordel.c", "."))
    entry = compile_file("entry_elf.c", f"{profan_path}/tools")

    link_files(entry, objs)

if __name__ == "__main__":
    main()

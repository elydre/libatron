#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <inttypes.h>
#include <dirent.h>
#include <fcntl.h>

#include <modules/filesys.h>
#include <profan/syscall.h>
#include <profan.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

void _exit(int a) {
    exit(a);
}

/*
struct stat64 {
    dev_t     st_dev;      // Périphérique
    ino64_t   st_ino;      // Numéro i-nœud
    mode_t    st_mode;     // Protection
    nlink_t   st_nlink;    // Nb liens matériels
    uid_t     st_uid;      // UID propriétaire
    gid_t     st_gid;      // GID propriétaire
    dev_t     st_rdev;     // Type périphérique
    off64_t   st_size;     // Taille totale en octets
    blksize_t st_blksize;  // Taille de bloc pour E/S
    blkcnt64_t  st_blocks; // Nombre de blocs de 512B alloué
    time_t    st_atime;    // Heure dernier accès
    time_t    st_mtime;    // Heure dernière modification
    time_t    st_ctime;    // Heure dernier changement état
};
*/

int stat64(const char *path, struct stat64 *buf) {
    // serial_debug("OK stat64(%s)\n", path);

    buf->st_dev = 0;
    buf->st_ino = 0;
    buf->st_mode = 0;
    buf->st_nlink = 0;
    buf->st_uid = 0;
    buf->st_gid = 0;
    buf->st_rdev = 0;
    buf->st_size = 0;
    buf->st_blksize = 0;
    buf->st_blocks = 0;
    buf->st_atime = 0;
    buf->st_mtime = 0;
    buf->st_ctime = 0;

    char *pwd = getenv("PWD");
    if (pwd == NULL) pwd = "/";
    char *full_path = profan_path_join(pwd, (char *) path);

    uint32_t sid = fu_path_to_sid(SID_ROOT, full_path);
    free(full_path);

    if (IS_SID_NULL(sid)) {
        errno = ENOENT;
        return -1;
    }

    buf->st_dev = SID_DISK(sid);
    
    if (fu_is_file(sid)) {
        buf->st_mode = S_IFREG;
    } else if (fu_is_dir(sid)) {
        buf->st_mode = S_IFDIR;
    } else {
        buf->st_mode = S_IFLNK;
    }
    buf->st_mode |= 00777;

    buf->st_size = syscall_fs_get_size(sid);
    buf->st_blksize = 512;
    buf->st_blocks = (buf->st_size + 511) / 512;

    return 0;    
}

// pid_t wait3(int *status, int options, struct rusage *rusage) {
//     printf("wait3(%d)\n", options);
//     return 0;
// }

int fstat64(int fd, struct stat64 *buf) {
    printf("fstat64(%d)\n", fd);
    return 0;
}

int setrlimit(int resource, const struct rlimit *rlim) {
    printf("setrlimit(%d)\n", resource);
    return 0;
}

int lstat64(const char *path, struct stat64 *buf) {
    printf("lstat64(%s)\n", path);
    return 0;
}

// @LINK SHARED: libz

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#define CHUNK_SIZE 16384

char *get_dest_filename(const char *source, int compress) {
    char *dest = malloc(strlen(source) + 6);
    strcpy(dest, source);

    if (compress) {
        strcat(dest, ".gz");
        return dest;
    }

    char *ext = strrchr(dest, '.');
    if (ext && strcmp(ext, ".gz") == 0) {
        *ext = '\0';
        return dest;
    }

    strcat(dest, ".out"); 
    return dest;
}

int compress_fd(FILE *in, FILE *out) {
    int ret;
    unsigned char inbuf[CHUNK_SIZE];
    unsigned char outbuf[CHUNK_SIZE];
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    ret = deflateInit(&strm, Z_DEFAULT_COMPRESSION);
    if (ret != Z_OK) {
        fprintf(stderr, "gzip: deflateInit failed\n");
        return ret;
    }

    do {
        strm.avail_in = fread(inbuf, 1, CHUNK_SIZE, in);
        if (ferror(in)) {
            deflateEnd(&strm);
            fprintf(stderr, "gzip: fread failed\n");
            return Z_ERRNO;
        }
        strm.next_in = inbuf;

        do {
            strm.avail_out = CHUNK_SIZE;
            strm.next_out = outbuf;
            ret = deflate(&strm, feof(in) ? Z_FINISH : Z_NO_FLUSH);
            if (ret == Z_STREAM_ERROR) {
                deflateEnd(&strm);
                fprintf(stderr, "gzip: deflate failed\n");
                return ret;
            }
            if (fwrite(outbuf, 1, CHUNK_SIZE - strm.avail_out, out) != CHUNK_SIZE - strm.avail_out || ferror(out)) {
                deflateEnd(&strm);
                fprintf(stderr, "gzip: fwrite failed\n");
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);
    } while (!feof(in));

    deflateEnd(&strm);
    return Z_OK;
}

int compress_file(const char *source) {
    char *dest = get_dest_filename(source, 1);

    FILE *source_file = fopen(source, "rb");
    if (!source_file) {
        free(dest);
        fprintf(stderr, "gzip: %s: No such file or directory\n", source);
        return 1;
    }

    FILE *dest_file = fopen(dest, "wb");
    if (!dest_file) {
        fclose(source_file);
        free(dest);
        fprintf(stderr, "gzip: %s: Failed to open file\n", dest);
        return 1;
    }

    fwrite("\x1f\x8b", 1, 2, dest_file);

    int ret = compress_fd(source_file, dest_file) != Z_OK;

    fclose(source_file);
    fclose(dest_file);
    free(dest);

    return ret;
}

int decompress_fd(FILE *in, FILE *out) {
    int ret;
    unsigned char inbuf[CHUNK_SIZE];
    unsigned char outbuf[CHUNK_SIZE];
    z_stream strm;

    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit(&strm);
    if (ret != Z_OK) {
        fprintf(stderr, "gzip: inflateInit failed\n");
        return ret;
    }

    do {
        strm.avail_in = fread(inbuf, 1, CHUNK_SIZE, in);
        if (ferror(in)) {
            inflateEnd(&strm);
            fprintf(stderr, "gzip: fread failed\n");
            return Z_ERRNO;
        }
        if (strm.avail_in == 0) break;
        strm.next_in = inbuf;

        do {
            strm.avail_out = CHUNK_SIZE;
            strm.next_out = outbuf;
            ret = inflate(&strm, Z_NO_FLUSH);
            if (ret == Z_STREAM_ERROR) {
                inflateEnd(&strm);
                fprintf(stderr, "gzip: inflate failed\n");
                return ret;
            }
            if (fwrite(outbuf, 1, CHUNK_SIZE - strm.avail_out, out) != CHUNK_SIZE - strm.avail_out || ferror(out)) {
                inflateEnd(&strm);
                fprintf(stderr, "gzip: fwrite failed\n");
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);
    } while (ret != Z_STREAM_END);

    inflateEnd(&strm);
    return Z_OK;
}

int is_fd_gzip(FILE *file) {
    unsigned char header[2];
    if (fread(header, 1, 2, file) != 2) return 0;
    return header[0] == 0x1f && header[1] == 0x8b;
}

int decompress_file(const char *source) {
    char *dest = get_dest_filename(source, 0);
    int ret;

    FILE *source_file = fopen(source, "rb");
    if (!source_file) {
        free(dest);
        fprintf(stderr, "gzip: %s: No such file or directory\n", source);
        return 1;
    }

    if (!is_fd_gzip(source_file)) {
        fclose(source_file);
        free(dest);
        fprintf(stderr, "gzip: %s: Not in gzip format\n", source);
        return 1;
    }

    FILE *dest_file = fopen(dest, "wb");
    if (!dest_file) {
        fclose(source_file);
        free(dest);
        fprintf(stderr, "gzip: %s: Failed to open file\n", dest);
        return 1;
    }

    ret = decompress_fd(source_file, dest_file) != Z_OK;

    fclose(source_file);
    fclose(dest_file);
    free(dest);

    return ret;
}

typedef struct {
    uint8_t compress;
    uint8_t keep;
    uint8_t help;
    int arg_offset;
} gzip_args_t;

void print_help(int full) {
    puts("Usage: gzip [options] <file1> [file2 ...]");

    if (!full) {
        puts("Try 'gzip -h' for more information.");
        return;
    }

    puts(
        "Options:\n"
        "  -d  decompress files\n"
        "  -k  keep original files\n"
        "  -h  display this help message"
    );
}

gzip_args_t *parse_args(int argc, char **argv) {
    gzip_args_t *args = malloc(sizeof(gzip_args_t));
    args->compress = 1;
    args->keep = 0;
    args->help = 0;
    args->arg_offset = 1;

    if (argc == 1) {
        args->help = 1;
        return args;
    }

    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-' && argv[i][1] != '\0') {
            if (strcmp(argv[i], "-d") == 0) {
                args->compress = 0;
            } else if (strcmp(argv[i], "-k") == 0) {
                args->keep = 1;
            } else if (strcmp(argv[i], "-h") == 0) {
                args->help = 1;
            } else {
                fprintf(stderr, "gzip: invalid option -- '%s'\n", argv[i]);
                args->help = 1;
            }
        } else {
            args->arg_offset = i;
            break;
        }
    }

    return args;
}

int main(int argc, char **argv) {
    gzip_args_t *args = parse_args(argc, argv);
    int ret = 0;

    if (args->help) {
        ret = args->arg_offset == 1;
        print_help(!ret);
        free(args);
        return ret;
    }

    for (int i = args->arg_offset; i < argc; i++) {
        if ((ret = ((args->compress) ? compress_file : decompress_file)(argv[i]))) break;
        if (!args->keep) unlink(argv[i]);
    }

    free(args);
    return ret;
}   

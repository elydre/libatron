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

int compress_file(const char *source) {
    char *dest = get_dest_filename(source, 1);
    int ret = 0;

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

    z_stream stream;
    memset(&stream, 0, sizeof(stream));

    if (deflateInit(&stream, Z_BEST_COMPRESSION) != Z_OK) {
        fclose(source_file);
        fclose(dest_file);
        free(dest);
        fprintf(stderr, "gzip: Failed to initialize compression stream\n");
        return 1;
    }

    uint8_t in_buffer[CHUNK_SIZE];
    uint8_t out_buffer[CHUNK_SIZE];

    stream.next_out = out_buffer;
    stream.avail_out = CHUNK_SIZE;

    do {
        stream.next_in = in_buffer;
        stream.avail_in = fread(in_buffer, 1, CHUNK_SIZE, source_file);
        if (deflate(&stream, feof(source_file) ? Z_FINISH : Z_NO_FLUSH) == Z_STREAM_ERROR) {
            fprintf(stderr, "gzip: Failed to compress data\n");
            ret = 1;
            break;
        }

        uint32_t have = CHUNK_SIZE - stream.avail_out;
        if (fwrite(out_buffer, 1, have, dest_file) != have) {
            fprintf(stderr, "gzip: Failed to write compressed data\n");
            ret = 1;
            break;
        }
    } while (stream.avail_out == 0);

    deflateEnd(&stream);
    fclose(source_file);
    fclose(dest_file);
    free(dest);

    return ret;
}

int decompress_file(const char *source) {
    char *dest = get_dest_filename(source, 0);
    int tmp, ret = 0;

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

    z_stream stream;
    memset(&stream, 0, sizeof(stream));

    if (inflateInit(&stream) != Z_OK) {
        fclose(source_file);
        fclose(dest_file);
        free(dest);
        fprintf(stderr, "gzip: Failed to initialize decompression stream\n");
        return 1;
    }

    uint8_t in_buffer[CHUNK_SIZE];
    uint8_t out_buffer[CHUNK_SIZE];

    stream.next_out = out_buffer;
    stream.avail_out = CHUNK_SIZE;

    do {
        stream.next_in = in_buffer;
        stream.avail_in = fread(in_buffer, 1, CHUNK_SIZE, source_file);

        if (stream.avail_in == 0)
            break;

        tmp = inflate(&stream, Z_NO_FLUSH);
        if (tmp == Z_NEED_DICT || tmp == Z_DATA_ERROR || tmp == Z_MEM_ERROR) {
            fprintf(stderr, "gzip: Failed to decompress data\n");
            ret = 1;
            break;
        }

        uint32_t have = CHUNK_SIZE - stream.avail_out;
        if (fwrite(out_buffer, 1, have, dest_file) != have) {
            fprintf(stderr, "gzip: Failed to write decompressed data\n");
            ret = 1;
            break;
        }
    } while (stream.avail_out == 0);

    inflateEnd(&stream);
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

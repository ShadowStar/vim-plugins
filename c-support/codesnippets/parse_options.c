#include <stdio.h>
#include <unistd.h>
#include <getopt.h>

static int parse_options(int argc, char *argv[])
{
    int ch;

    static struct option longopts[] = {
        { "version", no_argument, NULL, 'v' },
        { "help", no_argument, NULL, 'h' },
        { NULL, 0, NULL, 0 }
    };

    while ((ch = getopt_long(argc, argv, "-:vh", longopts, NULL)) != -1) {
        switch (ch) {
        case 'v':
            print_version();
            exit(0);
        case 'h':
            print_help();
            exit(0);
        case '?':
            dprintf(STDERR_FILENO, "Invalid option `-%c'\n", optopt);
            exit(-1);
        case ':':
            dprintf(STDERR_FILENO, "Missing option's argument `-%c'\n", optopt);
            exit(-1);
        case 1:
            dprintf(STDOUT_FILENO, "Undefined option `-%s'\n", optarg);
            break;
        }
    }
    return 0;
}


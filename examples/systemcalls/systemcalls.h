#include <stdio.h>
#include <stdbool.h>
#include <stdarg.h>
#include <errno.h> //for seeing error messages
#include <sys/wait.h> //exit status
#include <stdlib.h>
#include <fcntl.h> // for file io
#include <unistd.h>
#include <string.h>

bool do_system(const char *command);

bool do_exec(int count, ...);

bool do_exec_redirect(const char *outputfile, int count, ...);

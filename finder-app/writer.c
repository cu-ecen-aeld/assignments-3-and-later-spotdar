#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main (int argc, char *argv[])
{
    openlog(NULL,0,LOG_USER); // open a syslog with log_user facility

    if(argc != 3)
    {
        syslog(LOG_ERR,"Invalid number of arguments: %d expected 3",argc); //
        return 1;
    }

    const char *filepath = argv[1];
    const char *text_to_write = argv[2];

    //Open a file and overwrite contents if it already exists 
    FILE *fileptr = fopen(filepath,"w");
    if (fileptr == NULL)
    {
        syslog(LOG_ERR, "Error opening file \n");
        return 1;
    }
    //Write the passed string to the file
    fprintf(fileptr,"%s",text_to_write);
    syslog(LOG_DEBUG,"Writing %s to %s", text_to_write, filepath);

    //close file pointer
    fclose(fileptr);

    return 0;
}
#Defining the compiler used 
CC = gcc

#Defining the flags (all warnings, extra warnings, debug info)
CFLAGS = -Wall -Wextra -g 

#Define Target
TARGET = writer

#Define source
SRCS = writer.c
#Define object
OBJS = writer.o

#Default target
all: $(TARGET)

#Build Target executable
$(TARGET) : $(OBJS)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

#Build object file
$(OBJS) : $(SRCS)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c $(SRCS) -o $(OBJS)

#Clean
clean: 
	rm -rf $(OBJS) $(TARGET)

#Phony
.PHONY: all clean

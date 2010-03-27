  #include <sys/stat.h>
  #include <sys/types.h>
  #include <sys/fcntl.h>
  #include <sys/times.h>
  #include <sys/errno.h>
  #include <sys/time.h>
  #include <stdio.h>
  #include <errno.h>
  #undef errno
  extern int errno;
	
    void _exit(int code){
		unsigned int _errcode = code;
    asm("xorb %%ah, %%ah\n\t"
		"int $0x30"
		:
		: "b" (_errcode)
		);
    }

    int close(int file){
        return -1;
    }

    int execve(char *name, char **argv, char **env){
      asm("movb $14, %%ah\n\t"
	  "int $0x30"
	  :
	  : "S" (name)
	  : "%eax", "%ebx", "%ecx", "%edx", "%edi"
	  );
      return 0;
    }

    int fork() {
		int pid;
		asm("movb $11, %%ah\n\t"
			"xorl %%esi, %%esi\n\t"
			"int $0x30"
			: "=b" (pid)
			:
			: "%esi"
			);
		return pid;
    }

    int fstat(int file, struct stat *st) {
      st->st_mode = S_IFCHR;
      return 0;
    }

	int gettimeofday(struct timeval *p, void *z){
		asm("movb $12, %%ah\n\t"
			"int $0x30"
			: "=a" (p->tv_sec), "=c" (p->tv_usec)
			:
			: "%ebx"
			);
		return 0;
	}

    int getpid() {
		int pid;
		asm("movb $15, %%ah\n\t"
			"int $0x30"
			: "=d" (pid)
			:
			: "%eax", "%ebx", "%ecx", "%edi", "%esi"
			);
		return pid;
    }
	
	int getuid(){
		int uid;
		asm("movb $15, %%ah\n\t"
			"int $0x30"
			: "=b" (uid)
			:
			: "%eax", "%ecx", "%edx", "%edi", "%esi"
			);
		return uid;
	}

    int isatty(int file){
       return 1;
    }
	
    int kill(int pid, int sig){
      errno=EINVAL;
      return(-1);
    }

    int link(char *old, char *new){
      errno=EMLINK;
      return -1;
    }

    int lseek(int file, int ptr, int dir){
        return 0;
    }

    int _open(const char *name, int flags, int mode){
		return -1;
	}

    int read(int file, char *ptr, int len){
		int i = 0;
		if(file==0){
			    asm("movb $4, %%ah\n\t"
					"movb $10, %%al\n\t"
					"movb $7, %%bl\n\t"
					"int $0x30\n\t"
					"movb $10,%%al\n\t"
					"movb %%al, (%%esi)\n\t"
					"addl $1, %%esi\n\t"
					"xorb %%al, %%al\n\t"
					"movb %%al, (%%esi)\n\t"
					"addl $1, %%ecx"
					: "=c" (i)
					: "S" (ptr), "D" (ptr + len)
					: "%eax", "%ebx", "%edx"
					);
		}
		return i;
    }

    caddr_t sbrk(int incr){
      extern char end;		/* Defined by the linker */
      static char *heap_end;
      char *prev_heap_end;
     
      if (heap_end == 0) {
        heap_end = &end;
      }
      prev_heap_end = heap_end;
      heap_end += incr;
      return (caddr_t) prev_heap_end;
    }

    int _stat(char *file, struct stat *st) {
      st->st_mode = S_IFCHR;
      return 0;
    }
	
    int _times(struct tms *buf){
      return -1;
    }

    int unlink(char *name){
      errno=ENOENT;
      return -1; 
    }

    int wait(int *status) {
      errno=ECHILD;
      return -1;
    }

    int write(int file, char *ptr, int len){
		int i;
		asm("cli");
		if(file==1){
			for(i=1;i<len;i++){ //the i=1 instead of i=0 makes sure it is printed quietly
		        asm("movb $6, %%ah\n\t"
					"movb $7, %%bl\n\t"
					"movb %%bl, %%bh\n\t" 
					"int $0x30"
					:
					: "a" (*ptr++)
					: "%esi", "%edi", "%ebx", "%edx", "%ecx"
					);
			}
			asm("movb $6, %%ah\n\t"
				"movb $7, %%bl\n\t"
				"xorb %%bh, %%bh\n\t" 
				"int $0x30\n\t"
				:
				: "a" (*ptr++)
				: "%esi", "%edi", "%ebx", "%edx", "%ecx"
				);
		}
		if(file==2){
			for(i=1;i<len;i++){
		        asm("movb $6, %%ah\n\t"
					"movb $0xF0, %%bl\n\t"
					"movb %%bl, %%bh\n\t"
					"int $0x30"
					:
					: "a" (*ptr++)
					: "%esi", "%edi", "%ebx", "%edx", "%ecx"
					);
			}
		        asm("movb $6, %%ah\n\t"
					"movb $0xF0, %%bl\n\t"
					"xorb %%bh, %%bh\n\t"
					"int $0x30"
					:
					: "a" (*ptr++)
					: "%esi", "%edi", "%ebx", "%edx", "%ecx"
					);
		}
		asm("sti");
        return i;
    }

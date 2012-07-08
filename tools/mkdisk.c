/* Usage: mkdisk [boot] [system] [disk] 
 * Example: mkdisk boot.bin system.bin a.img
 * Time: 2012.6.30, by Jinfeng
 */
 
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>

int main(int argc, char * argv[])
{
	if(argc != 4){
		printf("Usage: %s [boot] [system] [disk]",argv[0]);
		exit(1);
	}
	
	char boot[512];
	char system[8196];
	
	int fd1 = open(argv[1], O_RDONLY);
	int fd2 = open(argv[2], O_RDONLY);
	int fd3 = open(argv[3], O_RDWR);
	
	if((fd1 == -1) || (fd2 == -1) || (fd3 == -1)){
		perror("Error open file");
		exit(1);
	}
	
	// write boot to disk's first sector
	int fd1read = read(fd1,boot,512);
	if((fd1read == -1) || (fd1read != 512)){
		perror("Error read boot");
		exit(1);
	}
	int fd3write = write(fd3,boot,512);
	if((fd3write == -1) || (fd3write != 512)){
		perror("Error write boot");
		exit(1);
	}
	printf("%d bytes have been written!\n",fd3write);
	
	// write system image to disk, skip first 512 bytes.
	int fd2read = read(fd2,system,8191);
	if(fd2read == -1){
		perror("Error read system");
		exit(1);
	}
	lseek(fd3,512,SEEK_SET);
	fd3write = write(fd3,system,fd2read);
	if((fd3write == -1) || (fd3write != fd2read)){
		perror("Error write system");
		exit(1);
	}
	printf("%d bytes have been written!\n",fd3write);
	
	close(fd1); close(fd2); close(fd3);
	
	return 0;
}
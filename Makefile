
CFLAGS += -O1 -Wall -g -pg -D_FILE_OFFSET_BITS=64 # -g -fstack-protector-all

all: pagecache-management.so sfr fadv pagecache-management-count-reads.so  pagecache-management-lazy200.so pagecache-management-nocount-reads.so

pagecache-management-nocount-reads.so: pagecache-management.so
	rm  pagecache-management-nocount-reads.so || true
	ln pagecache-management.so pagecache-management-nocount-reads.so

pagecache-management.so: pagecache-management.c
	$(CC) -g $(CFLAGS) -shared -fPIC pagecache-management.c -ldl -o pagecache-management.so

pagecache-management-count-reads.so: pagecache-management.c
	$(CC) -g $(CFLAGS) -shared -fPIC pagecache-management.c -ldl -o pagecache-management-count-reads.so -DCOUNT_READS
#sfr: sfr.o

pagecache-management-lazy200.so: pagecache-management.c
	$(CC) -g $(CFLAGS) -shared -fPIC pagecache-management.c -ldl -o pagecache-management-lazy200.so -DMAX_LAZY_CLOSE_FDS=200

#fadv: fadv.o
	
clean:
	$(RM) pagecache-management*.so *.o sfr fadv

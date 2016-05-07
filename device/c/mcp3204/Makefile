ifndef MAKEROOT
	export MAKEROOT:= $(shell path=`pwd`; until test -d $$path/.git; do path=$${path%/*}; done; echo $$path/device)
endif

include $(MAKEROOT)/mk/base.mk

TARGET = mcp3204

all:
	gcc main.c -L/usr/local/lib -lwiringPi -lrt -o $(TARGET)
	sudo chown root:root $(TARGET)
	sudo chmod u+s $(TARGET)

clean:
	rm -f *.o $(TARGET)

include ../makeinclude

all:

install:
	@ echo "Installing include files in $(IPREFIX)..."
	@ mkdir -p $(IPREFIX)
	@ rm -rf $(IPREFIX)/FLU
	@ mkdir -p $(IPREFIX)/FLU
	@ chmod 755 $(IPREFIX)/FLU
	@ cp *.h $(IPREFIX)/FLU
	@ chmod 644 $(IPREFIX)/FLU/*.h

uninstall:
	@ echo "Uninstalling include files from $(IPREFIX)..."
	@ rm -rf $(IPREFIX)/FLU


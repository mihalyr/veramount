# Installs the scripts for veramount
SHELL=/bin/sh

# Hardcoding paths as scripts have hardocded too
# Where scripts go
BINDIR=/usr/local/sbin
# Where template files go
SHAREDIR=/usr/local/share/veramount
# Config file location
CONFIGDIR=/etc/veramount.d

# Executable files
SRCBINFILES=$(srcdir)/sbin/veramount $(scrdir)/sbin/veramount-config

.SUFFIXES:
.PHONY: install uninstall purge

install:
	@echo "Installing veramount"
	@mkdir -vp $(SHAREDIR)
	@mkdir -vp $(CONFIGDIR)
	@install -v -m 755 sbin/* $(BINDIR)
	@install -v -m 644 share/* $(SHAREDIR)
	@echo "Done"

uninstall:
	@echo "Disabling all configs"
	@$(BINDIR)/veramount-config disable --name all
	@echo "Uninstalling veramount"
	@rm -vf $(BINDIR)/veramount
	@rm -vf $(BINDIR)/veramount-config
	@rm -vrf $(SHAREDIR)
	@echo "Done"

purge: uninstall
	@echo "Deleting configs"
	@rm -rvf $(CONFIGDIR)
	@echo "Done"


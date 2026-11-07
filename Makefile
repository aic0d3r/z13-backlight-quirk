# The module list lives in Kbuild; DKMS passes KERNELRELEASE, so no ifneq trick here.
KDIR ?= /lib/modules/$(shell uname -r)/build
# CachyOS kernels are built with clang; the module must use the same toolchain.
LLVM_FLAG := $(if $(shell grep -s '^CONFIG_CC_IS_CLANG=y' $(KDIR)/.config),LLVM=1)
all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) $(LLVM_FLAG) modules
clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean

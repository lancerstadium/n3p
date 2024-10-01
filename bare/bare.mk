BARE_DIR 	:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BARE_SRC	:= $(wildcard $(BARE_DIR)/*.c)

ifdef PROG
PROG_C		:= $(PROG).c
endif
ARCH		?= rv32imc
SRCS 		:= $(BARE_SRC) $(PROG_C)
INCS		:= -I$(BARE_DIR)
C_SRCS 		= $(filter %.c, $(SRCS))
ASM_SRCS 	= $(filter %.S, $(SRCS))
CPLUSPLUS 	= $(filter %.cpp $(SRCS))

CC 			:= riscv32-unknown-elf-gcc
CROSS_COMPILE = $(patsubst %-gcc,%-,$(CC))
OBJCOPY 	?= $(CROSS_COMPILE)objcopy
OBJDUMP 	?= $(CROSS_COMPILE)objdump
LINK_SCRIPT ?= $(BARE_DIR)/link.ld
CRT 		?= $(COMMON_DIR)/crt0.S
CFLAGS 		?= -march=$(ARCH) -mabi=ilp32 -static -mcmodel=medany -Wall -g -O3 -fvisibility=hidden -nostartfiles -ffreestanding $(PROG_CFLAGS)
OBJS 		:= ${C_SRCS:.c=.o} ${ASM_SRCS:.S=.o} ${CRT:.S=.o}
DEPS 		:= $(OBJS:%.o=%.d)
ifdef PROG
TRGS 		:= $(PROG).elf $(PROG).vmem $(PROG).bin
else
TRGS 		:= $(OBJS)
endif

all: $(TRGS)

ifdef PROG
$(PROG).elf: $(OBJS) $(LINK_SCRIPT)
	$(CC) $(CFLAGS) -T $(LINK_SCRIPT) $(OBJS) -o $@ $(LIBS)

.PHONY: disassemble
disassemble: $(PROG).dis
endif

%.dis: %.elf
	$(OBJDUMP) -fhSD $^ > $@

%.vmem: %.bin
	srec_cat $^ -binary -offset 0x0000 -byte-swap 4 -o $@ -vmem

%.bin: %.elf
	$(OBJCOPY) -O binary $^ $@

%.o: %.c
	$(CC) $(CFLAGS) -MMD -c $(INCS) -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -MMD -c $(INCS) -o $@ $<

clean:
	$(RM) -f $(OBJS) $(DEPS)

distclean: clean
	$(RM) -f $(TRGS)
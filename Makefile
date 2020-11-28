TARGET:=USBHost_FatFs
# TODO change to your ARM gcc toolchain path
TOOLCHAIN_ROOT:=/usr/local
TOOLCHAIN_PATH:=$(TOOLCHAIN_ROOT)/bin
TOOLCHAIN_PREFIX:=arm-none-eabi

# Optimization level, can be [0, 1, 2, 3, s].
OPTLVL:=0
DBG:=-g

STARTUP:=$(CURDIR)/Core/Startup
LINKER_SCRIPT:=$(CURDIR)/STM32F407VGTX_FLASH.ld

INCLUDE+=-I$(CURDIR)/Core/Inc
INCLUDE+=-I$(CURDIR)/FATFS/App
INCLUDE+=-I$(CURDIR)/FATFS/Target
INCLUDE+=-I$(CURDIR)/USB_HOST/App
INCLUDE+=-I$(CURDIR)/USB_HOST/Target
INCLUDE+=-I$(CURDIR)/Drivers/CMSIS/Device/ST/STM32F4xx/Include
INCLUDE+=-I$(CURDIR)/Drivers/CMSIS/Include
INCLUDE+=-I$(CURDIR)/Drivers/STM32F4xx_HAL_Driver/Inc
INCLUDE+=-I$(CURDIR)/Middlewares/ST/STM32_USB_HOST_Library/Core/Inc
INCLUDE+=-I$(CURDIR)/Middlewares/ST/STM32_USB_HOST_Library/Class/MSC/Inc
INCLUDE+=-I$(CURDIR)/Middlewares/Third_Party/FatFs/src

BUILD_DIR = $(CURDIR)/build
BIN_DIR = $(CURDIR)/binary

# オブジェクトファイルをソースファイルと同じディレクトリではなくカレントディレクトリに
# 書き込むためにvpathを使用する
vpath %.c $(CURDIR)/Core/Src \
	$(CURDIR)/FATFS/App $(CURDIR)/FATFS/Target \
	$(CURDIR)/USB_HOST/App $(CURDIR)/USB_HOST/Target \
	$(CURDIR)/Drivers/CMSIS/Device/ST/STM32F4xx/Include \
	$(CURDIR)/Drivers/CMSIS/Include \
	$(CURDIR)/Drivers/STM32F4xx_HAL_Driver/Src \
	$(CURDIR)/Middlewares/ST/STM32_USB_Host_Library/Core/Src \
	$(CURDIR)/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src \
	$(CURDIR)/Middlewares/Third_Party/FatFs/src \
	$(CURDIR)/Middlewares/Third_Party/FatFs/src/option \

vpath %.s $(STARTUP)
ASRC=startup_stm32f407vgtx.s

# Project Source Files
# Core/Src
SRC+=stm32f4xx_it.c
SRC+=system_stm32f4xx.c
SRC+=stm32f4xx_hal_msp.c
SRC+=main.c
SRC+=File_Handling.c
SRC+=syscalls.c
SRC+=sysmem.c
# FATFS
SRC+=fatfs.c
SRC+=usbh_diskio.c
# USB_HOST
SRC+=usb_host.c
SRC+=usbh_platform.c
SRC+=usbh_conf.c
# USB_Host Library
SRC+=usbh_ioreq.c
SRC+=usbh_pipes.c
SRC+=usbh_core.c
SRC+=usbh_ctlreq.c
# USB Class MSC
SRC+=usbh_msc.c
SRC+=usbh_msc_bot.c
SRC+=usbh_msc_scsi.c
# FatFs Library
SRC+=ff.c
SRC+=ff_gen_drv.c
SRC+=diskio.c
SRC+=ccsbcs.c
SRC+=syscall.c
# HAL
SRC+=stm32f4xx_hal_tim.c
SRC+=stm32f4xx_hal_flash.c
SRC+=stm32f4xx_hal_uart.c
SRC+=stm32f4xx_hal_exti.c
SRC+=stm32f4xx_hal_flash_ex.c
SRC+=stm32f4xx_ll_usb.c
SRC+=stm32f4xx_hal_rcc.c
SRC+=stm32f4xx_hal_rcc_ex.c
SRC+=stm32f4xx_hal_pwr.c
SRC+=stm32f4xx_hal_cortex.c
SRC+=stm32f4xx_hal_dma_ex.c
SRC+=stm32f4xx_hal_pwr_ex.c
SRC+=stm32f4xx_hal_dma.c
SRC+=stm32f4xx_hal.c
SRC+=stm32f4xx_hal_flash_ramfunc.c
SRC+=stm32f4xx_hal_hcd.c
SRC+=stm32f4xx_hal_tim_ex.c
SRC+=stm32f4xx_hal_gpio.c


CDEFS+=-DSTM32F4XX
CDEFS+=-DSTM32F407xx
CDEFS+=-DSTM32F407VG
CDEFS+=-DHSE_VALUE=8000000
CDEFS+=-DARM_MATH_CM4

MCUFLAGS=-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant -finline-functions -Wdouble-promotion -std=gnu99
COMMONFLAGS=-O$(OPTLVL) $(DBG) -Wall -ffunction-sections -fdata-sections
CFLAGS=$(COMMONFLAGS) $(MCUFLAGS) $(INCLUDE) $(CDEFS)

LDLIBS=-lm -lc -lgcc
LDFLAGS=$(MCUFLAGS) -u _scanf_float -u _printf_float -fno-exceptions -Wl,--gc-sections,-T$(LINKER_SCRIPT),-Map,$(BIN_DIR)/$(TARGET).map

CC=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-gcc
LD=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-gcc
OBJCOPY=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-objcopy
AS=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-as
AR=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-ar
GDB=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-gdb

OBJ = $(SRC:%.c=$(BUILD_DIR)/%.o)

$(BUILD_DIR)/%.o: %.c
	@echo [CC] $(notdir $<)
	@$(CC) $(CFLAGS) $< -c -o $@

all: $(OBJ)
	@echo [AS] $(ASRC)
	@$(AS) -o $(ASRC:%.s=$(BUILD_DIR)/%.o) $(STARTUP)/$(ASRC)
	@echo [LD] $(TARGET).elf
	@$(CC) -o $(BIN_DIR)/$(TARGET).elf $(LDFLAGS) $(OBJ) $(ASRC:%.s=$(BUILD_DIR)/%.o) $(LDLIBS)
	@echo [HEX] $(TARGET).hex
	@$(OBJCOPY) -O ihex $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).hex
	@echo [BIN] $(TARGET).bin
	@$(OBJCOPY) -O binary $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).bin

.PHONY: clean

clean:
	@echo [RM] OBJ
	@rm -f $(OBJ)
	@rm -f $(ASRC:%.s=$(BUILD_DIR)/%.o)
	@echo [RM] BIN
	@rm -f $(BIN_DIR)/$(TARGET).elf
	@rm -f $(BIN_DIR)/$(TARGET).hex
	@rm -f $(BIN_DIR)/$(TARGET).bin

flash:
	@st-flash write $(BIN_DIR)/$(TARGET).bin 0x8000000

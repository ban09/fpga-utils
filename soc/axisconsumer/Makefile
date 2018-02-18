VIVADO_DIR=C:/Xilinx/Vivado/2017.4
VIVADO=$(VIVADO_DIR)/bin/vivado

IP_NAME=axisconsumer

all: package_project

package_project:
	$(VIVADO) -mode tcl -source package_ip.tcl

.PHONY: clean 
clean:
	rm -f *.log *.jou *.xpr *~ 
	rm -rf $(IP_NAME).* .Xil xgui
clean_all:
	rm -f component.xml 
	

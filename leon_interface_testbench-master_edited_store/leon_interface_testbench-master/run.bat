del memfile0
del memfile1
del vsim.wlf
vsim -c -do run_tb.do
vsim -view vsim.wlf -do wave.do
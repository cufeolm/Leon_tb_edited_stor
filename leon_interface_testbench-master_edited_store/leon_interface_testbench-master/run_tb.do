vlog GUVM_bfm_leon.sv;
vlog top.sv
vsim top 

set NoQuitOnFinish 1
onbreak {resume}

log /* -r

run -all

#mem list top/dut/rf0/inf/u0/rfss -r
mem display top/dut/rf0/inf/u0/rfss/u0/rfd
#mem display top/dut/rf0/inf/u0/rfss/u1/rfd
mem save -format mti -outfile memfile0 top/dut/rf0/inf/u0/rfss/u0/rfd
mem save -format mti -outfile memfile1 top/dut/rf0/inf/u0/rfss/u1/rfd

quit
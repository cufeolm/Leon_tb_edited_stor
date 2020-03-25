# do wave2.do
#if [file exists "work"] {vdel -all}
#vlib work
#vcom -f DUT.f
#vcom [glob *.vhd ]

vsim proc

add wave -r /*

####################### forcing values ##################
# forcing clock and reset
#force -freeze sim:/proc/clk 1 0, 0 {500 ns} -r {1 us}
#force -freeze sim:/proc/rst 1 1us
#force -freeze sim:/proc/rst 0 2us




############################################################
force -freeze sim:/proc/clk 1 0, 0 {500 ns} -r 1us
force -freeze sim:/proc/rst 1 0us
#force -freeze sim:/proc/rst 0 2us
#force -freeze sim:/proc/rst 1 10us
force -freeze sim:/proc/pciclk 0 0
force -freeze sim:/proc/pcirst 0 0
force -freeze sim:/proc/iui.irl(3) 0 0
force -freeze sim:/proc/iui.irl(2) 0 0
force -freeze sim:/proc/iui.irl(1) 0 0
force -freeze sim:/proc/iui.irl(0) 0 0
force -freeze sim:/proc/ico.exception 0 0
force -freeze sim:/proc/ico.hold 1 0
force -freeze sim:/proc/ico.flush 0 0
force -freeze sim:/proc/ico.diagrdy 0 0
force -freeze sim:/proc/ico.mds 0 0
force -freeze sim:/proc/ico.data 32'h8E00C002 0
force -freeze sim:/proc/ico.diagdata 32'h00000000 0
force -freeze sim:/proc/dco.data 32'h13 0
force -freeze sim:/proc/dco.icdiag.addr 32'h0 0
force -freeze sim:/proc/dco.icdiag.enable 0 0
force -freeze sim:/proc/dco.icdiag.read 0 0
force -freeze sim:/proc/dco.icdiag.tag 0 0
force -freeze sim:/proc/dco.icdiag.flush 0 0
force -freeze sim:/proc/dco.mexc 0 0
force -freeze sim:/proc/dco.hold 1 0
force -freeze sim:/proc/dco.mds 0 0
force -freeze sim:/proc/dco.werr 0 0
#####

force -freeze sim:/proc/rf0/inf/u0/rfss/u1/rfd(2) 32'h5 0
force -freeze sim:/proc/rf0/inf/u0/rfss/u1/rfd(3) 32'h5 0
force -freeze sim:/proc/rf0/inf/u0/rfss/u1/rfd(130) 32'h5 0
force -freeze sim:/proc/rf0/inf/u0/rfss/u1/rfd(131) 32'h6 0
force -freeze sim:/proc/rf0/inf/u0/rfss/u0/rfd(130) 32'h7 0
force -freeze sim:/proc/rf0/inf/u0/rfss/u0/rfd(131) 32'h8 0

###########habd



#force -freeze sim:/proc/clko.holdn 1 0

#quit

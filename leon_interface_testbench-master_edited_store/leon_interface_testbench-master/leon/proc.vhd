
----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	proc
-- File:	proc.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	This unit contains the integer unit, cache memory,
--		clock/reset generation and (optinally) FPU.
------------------------------------------------------------------------------
-- Version control:
-- 11-9-1998:	First implemetation
-- 26-9-1999:	Release 1.0
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use work.target.all;
use work.config.all;
use work.iface.all;
use work.amba.all;------------
use work.fpulib.all;------------
use work.tech_map.all;

entity proc is
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;

    pciclk : in  std_logic;
    pcirst : in  std_logic;
   -- clki   : out clkgen_in_type;
   -- clko   : in  clkgen_out_type;--VERY IMPORTANT
   -- apbi   : in  apb_slv_in_type;----------
   -- apbo   : out apb_slv_out_type;----------
   -- ahbi   : in  ahb_mst_in_type;----------
   -- ahbo   : out ahb_mst_out_type;------
    
    iui    : in  iu_in_type;
    iuo    : out iu_out_type;
    --cache sig
    ici    : out icache_in_type;		-- icache input
    ico    : in  icache_out_type;		-- icache output
    dci    : out dcache_in_type;		-- dcache input
    dco    : in  dcache_out_type		-- dcache output
  );
end; 

architecture rtl of proc is

component clkgen 
port (
    clk    : in  std_logic;
    pciclk : in  std_logic;
    clki   : in  clkgen_in_type;
    clko   : out clkgen_out_type
);
end component;

component rstgen 
port (
    resetn : in  std_logic;
    pcirst : in  std_logic;
    clk    : in  clk_type;
    rst    : out rst_type
);
end component;

signal rst_t   : rst_type;
signal clko  : clkgen_out_type;
signal clki  : clkgen_in_type;
--signal pcirst :  std_logic;
--signal pciclk :  std_logic;

component iu
port (
    rst    : in std_logic;
    rclk   : in  clk_type;		
    rclkn  : in  clk_type;		
    clk    : in  clk_type;		
    iclk   : in  clk_type;		
    dclk   : in  clk_type;		
    holdn  : in  std_logic;		

    ici    : out icache_in_type;		-- icache input
    ico    : in  icache_out_type;		-- icache output
    dci    : out dcache_in_type;		-- dcache input
    dco    : in  dcache_out_type;		-- dcache output

    
    fpui   : out fpu_in_type;			-- FPU input
    fpuo   : in  fpu_out_type;			-- FPU output
    iui    : in  iu_in_type;			-- system input
    iuo    : out iu_out_type;			-- system output
    rfi    : out rf_in_type;			-- register-file input
    rfo    : in rf_out_type;			-- register-file output
    cpi    : out cp_in_type;			-- CP input
    cpo    : in  cp_out_type;			-- CP output
    fpi    : out cp_in_type;			-- FP input
    fpo    : in  cp_out_type			-- FP output
);
end component;

--component cache
  --port (
   -- rst   : in  std_logic;
    --clk   : in  clk_type;
  --  ici   : in  icache_in_type;
   -- ico   : out icache_out_type;
   -- dci   : in  dcache_in_type;
   -- dco   : out dcache_out_type;
   -- iuo   : in  iu_out_type;		
   -- apbi  : in  apb_slv_in_type;
   -- apbo  : out apb_slv_out_type;
  --  ahbi  : in  ahb_mst_in_type;
  --  ahbo  : out ahb_mst_out_type;
  --  crami : out cram_in_type;
--cramo : in  cram_out_type;
--fpuholdn : in  std_logic
 -- );
--end component; 

--component cp
--port (
    --rst    : in  std_logic;			-- Reset
    --clk    : in  clk_type;			-- main clock	
    --iuclk  : in  clk_type;			-- gated IU clock
   -- holdn  : in  std_logic;			-- pipeline hold
    --cpi    : in  cp_in_type;
  --  cpo    : out cp_out_type
 -- );
--end component;

--component fp
--port (
  --  rst    : in  std_logic;			-- Reset
   -- clk    : in  clk_type;			-- main clock	
   -- iuclk  : in  clk_type;			-- gated IU clock
   -- holdn  : in  std_logic;			-- pipeline hold
   -- xholdn : in  std_logic;			-- pipeline hold
   -- cpi    : in  cp_in_type;
  -- cpo    : out cp_out_type
 -- );
--end component;

--component fp1eu --unkown
--port (
   -- rst    : in  std_logic;			-- Reset
   -- clk    : in clkgen_out_type;
    --xholdn : in  std_logic;			-- Reset
    --cpi    : in  cp_in_type;
  --  cpo    : out cp_out_type
 -- );
--end component;

--component cachemem 
 -- port (
 --   	clk   : in  clk_type;
--	crami : in  cram_in_type;
--	cramo : out cram_out_type
--  );
--end component;

--signal ici : icache_in_type;
--signal ico : icache_out_type;
--signal dci : dcache_in_type;
--signal dco : dcache_out_type;

signal fpui : fpu_in_type;
signal fpuo : fpu_out_type;
signal cpi, fpi : cp_in_type;
signal cpo, fpo : cp_out_type;
signal pholdn, xholdn : std_logic;
signal iuol : iu_out_type;		
signal rfi : rf_in_type;			-- register-file input
signal rfo : rf_out_type;			-- register-file output
--signal crami : cram_in_type;
--signal cramo : cram_out_type;



begin

-- reset generator

  reset0 : rstgen port map (rst,pcirst, clko.clk, rst_t); --without (,pciresetn,) fel 2awel
  
-- clock generator

 clkgen0 : clkgen port map (clk,pciclk , clki, clko); --without (,pcii.pci_clk_in,) fel 2awel

  clki.iholdn <= ico.hold;
  clki.imdsn  <= ico.mds;
  clki.dholdn <= dco.hold;
  clki.dmdsn  <= dco.mds;
  clki.fpuholdn <= fpui.fpuholdn and cpo.holdn and fpo.holdn;
  pholdn <= fpui.fpuholdn and cpo.holdn and fpo.holdn;
  xholdn <= cpo.holdn and dco.hold and ico.hold;
  iuo <= iuol;










 -- rst_t.syncrst

-- integer unit and register file

  iu0 : iu  port map (rst_t.syncrst, clko.clk, clko.clkn, clko.iuclk, clko.iclk, 
        clko.dclk, clko.holdn, ici, ico, dci, dco, fpui, fpuo, iui, iuol,
	rfi, rfo, cpi, cpo, fpi, fpo);

  rf0 : regfile_iu generic map (RFIMPTYPE, RABITS, RDBITS, IREGNUM)
       port map (rst_t.syncrst, clko.clk, clko.clkn, rfi, rfo);

-- cache controller and memories

  --c0 : cache port map (rst_t.syncrst, clko.clk, ici, ico, dci, dco, iuol, 
	--apbi, apbo, ahbi, ahbo, crami, cramo, pholdn);

  --cmem0 : cachemem port map (clko.clk, crami, cramo);

-- FPU (optional)

 -- fpopt : if FPEN and (FPTYPE = meiko) generate
    --fpu0 : fpu port map (
    --ss_clock   => clko.clk,
    --FpInst     => fpui.FpInst, 
    --FpOp       => fpui.fpop, 
   -- FpLd       => fpui.FpLd, 
    --Reset      => fpui.reset, 
    --fprf_dout1 => fpui.fprf_dout1, 
   -- fprf_dout2 => fpui.fprf_dout2, 
   --RoundingMode => fpui.RoundingMode, 
    --FpBusy    => fpuo.FpBusy,
   -- FracResult => fpuo.FracResult,
   -- ExpResult  => fpuo.ExpResult,
   -- SignResult => fpuo.SignResult,
   -- SNnotDB    => fpuo.SNnotDB,
   -- Excep      => fpuo.Excep,
    --ConditionCodes => fpuo.ConditionCodes,
   -- ss_scan_mode => fpui.ss_scan_mode,
   -- fp_ctl_scan_in => fpui.fp_ctl_scan_in,
   -- fp_ctl_scan_out => fpuo.fp_ctl_scan_out
  -- );
  --end generate;

-- external floating-point co-processor (optional)

  --fpcopt : if (FPTYPE = fpc) generate
--    fp0 : fp port map (rst, clko.clk, clko.iuclk, clko.holdn, xholdn, fpi, fpo);
    --fp0 : fp1eu port map (rst, clko, xholdn, fpi, fpo);
  --end generate;

  nofpc : if (FPTYPE /= fpc) generate
    fpo.holdn <= '1';
    fpo.ldlock <= '0';
    fpo.ccv <= '1';
  end generate;

-- co-processor (optional)

  --cpopt : if CPEN generate
--    cp0 : cp port map (rst, clko, cpi, cpo);
    --cp0 : fp1eu port map (rst, clko, xholdn, cpi, cpo);
 -- end generate;

  nocp : if not CPEN generate
    cpo.holdn <= '1';
    cpo.ldlock <= '0';
  end generate;

end ;


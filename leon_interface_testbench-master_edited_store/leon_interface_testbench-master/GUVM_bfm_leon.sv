interface GUVM_interface(input logic clk);
    import iface::*;
    // import GUVM_classes_pkg::*;
    //logic       clk;
    logic       rst;
    logic       pciclk;
    logic       pcirst;

    iu_in_type integer_unit_input; // to the core
    iu_out_type integer_unit_output; // from the core
    
    icache_out_type icache_output; // to the core
    icache_in_type icache_input; // address to the instruction cach

    dcache_out_type dcache_output; // to the core
    
    dcache_in_type dcache_input ;  // to the data cach

    icdiag_in_type dcache_output_diag; // inside dcache_out_type package // what is this ? 

    logic [31:0] inst;
    logic [31:0] out;
    always @ (posedge clk)
      force dut.iu0.de.cwp=7;  // cntrl_enb ? cntrl_data : 'Z;
    /*
    clocking driver_cb @ (negedge clk);
        output inst;
    endclocking : driver_cb

    always @ (negedge clk) begin
        icache_output.data = inst;
        out = icache_output.data;
    end

    clocking monitor_cb @ (negedge clk);
        input out;
        // lessa b2eet el7agat 
    endclocking : monitor_cb

    modport driver_if_mp (clocking driver_cb);
    modport monitor_if_mp (clocking monitor_cb);
    */ 
    
    ////////////// elclock generation hatkoon fe eltop ///////////////////
    // always #5 clk = ~clk;
    // initial begin
    //     clk = 0;
    // end

    /*
    initial begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end
    */
    function void send_data(logic [31:0] data );
        dcache_output.data = data ;
    endfunction

    function void send_inst(logic [31:0] inst  );
        icache_output.data = inst ; 
    endfunction

    function logic [31:0] recive_data();
        return dcache_input.edata;
        //return dcache_input.edata;
    endfunction 
    function logic [31:0] store(logic [4:0] ra );
        send_inst({2'b11,ra,6'b000100,3'b0,16'h2000});
        //send_data(rd);
		//dcache_output.mds = 1'b1;
    endfunction

    function void load(logic [4:0] ra , logic [31:0] rd );
        send_inst({2'b11,ra,1'b0,8'h0,16'h2000});
        send_data(rd);
		//dcache_output.mds = 1'b1;
		
    endfunction

    function void nop ();
        icache_output.data = 32'h01000000;
    endfunction
    function void add(logic [4:0] r1,logic [4:0] r2,logic [4:0] rd);
        //dcache_output.hold = 1'b0;
        //icache_output.hold = 1'b0;
        //dcache_output.mds = 1'b1;
        send_inst({2'b10,rd,6'b0,r1,1'b0,8'b0,r2});
		//dcache_output.mds = 1'b1;
		
    endfunction

    function void set_Up();
                ////////////// da mkan elsetup function //////////////////
        pciclk = 1'b0;
        pcirst = 1'b0;

        // iui
        integer_unit_input.irl = 4'b0000;

        // ico
        // icache_output.data = 32'h8E00C002;
        icache_output.exception = 1'b0;
        icache_output.hold = 1'b1;
        icache_output.flush = 1'b0; 
        icache_output.diagrdy = 1'b0;
        icache_output.diagdata = 32'h00000000; 
        icache_output.mds = 1'b0;

        // dco
        //dcache_output.data = 32'h13; // Data bus address
        dcache_output.mexc = 1'b0; // memory exception
        dcache_output.hold = 1'b1;
        dcache_output.mds = 1'b1;
        dcache_output.werr = 1'b0; // memory write error

        dcache_output_diag.addr = 15 ;
        //dcache_output_diag.enable = 32'h0;
        dcache_output_diag.enable = 1'b0;
        dcache_output_diag.read = 1'b0;
        dcache_output_diag.tag = 1'b0;
        dcache_output_diag.flush = 1'b0;

        dcache_output.icdiag=dcache_output_diag;
    endfunction

    task reset_dut();
        rst = 1'b0;
        repeat (10) begin
            @(negedge clk);
        end
            rst = 1'b1;
    endtask : reset_dut

endinterface: GUVM_interface
module  fdtd_calc_Ez	
#(parameter FDTD_DATA_WIDTH = 32,
  parameter CUT_LT  = 51,
  parameter CUT_RT  = 21
  )
(
  input                                CLK,
  input                                RST_N,
  input                                clken,
  /////////////
  input  signed	[FDTD_DATA_WIDTH-1:0]  Hy_old_i,
  input	 signed	[FDTD_DATA_WIDTH-1:0]  Ez_old_i,
  /////////////
  input	 signed	[FDTD_DATA_WIDTH-1:0]  cezhy,
  input	 signed	[FDTD_DATA_WIDTH-1:0]  ceze,
  /////////////
  output signed [FDTD_DATA_WIDTH-1:0]  Ez_n_o
	);
  //
  localparam CUT_WIDTH = 2*FDTD_DATA_WIDTH;
  ////////////////////////////////////////////////////////
  reg  signed  [FDTD_DATA_WIDTH-1:0]  Hy_temp0;
  reg  signed  [FDTD_DATA_WIDTH-1:0]  Hy_temp1;
  reg  signed  [FDTD_DATA_WIDTH-1:0]  Ez_old_i_r;
  wire signed  [FDTD_DATA_WIDTH-1:0]  temp0;
  /////////////////////////////////////////////////////////
  wire signed  [CUT_WIDTH-1:0]        cut_data0;
  wire signed  [CUT_WIDTH-1:0]        cut_data1;
  /////////////////////////////////////////////////////////
  wire signed  [FDTD_DATA_WIDTH-1:0]  old_data;
  //
  always @(posedge CLK or negedge RST_N)begin
  	if (!RST_N)begin
  	    Hy_temp0  <= 'd0;
  	    Hy_temp1  <= 'd0;
  	end
  	else begin
  	    Hy_temp0  <= Hy_old_i;
  	    Hy_temp1  <= Hy_temp0;
  	end
  end
  //
  always_ff @(posedge CLK or negedge RST_N)begin
  	if (!RST_N)begin
  	    Ez_old_i_r  <= 'd0;
  	end
  	else begin
  	    Ez_old_i_r  <= Ez_old_i;
  	end
  end
  
  //----------------------calc_Ez_part--------------------//
  c_addsub_0 	sub_Ez_inst0	(
  			.ADD ( 1'b0     ),
  			.CE	 ( clken    ),
  			.CLK ( CLK      ),    
  			.A 	 ( Hy_temp0 ),  
  			.B   ( Hy_temp1 ),   
  			.S   ( temp0    )     	
  			);
  /////////////////////////////////////////////////////
  mult_gen_0	multi_Ez_inst0 (
  			.CLK ( CLK       ),////
  			.CE	 ( clken     ),
  			.A   ( temp0     ),///
  			.B   ( cezhy     ),///material coefficient
  			.P   ( cut_data0 )////cut
  			);														
  /////////								
  mult_gen_0	multi_Ez_inst2 (
  			.CLK ( CLK       ),////
  			.CE  ( clken     ),
  			.A   ( Ez_old_i_r),
  			.B   ( ceze      ),///material coefficient
  			.P   ( cut_data1 )////cut
  			);
  ////////
  fdtd_data_delay
  	#( .DATA_WIDTH  ( FDTD_DATA_WIDTH ),
  	   .DELAY_STAGE ( 1               )
  	)
  	u1(
       .CLK   (CLK),
       .RST_N (RST_N),
       .data_i({cut_data1[CUT_WIDTH-1],cut_data1[CUT_LT:CUT_RT]}),
       .data_o(old_data)
  	);
  //////////////////////////////////////////////////////////////		
  c_addsub_0 	add_Ez_inst3	(
  			.ADD ( 1'b1     ),    // 
  			.CE	 ( clken    ),     // 
  			.CLK ( CLK      ),  // 
  			.A 	 ({cut_data0[CUT_WIDTH-1],cut_data0[CUT_LT:CUT_RT]}), 
  			.B   ( old_data ),    // 
  			.S   ( Ez_n_o   )      //	
  			);	
  
  endmodule

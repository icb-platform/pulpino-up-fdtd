`define REG_SIZE_WIDTH    15  // At most 32KB
`define FDTD_DATA_WIDTH   32
`define BUFFER_ADDR_WIDTH 6
`define BUFFER_SIZE       50

module fdtd_top
(
    input logic     ACLK,
    input logic     ARESETn,

    AXI_BUS.Slave   slv,
    AXI_BUS.Master  mstr,

    output  logic   int_o
);
    //fdtd calc coefficients
    logic signed [mstr.AXI_DATA_WIDTH - 1: 0] ceze;
    logic signed [mstr.AXI_DATA_WIDTH - 1: 0] cezhy;
    logic signed [mstr.AXI_DATA_WIDTH - 1: 0] cezj;
    logic signed [mstr.AXI_DATA_WIDTH - 1: 0] chyh;
    logic signed [mstr.AXI_DATA_WIDTH - 1: 0] chyez;
    logic signed [mstr.AXI_DATA_WIDTH - 1: 0] coe0;
    logic signed [mstr.AXI_DATA_WIDTH - 1: 0] Jz;

    logic                                     fdtd_start_signal;
    //field_value address
    logic signed [mstr.AXI_ADDR_WIDTH - 1: 0] Hy_addr;
    logic signed [mstr.AXI_ADDR_WIDTH - 1: 0] Ez_addr;
    //starting signal of buffering field_data
    logic                                     buffer_Hy_end;
    logic                                     buffer_Ez_end;
    logic                                     buffer_src_end;
    //data valid signal
    logic                                     rdvalid_Hy;
    logic                                     rdvalid_Ez;
    //buffer data start signal
    logic                                     buffer_Hy_start;
    logic                                     buffer_Ez_start;
    logic                                     buffer_src_start;
    //ram_buffer -> data_mem
    logic                                     wrt_Hy_start;
    logic                                     wrt_Ez_start;
    logic                                     wrt_src_start;
    //
    logic                                     mem_rd_Hy_en;
    logic                                     mem_rd_Ez_en;
    //
    logic                                     wrtvalid_sgl;
    //
    logic                                     calc_Hy_start_en;
    logic                                     calc_Ez_start_en;
    logic                                     calc_src_start_en;
    logic                                     calc_Hy_flg;
    logic                                     calc_Ez_flg;
    logic                                     calc_src_flg;
    //
    logic                                     calc_Hy_end_flg;
    logic                                     calc_Ez_end_flg;
    logic                                     calc_src_end_flg;
    //
    logic [mstr.AXI_DATA_WIDTH - 1: 0]        Hy_old;
    logic [mstr.AXI_DATA_WIDTH - 1: 0]        Ez_old;
    logic [mstr.AXI_DATA_WIDTH - 1: 0]        Hy_n;
    logic [mstr.AXI_DATA_WIDTH - 1: 0]        Ez_n;
    //
    logic [`REG_SIZE_WIDTH - 1: 0]            s_size;
    logic                                     s_ctrl_int_en;
    logic                                     s_cmd_clr_int_pulse;
    logic                                     s_cmd_trigger_pulse;
    logic                                     s_status_busy;
    logic                                     s_status_int_pending;

    fdtd_reg_ctrl
    #(
        .REG_SIZE_WIDTH( `REG_SIZE_WIDTH )
    )
    reg_if_i
    (
        .ACLK                 ( ACLK                 ),
        .ARESETn              ( ARESETn              ),

        .slv                  ( slv                  ),

        .ceze                 ( ceze                 ),
        .cezhy                ( cezhy                ),
        .cezj                 ( cezj                 ),
        .chyh                 ( chyh                 ),
        .chyez                ( chyez                ),
        .coe0                 ( coe0                 ),
        .Jz                   ( Jz                   ),
        //calculation signal
        .fdtd_start_signal_o  ( fdtd_start_signal    ),
        //read/write address
        .Hy_addr_o            ( Hy_addr              ),
        .Ez_addr_o            ( Ez_addr              ),
        //calculation flag
        .calc_Hy_start_en_o   ( calc_Hy_start_en     ),
        .calc_Ez_start_en_o   ( calc_Ez_start_en     ),
        .calc_src_start_en_o  ( calc_src_start_en    ),
        .calc_Hy_end_flg_i    ( calc_Hy_end_flg      ),
        .calc_Ez_end_flg_i    ( calc_Ez_end_flg      ),
        .calc_src_end_flg_i   ( calc_src_end_flg     ),
        //
        .size_o               ( s_size               ),
        .ctrl_int_en_o        ( s_ctrl_int_en        ),
        .cmd_clr_int_pulse_o  ( s_cmd_clr_int_pulse  ),
        .cmd_trigger_pulse_o  ( s_cmd_trigger_pulse  ),

        .status_busy_i        ( s_status_busy        ),
        .status_int_pending_i ( s_status_int_pending )
    );

    fdtd_mem_ctrl
    #(
        .REG_SIZE_WIDTH ( `REG_SIZE_WIDTH )
    )
    mem_ctrl_i
    (
        .ACLK                 ( ACLK                 ),
        .ARESETn              ( ARESETn              ),
        .mstr                 ( mstr                 ),
        //fdtd logic
        //initial signal
        .fdtd_start_signal_i  ( fdtd_start_signal    ),
        //fdfd size
        .size_i               ( s_size               ),
        //two basic address of electromagnetic
        .Hy_addr_i            ( Hy_addr              ),
        .Ez_addr_i            ( Ez_addr              ),
        //caculation signal
        .calc_Hy_start_en_i   ( calc_Hy_start_en     ),
        .calc_Ez_start_en_i   ( calc_Ez_start_en     ),
        .calc_src_start_en_i  ( calc_src_start_en    ),
        
        .calc_Hy_flg_o        ( calc_Hy_flg          ),
        .calc_Ez_flg_o        ( calc_Ez_flg          ),
        .calc_src_flg_o       ( calc_src_flg         ),
        .calc_Hy_end_flg_o    ( calc_Hy_end_flg	     ),
        .calc_Ez_end_flg_o    ( calc_Ez_end_flg	     ),
        .calc_src_end_flg_o   ( calc_src_end_flg     ),
        //ram_buffer -> data_mem
        .wrt_Hy_start_i	      ( wrt_Hy_start         ),
        .wrt_Ez_start_i	      ( wrt_Ez_start         ),
        .wrt_src_start_i      ( wrt_src_start        ),
        //data_mem -> ram_buffer
        .mem_rd_Hy_en_o       ( mem_rd_Hy_en         ),
        .mem_rd_Ez_en_o	      ( mem_rd_Ez_en         ),	
        .mem_rd_end_o         ( mem_rd_end           ),	
        .wrtvalid_sgl_o	      ( wrtvalid_sgl         ),	
        //
        .buffer_Hy_start_o    ( buffer_Hy_start      ),
        .buffer_Ez_start_o    ( buffer_Ez_start      ),
        .buffer_src_start_o   ( buffer_src_start     ),
        .buffer_Hy_end_o      ( buffer_Hy_end        ),
        .buffer_Ez_end_o      ( buffer_Ez_end        ),
        .buffer_src_end_o     ( buffer_src_end       ),
        //
        .rdvalid_Hy_o_o	      ( rdvalid_Hy           ),
        .rdvalid_Ez_o_o	      ( rdvalid_Ez           ),
        //read/write data
        .Hy_old_o             ( Hy_old               ),
        .Ez_old_o             ( Ez_old               ),
        .Hy_n_i               ( Hy_n                 ),
        .Ez_n_i               ( Ez_n                 ),
        //user logic
        .ctrl_int_en_i        ( s_ctrl_int_en        ),
        .cmd_clr_int_pulse_i  ( s_cmd_clr_int_pulse  ),
        .cmd_trigger_pulse_i  ( s_cmd_trigger_pulse  ),

        .status_busy_o        ( s_status_busy        ),
        .status_int_pending_o ( s_status_int_pending ),
        .int_o                ( int_o                )
    );
///////////////////
//one_dim_fdtd/////
///////////////////
    fdtd_acc 
    #(
        .FDTD_DATA_WIDTH  ( `FDTD_DATA_WIDTH    ),
        .BUFFER_SIZE      ( `BUFFER_SIZE        ),
        .BUFFER_ADDR_WIDTH( `BUFFER_ADDR_WIDTH  )
    )
    fdtd_acc_i
    (
        .CLK                ( ACLK              ),
        .RST_N              ( ARESETn           ),
        //ram_buffer -> data_mem
        .wrt_Hy_start_o     ( wrt_Hy_start      ),
        .wrt_Ez_start_o     ( wrt_Ez_start      ),
        .wrt_src_start_o    ( wrt_src_start     ),
        //data_mem -> ram_buffer
        .mem_rd_Hy_en_i     ( mem_rd_Hy_en      ),
        .mem_rd_Ez_en_i     ( mem_rd_Ez_en      ),
        .mem_rd_end_i       ( mem_rd_end        ),
        .wrtvalid_sgl_i     ( wrtvalid_sgl      ),
        .wrtvalid_Hy_old_i  ( rdvalid_Hy       	),
        .wrtvalid_Ez_old_i  ( rdvalid_Ez       	),
        //buffer start
        .buffer_Hy_start_i  ( buffer_Hy_start   ),
        .buffer_Ez_start_i  ( buffer_Ez_start   ),
        .buffer_src_start_i ( buffer_src_start  ),
        //buffer end
        .buffer_Hy_end_i    ( buffer_Hy_end     ),
        .buffer_Ez_end_i    ( buffer_Ez_end     ),
        .buffer_src_end_i   ( buffer_src_end    ),
        //calculation flag
        .calc_Hy_flg_i      ( calc_Hy_flg       ),
        .calc_Ez_flg_i      ( calc_Ez_flg       ),
        .calc_src_flg_i     ( calc_src_flg      ),
        //some coefficients for calculation
        .ceze               ( ceze              ),
        .cezhy              ( cezhy             ),
        .cezj               ( cezj              ),
        .chyh               ( chyh              ),
        .chyez              ( chyez             ),
        .coe0               ( coe0              ),
        .Jz                 ( Jz                ),
        //
        .Hy_old_i           ( Hy_old            ),
        .Ez_old_i           ( Ez_old            ),
        .Hy_n_o             ( Hy_n              ),
        .Ez_n_o             ( Ez_n              )	
    );
//
endmodule

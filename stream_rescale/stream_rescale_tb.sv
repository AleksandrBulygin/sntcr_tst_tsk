`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2023 20:00:24
// Design Name: 
// Module Name: resizer_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define T_DATA_WIDTH_D 4
`define S_KEEP_WIDTH_D 4
`define M_KEEP_WIDTH_D 7

module resizer_tb  #(parameter T_DATA_WIDTH = `T_DATA_WIDTH_D,
                               S_KEEP_WIDTH = `S_KEEP_WIDTH_D,
                               M_KEEP_WIDTH = `M_KEEP_WIDTH_D)
                   ();
    
    logic                   	CLK;
    logic [65:0]             	testvectors					[10000:0];
    logic [31:0]             	vectornum;
    logic [31:0]             	errors;
    
    logic [T_DATA_WIDTH-1:0] 	s_data_i_pp          	[S_KEEP_WIDTH-1:0];
    logic [S_KEEP_WIDTH-1:0] 	s_keep_i_pp;
    logic                    	s_last_i_pp;
    logic [T_DATA_WIDTH-1:0] 	buffer_pp             	[S_KEEP_WIDTH-1:0];
    logic [S_KEEP_WIDTH-1:0] 	last_idx_pp;
    logic [T_DATA_WIDTH-1:0] 	buffer_pp_test        	[S_KEEP_WIDTH-1:0];
    logic [S_KEEP_WIDTH-1:0] 	last_idx_pp_test;
    logic [S_KEEP_WIDTH-1:0] 	keep_idx_pp;
    logic [S_KEEP_WIDTH-1:0] 	keep_idx_pp_test;
    logic [T_DATA_WIDTH-1:0] 	s_parsed_data_i_fifo  	[S_KEEP_WIDTH-1:0];
    logic [S_KEEP_WIDTH-1:0] 	s_last_idx_i_fifo;
    logic [S_KEEP_WIDTH-1:0] 	s_keep_idx_i_fifo;
    logic                    	clk_i_fifo;
    logic                    	rst_i_fifo;
    logic                    	m_ready_i_fifo;
    logic                    	s_we_i_fifo;
    logic                    	m_full_o_fifo;
    logic                    	m_empty_o_fifo;
    logic                    	m_last_o_fifo;
    logic [T_DATA_WIDTH-1:0] 	m_data_o_fifo          	[M_KEEP_WIDTH-1:0];
    logic [M_KEEP_WIDTH-1:0] 	m_keep_o_fifo;
    logic                    	m_full_o_fifo_test;
    logic                    	m_empty_o_fifo_test;
    logic                    	m_last_o_fifo_test;
    logic [T_DATA_WIDTH-1:0] 	m_data_o_fifo_test     	[M_KEEP_WIDTH-1:0];
    logic [M_KEEP_WIDTH-1:0] 	m_keep_o_fifo_test;
    logic                    	clk_rszr;
	 logic							fast_clock;
    logic                    	rst_n_rszr;
    logic [T_DATA_WIDTH-1:0] 	s_data_i_rszr          	[S_KEEP_WIDTH-1:0];
    logic [S_KEEP_WIDTH-1:0] 	s_keep_i_rszr;
    logic                    	s_last_i_rszr;
    logic                    	s_valid_i_rszr;
    logic                    	s_ready_o_rszr;
    logic                    	s_ready_o_rszr_test;
    logic [T_DATA_WIDTH-1:0] 	m_data_o_rszr        	[M_KEEP_WIDTH-1:0];
    logic [T_DATA_WIDTH-1:0] 	m_data_o_rszr_test      [M_KEEP_WIDTH-1:0];
    logic [M_KEEP_WIDTH-1:0] 	m_keep_o_rszr;
    logic [M_KEEP_WIDTH-1:0] 	m_keep_o_rszr_test;
    logic                    	m_last_o_rszr;
    logic                    	m_last_o_rszr_test;
    logic                    	m_valid_o_rszr;
    logic                    	m_valid_o_rszr_test;
    logic                    	m_ready_i_rszr;  
    
    priority_parser priority_parser_dut(.s_data_i(s_data_i_pp),
                                        .s_keep_i(s_keep_i_pp),
                                        .s_last_i(s_last_i_pp),
                                        .m_buffer_o(buffer_pp),
                                        .m_last_idx_o(last_idx_pp),
                                        .m_keep_idx_o(keep_idx_pp));
                                        
    FIFO FIFO_dut(.s_parsed_data_i(s_parsed_data_i_fifo),
                  .s_last_idx_i(s_last_idx_i_fifo),
                  .s_keep_idx_i(s_keep_idx_i_fifo),
                  .clk_i(clk_i_fifo),
                  .rst_i(rst_i_fifo),
                  .m_ready_i(m_ready_i_fifo),
                  .s_we_i(s_we_i_fifo),
                  .m_full_o(m_full_o_fifo),
                  .m_empty_o(m_empty_o_fifo),
                  .m_last_o(m_last_o_fifo),
                  .m_data_o(m_data_o_fifo),
                  .m_keep_o(m_keep_o_fifo));
                  
    stream_rescale stream_rescale_dut(.clk(fast_clock),
                                      .rst_n(rst_n_rszr),
                                      .s_data_i(s_data_i_rszr),
                                      .s_keep_i(s_keep_i_rszr),
                                      .s_last_i(s_last_i_rszr),
                                      .s_valid_i(s_valid_i_rszr),
                                      .s_ready_o(s_ready_o_rszr),
                                      .m_data_o(m_data_o_rszr),
                                      .m_keep_o(m_keep_o_rszr),
                                      .m_last_o(m_last_o_rszr),
                                      .m_valid_o(m_valid_o_rszr),
                                      .m_ready_i(m_ready_i_rszr));
                                        
    task priority_parser_test (input [7:0] iterations);
        
                    integer i;
    
            $readmemb("../../priority_parser_testvector.tv", testvectors);
            vectornum = 0;
            errors = 0;
            

            s_data_i_pp = {testvectors[vectornum][44:41], 
            testvectors[vectornum][40:37], testvectors[vectornum][36:33],
             testvectors[vectornum][32:29]};
            {s_keep_i_pp, s_last_i_pp} = testvectors[vectornum][28:24];
            buffer_pp_test = {testvectors[vectornum][23:20],
            testvectors[vectornum][19:16], testvectors[vectornum][15:12], 
            testvectors[vectornum][11:8]};
            last_idx_pp_test = testvectors[vectornum][7:4];
            keep_idx_pp_test = testvectors[vectornum][3:0];
            
            for(i = 0; i < iterations; i++)
                begin
                
                if(buffer_pp_test != buffer_pp || 
                last_idx_pp != last_idx_pp_test || 
                keep_idx_pp != keep_idx_pp_test)
                    begin
                    $display("ERROR: iteration #%d", vectornum[5:0]+1);
                    errors = errors + 1;
                end
                
                    
                s_data_i_pp = {testvectors[vectornum][44:41], 
                testvectors[vectornum][40:37], testvectors[vectornum][36:33], 
                testvectors[vectornum][32:29]};
                {s_keep_i_pp, s_last_i_pp} = testvectors[vectornum][28:24];
                buffer_pp_test = {testvectors[vectornum][23:20], 
                testvectors[vectornum][19:16], testvectors[vectornum][15:12], 
                testvectors[vectornum][11:8]};
                last_idx_pp_test = testvectors[vectornum][7:4];
                keep_idx_pp_test = testvectors[vectornum][3:0];
                    
                CLK = 1; #5; CLK = 0; #5;
                vectornum = vectornum + 1;
                
                end
                $display("%d priority parser tests finished with %d errors", 
                vectornum[5:0], errors[5:0]);
        
    endtask
    
    task FIFO_test(input [7:0] iterations);
    
        integer i;
        
        $readmemb("../../FIFO_testvector.tv", testvectors);
        vectornum = 0;
        errors = 0;
        
        for(i = 0; i < iterations; i++)
        begin
            {rst_i_fifo, clk_i_fifo} = testvectors[vectornum][65:64];
            s_parsed_data_i_fifo = {testvectors[vectornum][63:60], 
            testvectors[vectornum][59:56], testvectors[vectornum][55:52], 
            testvectors[vectornum][51:48]};
            {s_keep_idx_i_fifo, s_last_idx_i_fifo, m_ready_i_fifo, s_we_i_fifo, 
            m_full_o_fifo_test, m_empty_o_fifo_test, 
            m_last_o_fifo_test} = testvectors[vectornum][47:35];
            m_data_o_fifo_test = {testvectors[vectornum][34:31], 
            testvectors[vectornum][30:27], testvectors[vectornum][26:23], 
            testvectors[vectornum][22:19], testvectors[vectornum][18:15], 
            testvectors[vectornum][14:11], testvectors[vectornum][10:7]};
            m_keep_o_fifo_test = testvectors[vectornum][6:0];
            
            #5;
            if(m_last_o_fifo != m_last_o_fifo_test || 
            m_data_o_fifo != m_data_o_fifo_test || 
            m_keep_o_fifo != m_keep_o_fifo_test)
                begin
                $display("ERROR: iteration #%d", vectornum[6:0]+1);
                errors++;
                end
             vectornum++;
        end
        $display("%d FIFO Reg tests finished with %d errors", vectornum[6:0], 
        errors[6:0]);
            
    endtask
    
    task stream_rescale_test(input [7:0] iterations);
    
        integer i;
        
        $readmemb("../../stream_rescale_testvector.tv", testvectors);
        vectornum = 0;
        errors = 0;
		  fast_clock = 0;
        
        for(i = 0; i < iterations; i++)
        begin
            {clk_rszr, rst_n_rszr} = testvectors[vectornum][62:61];
            s_data_i_rszr = {testvectors[vectornum][60:57], 
            testvectors[vectornum][56:53], testvectors[vectornum][52:49], 
            testvectors[vectornum][48:45]};
            {s_keep_i_rszr, s_last_i_rszr, s_valid_i_rszr, 
            s_ready_o_rszr_test} = testvectors[vectornum][44:38];
            m_data_o_rszr_test = {testvectors[vectornum][37:34], 
            testvectors[vectornum][33:30], testvectors[vectornum][29:26], 
            testvectors[vectornum][25:22], testvectors[vectornum][21:18], 
            testvectors[vectornum][17:14], testvectors[vectornum][13:10]};
            m_keep_o_rszr_test = testvectors[vectornum][9:3];
            {m_last_o_rszr_test, m_valid_o_rszr_test, m_ready_i_rszr} = 
            testvectors[vectornum][2:0];
            
            while(clk_rszr != stream_rescale_dut.clk_40MHZ)
					begin
					fast_clock = !fast_clock;
					#3;
					end
				#5;
            if(s_ready_o_rszr != s_ready_o_rszr_test || 
            m_data_o_rszr != m_data_o_rszr_test || 
            m_keep_o_rszr != m_keep_o_rszr_test ||
            m_last_o_rszr != m_last_o_rszr_test || 
            m_valid_o_rszr != m_valid_o_rszr_test)
                begin
                $display("ERROR: iteration #%d", vectornum[6:0]+1);
                errors++;
                end
             vectornum++;
        end
        $display("%d stream rescale tests finished with %d errors", 
        vectornum[6:0], errors[6:0]);
            
    endtask    
        initial
    begin

    priority_parser_test(11);
    #5;
    FIFO_test(31);
    #5;
    stream_rescale_test(42);
    
    $finish;
    end
endmodule

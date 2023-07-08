`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2023 19:55:24
// Design Name: 
// Module Name: 
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
`define FIFO_ADDR_WIDTH 8
`define MAX_PTR `M_KEEP_WIDTH_D*`S_KEEP_WIDTH_D-1

module stream_rescale #(
  parameter T_DATA_WIDTH = `T_DATA_WIDTH_D,
  S_KEEP_WIDTH = `S_KEEP_WIDTH_D,
  M_KEEP_WIDTH = `M_KEEP_WIDTH_D
)(
  input logic                       clk,
  input logic                       rst_n,
  input logic   [T_DATA_WIDTH-1:0]  s_data_i    [S_KEEP_WIDTH-1:0],
  input logic   [S_KEEP_WIDTH-1:0]  s_keep_i,
  input logic                       s_last_i,
  input logic                       s_valid_i,
  output logic                      s_ready_o,
  output logic  [T_DATA_WIDTH-1:0]  m_data_o    [M_KEEP_WIDTH-1:0],
  output logic  [M_KEEP_WIDTH-1:0]  m_keep_o,
  output logic                      m_last_o,
  output logic                      m_valid_o,
  input logic                       m_ready_i
);  
    logic       [T_DATA_WIDTH-1:0]  data_reg    [S_KEEP_WIDTH-1:0];
    logic       [S_KEEP_WIDTH-1:0]  keep_reg;
    logic                           last_reg;
    logic                           valid_reg;
    logic       [T_DATA_WIDTH-1:0]  parsed_data [S_KEEP_WIDTH-1:0];
    logic       [S_KEEP_WIDTH-1:0]  last_idx;
    logic       [S_KEEP_WIDTH-1:0]  keep_idx;
    logic                           fifo_empty;
    logic                           fifo_full;
	 logic									clk_40MHZ;
	 logic									locked;
    integer                         i;
    
    always @(posedge clk_40MHZ, negedge rst_n)
        begin
        if (!rst_n)
            begin
            for(i = 0; i <S_KEEP_WIDTH; i++)
                begin: RESET_LOOP
                data_reg[i] <= 0;
                end
            keep_reg <= 0;
            last_reg <= 0;
            valid_reg <= 0;
            end
        else
            begin
            for(i = 0; i < S_KEEP_WIDTH; i++)
                begin: RESET_LOOP_1
                data_reg[i] <= s_data_i[i];
                end
            keep_reg <= s_keep_i;
            last_reg <= s_last_i;
            valid_reg <= s_valid_i;
            end
        end
        
    clockDecrease clockDecrease_inst(
		.refclk(clk),
		.rst(!rst_n),
		.outclk_0(clk_40MHZ),
		.locked(locked)
	);
	 
	 FIFO fifo_inst(
        .s_parsed_data_i(parsed_data),
        .s_last_idx_i(last_idx),
        .s_keep_idx_i(keep_idx),
        .clk_i(clk_40MHZ),
        .rst_i(!rst_n),
        .m_ready_i(m_ready_i),
        .s_we_i(valid_reg),
        .m_full_o(fifo_full),
        .m_empty_o(fifo_empty),
        .m_last_o(m_last_o),
        .m_data_o(m_data_o),
        .m_keep_o(m_keep_o));
    
    priority_parser priority_parser_inst(
        .s_data_i(data_reg),
        .s_keep_i(keep_reg),
        .s_last_i(last_reg),
        .m_buffer_o(parsed_data),
        .m_last_idx_o(last_idx),
        .m_keep_idx_o(keep_idx));
    
    assign  m_valid_o = !fifo_empty;
    assign  s_ready_o = !fifo_full;
endmodule

module priority_parser #(
    parameter   T_DATA_WIDTH = `T_DATA_WIDTH_D,
                S_KEEP_WIDTH = `S_KEEP_WIDTH_D,
                M_KEEP_WIDTH = `M_KEEP_WIDTH_D
)(
    input logic     [T_DATA_WIDTH-1:0]  s_data_i        [S_KEEP_WIDTH-1:0],
    input logic     [S_KEEP_WIDTH-1:0]  s_keep_i,
    input logic                         s_last_i,
    output logic    [T_DATA_WIDTH-1:0]  m_buffer_o      [S_KEEP_WIDTH-1:0],
    output logic    [S_KEEP_WIDTH-1:0]  m_last_idx_o,
    output logic    [S_KEEP_WIDTH-1:0]  m_keep_idx_o);
                        
    integer i, j;
                        
    logic           [S_KEEP_WIDTH-1:0]  onehot_count    [S_KEEP_WIDTH-1:0];
    logic           [S_KEEP_WIDTH-1:0]  buffer_idx      [S_KEEP_WIDTH-1:0];
                        
                        
    always_comb
        begin
        for(i = 0; i < S_KEEP_WIDTH ; i++) begin: parser_loop
            for(j = 0; j < S_KEEP_WIDTH ; j++) begin: inner_parser_loop
                onehot_count[i] = (j == 0) ? s_keep_i[0] : (j <= i) ? 
                (onehot_count[i]+s_keep_i[j]) : (onehot_count[i]);
            end
        end
        
        for (i = 0; i < S_KEEP_WIDTH ; i++) 
            begin: parser_loop_2
            for(j = 0; j < S_KEEP_WIDTH ; j++) 
                begin: inner_parser_loop_2
                buffer_idx[i] = (j == 0) ? 0 : 
                (((i == onehot_count[j]-1)&(i-1 == onehot_count[j-1]-1)) ? j : 
                buffer_idx[i]);
                end
            end
                            
        for (i = 0; i < S_KEEP_WIDTH ; i++) 
            begin: parser_loop_3
            m_buffer_o[i] = s_data_i[buffer_idx[i]];
            end    
                        
        m_last_idx_o = s_last_i ? onehot_count[S_KEEP_WIDTH - 1] : 0;
        m_keep_idx_o = onehot_count[S_KEEP_WIDTH - 1];
        end
                        
endmodule

module FIFO #(
    parameter   T_DATA_WIDTH = `T_DATA_WIDTH_D,
                S_KEEP_WIDTH = `S_KEEP_WIDTH_D,
                M_KEEP_WIDTH = `M_KEEP_WIDTH_D
)(
    input logic     [T_DATA_WIDTH-1:0]      s_parsed_data_i     [S_KEEP_WIDTH-1:0],
    input logic     [S_KEEP_WIDTH-1:0]      s_last_idx_i,
    input logic     [S_KEEP_WIDTH-1:0]      s_keep_idx_i,
    input logic                             clk_i,
    input logic                             rst_i,
    input logic                             m_ready_i,
    input logic                             s_we_i,
    output logic                            m_full_o,
    output logic                            m_empty_o,
    output logic                            m_last_o,
    output logic    [T_DATA_WIDTH-1:0]      m_data_o            [M_KEEP_WIDTH-1:0],
    output logic    [M_KEEP_WIDTH-1:0]      m_keep_o);
        
    logic           [T_DATA_WIDTH-1:0]      data_fifo_buffer    [S_KEEP_WIDTH*M_KEEP_WIDTH-1:0];
    logic                                   last_fifo_buffer    [S_KEEP_WIDTH*M_KEEP_WIDTH-1:0];
    logic           [`FIFO_ADDR_WIDTH-1:0]  wr_ptr;
    logic           [`FIFO_ADDR_WIDTH-1:0]  rd_ptr;
    logic           [`FIFO_ADDR_WIDTH-1:0]  carry_wr_ptr;
    logic           [M_KEEP_WIDTH-1:0]      last_flag_rd;
    logic           [M_KEEP_WIDTH-1:0]      last_rd_idx         [M_KEEP_WIDTH-1:0];
    logic                                   carry_fifo;
    logic                                   last;
                        
    integer                                 i, k, d;

    always @(posedge rst_i, negedge clk_i)
        begin
        if(rst_i)
            begin
            wr_ptr <= 0;
            carry_fifo <= 0;
            m_full_o <= 1'b0;
            carry_wr_ptr <= `MAX_PTR;
            for (i = 0; i < S_KEEP_WIDTH*M_KEEP_WIDTH; i++)
                begin: RESET_FIFO_BUFFER_LOOP
                data_fifo_buffer[i] <= 0;
                last_fifo_buffer[i] <= 0;
                end             
            end                 
                                    
        else
            begin
            if(s_we_i)
                begin
                if ((((wr_ptr + S_KEEP_WIDTH + s_keep_idx_i)<=`MAX_PTR 
                &(wr_ptr>rd_ptr))
                | (((wr_ptr + S_KEEP_WIDTH + s_keep_idx_i)<rd_ptr))))
                    begin
                    wr_ptr <= wr_ptr + s_keep_idx_i;
                    carry_wr_ptr <= carry_wr_ptr;
                    m_full_o <= 1'b0;
                    carry_fifo <= (wr_ptr < rd_ptr);
                    for(i = 0; i < S_KEEP_WIDTH; i++) 
                        begin: WRITE_LOOP_1
                        data_fifo_buffer[wr_ptr+i] <= s_parsed_data_i[i];
                        last_fifo_buffer[wr_ptr+i] <= (s_last_idx_i-1==i);
                        end
                    end
                else if (((wr_ptr + S_KEEP_WIDTH + s_keep_idx_i)>`MAX_PTR) 
                & (rd_ptr > S_KEEP_WIDTH - 1)&(wr_ptr>rd_ptr))
                    begin
                    wr_ptr <= 0;
                    carry_fifo <= 1'b1;
                    carry_wr_ptr <= wr_ptr + s_keep_idx_i;
                    m_full_o <= 1'b0;
                    for(i = 0; i < S_KEEP_WIDTH; i++) 
                        begin: WRITE_LOOP_2
                        data_fifo_buffer[wr_ptr+i] <= s_parsed_data_i[i];
                        last_fifo_buffer[wr_ptr+i] <= (s_last_idx_i-1==i);
                        end
                    end                              
                else if ((wr_ptr + S_KEEP_WIDTH)<=rd_ptr)
                    begin
                    wr_ptr <= wr_ptr + s_keep_idx_i;
                    m_full_o <= 
                    ((wr_ptr + S_KEEP_WIDTH + s_keep_idx_i)>=rd_ptr);
                    for(i = 0; i < S_KEEP_WIDTH; i++) 
                        begin: WRITE_LOOP_3
                        data_fifo_buffer[wr_ptr+i] <= (s_keep_idx_i>i) ? 
                        s_parsed_data_i[i] : data_fifo_buffer[wr_ptr+i];
                        last_fifo_buffer[wr_ptr+i] <= (s_keep_idx_i>i) ? 
                        (s_last_idx_i-1==i) : last_fifo_buffer[wr_ptr+i];
                        end
                    end
                else if (!carry_fifo&(wr_ptr == rd_ptr))
                    begin
                    wr_ptr <= ((
                    (wr_ptr + S_KEEP_WIDTH + s_keep_idx_i) <= `MAX_PTR)
                    |wr_ptr==0) 
                    ? wr_ptr + s_keep_idx_i : 0;
                    carry_wr_ptr <= ((
                    (wr_ptr + S_KEEP_WIDTH + s_keep_idx_i) <= `MAX_PTR)
                    |wr_ptr==0) 
                    ? carry_wr_ptr : wr_ptr + s_keep_idx_i;
                    m_full_o <= 1'b0;
                    carry_fifo <= (
                    (wr_ptr + S_KEEP_WIDTH + s_keep_idx_i) > `MAX_PTR);
                    for(i = 0; i < S_KEEP_WIDTH; i++) 
                        begin: WRITE_LOOP_4
                        data_fifo_buffer[wr_ptr+i] <= s_parsed_data_i[i];
                        last_fifo_buffer[wr_ptr+i] <= (s_last_idx_i-1==i);
                        end
                    end
                else if(carry_fifo&(wr_ptr==rd_ptr)&(M_KEEP_WIDTH==1))
                    begin
                    wr_ptr <= (wr_ptr==0) ? wr_ptr + s_keep_idx_i : 
                    s_keep_idx_i + wr_ptr - (`MAX_PTR+1);
                    m_full_o <= 1'b0;
                    for(i = 0; i < S_KEEP_WIDTH; i++) 
                        begin: WRITE_LOOP_5
                        data_fifo_buffer[(wr_ptr+i<=`MAX_PTR)? wr_ptr+i :
                        i + wr_ptr - (`MAX_PTR+2)] <= s_parsed_data_i[i];
                        last_fifo_buffer[(wr_ptr+i<=`MAX_PTR)? wr_ptr+i :
                        i + wr_ptr - (`MAX_PTR+2)] <= (s_last_idx_i-1==i);
                        end
                    end
                else
                    begin
                    wr_ptr <= wr_ptr;
                    carry_wr_ptr <= carry_wr_ptr;
                    m_full_o <= 1'b1;    
                    end
                end
            end
        end
        
    always @(posedge rst_i, posedge clk_i)
        begin
        if(rst_i)
            begin
            for (i = 0; i < M_KEEP_WIDTH; i++)
                begin: RESET_OUTPUT_LOOP
                m_data_o[i] <= 0;
                end
            rd_ptr <= 0;
            m_empty_o <= 1'b1;
            m_keep_o <= 0;
            m_last_o <= 0;
            end
        else
            begin
            if(m_ready_i)
                begin
                m_last_o <= last;
                if((rd_ptr + M_KEEP_WIDTH <= wr_ptr) | 
                ((rd_ptr + M_KEEP_WIDTH < carry_wr_ptr) & 
                ((rd_ptr > wr_ptr)|((rd_ptr==wr_ptr)&carry_fifo))))
                    begin
                    for (i = 0; i < M_KEEP_WIDTH; i++)
                        begin: READ_LOOP
                        m_data_o[i] <= data_fifo_buffer[rd_ptr+i];
                        m_keep_o[i] <= (i==0) ? 1'b1 : !last_flag_rd[i-1];
                        end
                    m_empty_o <= 1'b0;
                    rd_ptr <= (last) ? rd_ptr + last_rd_idx[M_KEEP_WIDTH-1] : 
                    rd_ptr + M_KEEP_WIDTH;
                    end
                else if((rd_ptr + M_KEEP_WIDTH >= carry_wr_ptr) &
                ((rd_ptr > wr_ptr)|((rd_ptr==wr_ptr)&carry_fifo)) 
                & (M_KEEP_WIDTH + rd_ptr - carry_wr_ptr <= wr_ptr))
                    begin
                    for (i = 0; i < M_KEEP_WIDTH; i++)
                        begin: READ_LOOP_2
                        m_data_o[i] <= (rd_ptr+i < carry_wr_ptr) ? 
                        data_fifo_buffer[rd_ptr+i] : 
                        data_fifo_buffer[i + rd_ptr - carry_wr_ptr];
                        m_keep_o[i] <= (i==0) ? 1'b1 : !last_flag_rd[i-1];
                        end
                    rd_ptr <= M_KEEP_WIDTH + rd_ptr - carry_wr_ptr;
                    m_empty_o <= 1'b0;
                    end
                else if(last&(wr_ptr!=rd_ptr))
                    begin
                    for (i = 0; i < M_KEEP_WIDTH; i++)
                        begin: READ_LOOP_3
                        m_data_o[i] <= (M_KEEP_WIDTH + rd_ptr < carry_wr_ptr) 
                        ? data_fifo_buffer[rd_ptr+i] :
                        ((carry_wr_ptr - rd_ptr) > i) ? 
                        data_fifo_buffer[rd_ptr+i] : 
                        data_fifo_buffer[i-carry_wr_ptr+rd_ptr];
                        m_keep_o[i] <= (i==0) ? 1'b1 : !last_flag_rd[i-1];
                        end
                    m_empty_o <= 1'b0;
                    rd_ptr <= ((M_KEEP_WIDTH - carry_wr_ptr + rd_ptr <= wr_ptr)
                    &(rd_ptr>wr_ptr)&(rd_ptr+M_KEEP_WIDTH>carry_wr_ptr)) 
                    ? M_KEEP_WIDTH - carry_wr_ptr + rd_ptr 
                    : ((rd_ptr>=wr_ptr)&(rd_ptr+M_KEEP_WIDTH>carry_wr_ptr)) 
                    ? wr_ptr : 
                    ((rd_ptr+M_KEEP_WIDTH>carry_wr_ptr)&
                    (last_rd_idx[M_KEEP_WIDTH-1]>=carry_wr_ptr-rd_ptr+1)) ?
                    last_rd_idx[M_KEEP_WIDTH-1] + rd_ptr - (carry_wr_ptr + 1) :
                    rd_ptr + last_rd_idx[M_KEEP_WIDTH-1]; 
                    end
                else
                    begin
                    m_empty_o <= 1'b1;
                    rd_ptr <= rd_ptr;
                    end
                end
            end
        end
    
    always_comb
        begin
        for (k = 0; k < M_KEEP_WIDTH; k++)
            begin: LOOP_LAST_FLAG_RD
            last_flag_rd[k] = (k == 0) ? last_fifo_buffer[rd_ptr] :
            (((rd_ptr>=wr_ptr)&(k<carry_wr_ptr-rd_ptr+wr_ptr)|
            ((rd_ptr<wr_ptr)&(rd_ptr+k<wr_ptr)))?
            ((carry_wr_ptr - rd_ptr < M_KEEP_WIDTH) ? 
            (((carry_wr_ptr - rd_ptr) > k) ? last_flag_rd[k-1]|
            last_fifo_buffer[rd_ptr+k] 
            : last_flag_rd[k-1]|last_fifo_buffer[k-carry_wr_ptr+rd_ptr]) : 
            last_flag_rd[k-1]|last_fifo_buffer[rd_ptr+k]) : last_flag_rd[k-1]);
            end
        for (k = 0; k < M_KEEP_WIDTH; k++)
            begin: LOOP_LAST_RD_IDX
            last_rd_idx[k] = (k == 0) ? !last_fifo_buffer[rd_ptr] + 1 :
            ((carry_wr_ptr - rd_ptr < M_KEEP_WIDTH)) ? 
            (((carry_wr_ptr - rd_ptr) > k) ? 
            (last_rd_idx[k-1] + 
            (!last_fifo_buffer[rd_ptr+k]&(!last_flag_rd[k-1]))) 
            : (last_rd_idx[k-1] + (!last_fifo_buffer[k-carry_wr_ptr+rd_ptr]
            &(!last_flag_rd[k-1])))) :
            (last_rd_idx[k-1] + 
            (!last_fifo_buffer[rd_ptr+k]&(!last_flag_rd[k-1])));
            end
        last = last_flag_rd[M_KEEP_WIDTH-1];
    end

endmodule
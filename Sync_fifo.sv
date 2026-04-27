`timescale 1ns/1ps
`define BUF_WIDTH 3
`define BUF_SIZE (1 << `BUF_WIDTH)

module Sync_FIFO ( 
  input                  baud_clk,
  input                  rst,
  input                  wr_en,
  input                  rd_en,
  input      [7:0]       buf_in, //payload_out
  input                  do_it,
  output reg [7:0]       buf_out,
  output logic           buf_empty,
  output logic           buf_full
);

  // Internal memory
  reg [7:0] buf_mem[`BUF_SIZE-1:0];
 // reg [63:0] mem;
  // Extended-width read/write pointers with wrap bit
  reg [`BUF_WIDTH:0]  rd_ptr;
  reg [`BUF_WIDTH:0] wr_ptr;
  reg do_it_pls;
  logic delay ; //[7:0] delay;
  logic wr_ena;
always_ff@(posedge baud_clk or posedge rst) begin
    if(rst)   delay <= '0;
    else delay <=    wr_en; //{delay[6:0],wr_en};
end
assign wr_ena =         delay; //delay[7];

  // === Combinational flags ===
  always_comb begin
  if(rst) begin 
  buf_empty<= 0;
  buf_full <=0;
//  mem    <= '{default: 0};
  buf_mem <= '{default: 0};
  end
  else begin
    buf_empty = (wr_ptr == rd_ptr);
    buf_full  = ((wr_ptr[`BUF_WIDTH-1:0] == rd_ptr[`BUF_WIDTH-1:0]) && (wr_ptr[`BUF_WIDTH] != rd_ptr[`BUF_WIDTH]));
  end
  end

always_ff @(posedge baud_clk) begin
   do_it_pls <= do_it;
end

  // === Write logic ===
  always_ff @(posedge baud_clk or posedge rst) begin
    if (rst) begin
     wr_ptr <=0;
      end
    else if (wr_ena && !buf_full && do_it) begin
      buf_mem[wr_ptr[`BUF_WIDTH-1:0]] <= buf_in;
          
            wr_ptr <= wr_ptr + 1;
   
   end
  end

  // === Read logic ===
  always_ff @(posedge baud_clk or posedge rst) begin
    if (rst) begin
      rd_ptr <= 0;
      buf_out <= 0;
    end else if (rd_en && !buf_empty) begin
      buf_out <= {buf_mem[rd_ptr[`BUF_WIDTH-1:0]]};
    //  mem    <={buf_mem[rd_ptr[`BUF_WIDTH-1:0]],mem[55:8]}
      rd_ptr <= rd_ptr + 1;
    end
  
end

endmodule


   //end
endmodule

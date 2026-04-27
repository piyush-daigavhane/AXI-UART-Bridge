
 

`timescale 1ns/1ps

module top(
 input clk,
 input rst,
 input rx_bit,
 input aWREADY,
 input wREADY,
 input ARREADY,
 input RREADY
 );

reg   [7:0]   buf_in;
reg           baud_clk;
wire          wr_en;
reg   [7:0]   buf_out;
wire          do_it;
wire          rd_en;
wire          buf_empty;
wire          buf_full;
wire          full;
wire [7:0]    data_in;
wire          unsyn_we;
wire [3:0]    AWID;
wire [31:0]   ADDR;
wire [1:0]    Burst_ty;
wire [2:0]    Burst_size;
wire [3:0]    Burst_len;
wire          read_en;  //asyn_fifo read_en
wire [7:0]    fifo_data;
wire          o_rempty;
wire          burst_start;

wire          wvalid;
wire          wstrb;
wire          wready;
wire [31:0]   wdata;
wire          wlast;
wire          address_valid;
wire [3:0]    ARLEN;
wire          RVALID;
wire  [31:0]  RDATA;
wire  [31:0]  tx_data;
wire          tx_full;
wire          tx_read_en;
wire          tx_fifo_empty;

unwrapper unwrap (
  .rst(rst),
  .rx_bit(rx_bit),
  .payload_out(buf_in),
  .baud_clk(baud_clk),
  .wr_en(wr_en),
  .do_it(do_it),
  .full(full),
  .data_out(data_in),
  .unsyn_we(unsyn_we),
  .burst_start(burst_start),
  .burst_len(Burst_len),
  .burst_size(Burst_size)
);
 

clk2baud baud(
  .clk(clk), 
  .rst(rst),
  .baud_clk(baud_clk)
);

Sync_FIFO fifo(
  .baud_clk(baud_clk),
  .rst(rst),
  .wr_en(wr_en),
  .buf_in(buf_in),
  .buf_out(buf_out),
  .do_it(do_it),
  .rd_en(rd_en),
  .buf_empty(buf_empty),
  .buf_full(buf_full)
);

copy_fifo copy(
  .baud_clk(baud_clk),
  .rst(rst),
  .buf_out(buf_out),
  .rd_en(rd_en),
  .buf_empty(buf_empty),
  .AWID(AWID),
  .Burst_size(Burst_size),
  .Burst_len(Burst_len),
  .Burst_ty(Burst_ty),
  .ADDR(ADDR)
);

afifo asyn_fifo(
.baud_clk(baud_clk),
.wrst(rst),
.full(full),
.data_in(data_in),
.unsyn_we(unsyn_we),
.i_rrst_n(rst),
.i_rclk(clk),
.i_rd(read_en),
.o_rdata(fifo_data),
.o_rempty(o_rempty)
);

rx_as_fifo rx_fifo(
.wrst(rst),
.RDATA(RDATA),
.unsyn_we(RVALID),
.clk(clk),

.baud_clk(baud_clk),
.i_rrst_n(rst),
.rx_data(tx_data),
.o_rempty(tx_fifo_empty),
.i_rd(tx_read_en)
);

uart_tx tx(
  .baud_clk(baud_clk),
  .rst(rst),
  .tx_data(tx_data),
  .fifo_empty(tx_fifo_empty),
  .tx_read_en(tx_read_en)
);

burst_incr incr (
 .clk(clk),
 .rst(rst),
 .start_address(ADDR),
 .burst_size(Burst_size),
 .burst_len(Burst_len),
 .burst_type(Burst_ty),
 .o_rempty(o_rempty),
 .fifo_data(fifo_data),
 .read_en(read_en),
 .burst_start(burst_start),
 .wdata(wdata),
 .wstrb(wstrb),
 .wvalid(wvalid),
 .wlast(wlast),
 .wready(wREADY)
);

slave_mem slave(
  .clk(clk),
  .rst(rst),
  .wr_en(wvalid),
  .buf_in(wdata),
  .ARLEN(ARLEN),
  .RREADY(RREADY),
  .RVALID(RVALID),
  .slave_data(RDATA)
);

address_read  adread(
.baud_clk(baud_clk),
.rst(rst),
.buf_out(buf_out),
.buf_empty(buf_empty),
.ARREADY(ARREADY),
.ARLEN(ARLEN)
);



channel cha(
 .AWID_r(AWID),
 .ADDR_r(ADDR),
 .Burst_ty(Burst_ty),
 .Burst_size(Burst_size),
 .Burst_len(Burst_len),
 .AWREADY(aWREADY),
 .wdata(wdata),
 .wstrb(wstrb),
 .WVALID(wvalid),
 .wlast(wlast),
 .WREADY(wREADY),
 .AWVALID(AWVALID),
 .address_val(AWVALID)
);

endmodule

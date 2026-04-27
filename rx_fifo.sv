module rx_as_fifo #(  parameter DSIZE = 32, parameter ASIZE = 6  )(

    input  wire              clk,
    input  wire              wrst,
    input  wire              unsyn_we,
    input  wire [DSIZE-1:0]  RDATA,
    output reg               full,
    input  wire              baud_clk,
    input  wire              i_rrst_n,
    input  wire              i_rd,
    output wire [DSIZE-1:0]  rx_data,
    output reg               o_rempty

);

 localparam DW = DSIZE;
 localparam AW = ASIZE;

 reg [DW-1:0] mem [0:(1<<AW)-1];
         
 reg [AW:0] wbin, wgray;
 wire [AW:0] wbinnext, wgraynext;
 reg [AW:0] wq1_rgray, wq2_rgray;

 reg [AW:0] rbin, rgray;
 wire [AW:0] rbinnext, rgraynext;
 reg [AW:0] rq1_wgray, rq2_wgray;

 wire [AW-1:0] waddr = wbin[AW-1:0];
 wire wfull_next;

 wire [AW-1:0] raddr = rbin[AW-1:0];
 wire rempty_next;

 // WRITE DOMAIN
always @(posedge clk or posedge wrst)
    if (wrst)
        { wq2_rgray, wq1_rgray } <= 0;
    else
        { wq2_rgray, wq1_rgray } <= { wq1_rgray, rgray };

assign wbinnext  = wbin + ( (unsyn_we && !full) ? 1 : 0 );
assign wgraynext = (wbinnext >> 1) ^ wbinnext;   // Gray encoding

always @(posedge clk or posedge wrst)
    if (wrst)
        { wbin, wgray } <= 0;
    else
        { wbin, wgray } <= { wbinnext, wgraynext };

// Full detection (Gray pointer comparison)
assign wfull_next = (wgraynext == { ~wq2_rgray[AW:AW-1], wq2_rgray[AW-2:0] });

always @(posedge clk or posedge wrst)
    if (wrst)
        full <= 1'b0;
    else
        full <= wfull_next;

always @(posedge clk or posedge wrst)
    if(wrst) begin
        mem = '{default: 0};
    end
    else if (unsyn_we && !full)
        mem[waddr] <= RDATA;

 // READ DOMAIN
always @(posedge baud_clk or posedge i_rrst_n)
    if (i_rrst_n)
        { rq2_wgray, rq1_wgray } <= 0;
    else
        { rq2_wgray, rq1_wgray } <= { rq1_wgray, wgray };

assign rbinnext  = rbin + ( (i_rd && !o_rempty) ? 1 : 0 );
assign rgraynext = (rbinnext >> 1) ^ rbinnext;   // Gray encoding

always @(posedge baud_clk or posedge i_rrst_n)
    if (i_rrst_n)
        { rbin, rgray } <= 0;
    else
        { rbin, rgray } <= { rbinnext, rgraynext };

// Empty detection
assign rempty_next = (rgraynext == rq2_wgray);

always @(posedge baud_clk or posedge i_rrst_n)
    if (i_rrst_n)
        o_rempty <= 1'b1;
    else
        o_rempty <= rempty_next;

assign rx_data = mem[raddr];

endmodule

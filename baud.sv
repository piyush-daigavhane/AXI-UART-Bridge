`timescale 1ns/ 1ps
module clk2baud #(parameter clk_freq = 200000000,
                  parameter baud_rate = 9600)
(
   input clk,
   input rst,
   output reg baud_clk
);

localparam divisor= clk_freq/(baud_rate * 16);
localparam half_divisor = divisor/2;
reg [$clog2(divisor)-1:0] counter;

always_ff @(posedge clk or posedge rst) begin
       if(rst) begin
           baud_clk <=0;
           counter  <=0;
         end 
       else if(counter == divisor-1) begin
          counter <=0;
         end 
       else begin
         counter <= counter+1;
         if(counter <= half_divisor)
                baud_clk <=1;
         else 
		baud_clk <=0;
         end
   end
endmodule


   

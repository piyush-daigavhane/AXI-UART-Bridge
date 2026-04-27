`timescale 1ns/1ps
module tb;

logic clk;
logic rx_bit;
logic baud_clk1;
logic rst;
logic [7:0] rand_n;
logic aWREADY;
logic wREADY;
logic ARREADY;
logic RREADY;
initial begin
   clk=0;
   forever #5 clk= ~clk;
end

top dut(
  .clk(clk),
  .rst(rst),
  .rx_bit(rx_bit),
  .aWREADY(aWREADY),
  .wREADY(wREADY),
  .ARREADY(ARREADY),
  .RREADY(RREADY)
);

assign baud_clk1 = dut.baud_clk;

initial begin
    rst = 1;
    rx_bit = 1;  
    aWREADY <= 1'b0;
    wREADY  <= 1'b0;
    ARREADY <= 1'b0;
    RREADY  <= 1'B0;
    #10;
    rst = 0;
    #10;
    rx_bit=0;
    aWREADY <= 1'b1;
    wREADY  <= 1'b1;
    ARREADY <= 1'b1;
    RREADY  <= 1'B1;
  end

task send_uart_frame(input [10:0] frame);
    integer i;
    begin
      for (i = 0; i < 12; i++) begin
        @(posedge baud_clk1);
        rx_bit = frame[i]; 
    end
    rx_bit=1;
    end
  endtask

initial begin

    @(negedge baud_clk1 or negedge rst); 
     send_uart_frame({2'b11, 8'b00000000, 1'b0});
          //#1;
     send_uart_frame({2'b11, 8'b00010101, 1'b0});
     
       
     send_uart_frame({2'b11, 8'b00011100, 1'b0});
     send_uart_frame({2'b11, 8'b00010010, 1'b0});
    //#1;
     send_uart_frame({2'b11, 8'b00000100, 1'b0});
    // #1;
     send_uart_frame({2'b11, 8'b10010000, 1'b0});
     //#1;
     send_uart_frame({2'b11, 8'b00001110, 1'b0});
     //#1;
     send_uart_frame({2'b11, 8'b00000000, 1'b0});
     
     repeat(34) begin
     rand_n = $random();
     send_uart_frame({2'b11, rand_n,1'b0});
     end
      send_uart_frame({2'b11, 8'b10000000, 1'b0});
          //#1;
     send_uart_frame({2'b11, 8'b10010101, 1'b0});
     
       
     send_uart_frame({2'b11, 8'b10011100, 1'b0});
     send_uart_frame({2'b11, 8'b10010010, 1'b0});
    //#1;
     send_uart_frame({2'b11, 8'b10000100, 1'b0});
    // #1;
     send_uart_frame({2'b11, 8'b10010000, 1'b0});
     //#1;
     send_uart_frame({2'b11, 8'b00001110, 1'b0});
     //#1;
     send_uart_frame({2'b11, 8'b10000000, 1'b0});

      repeat(34) begin
     rand_n = $random();
     send_uart_frame({2'b11, rand_n,1'b0});
     end
  
    
 #2500000;

$finish;

end

  
//  initial begin
   
//    @(negedge baud_clk1 or negedge rst);
//    repeat (5) begin
//    rand_n = $random(); 
//    send_uart_frame({2'b11, rand_n, 1'b0});
//    $display("value of random value n = %0d", rand_n);
 //   end 
//    
    
   


   //end
endmodule

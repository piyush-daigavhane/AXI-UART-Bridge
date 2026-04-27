`timescale 1ns/1ps

module unwrapper (
    input  logic       baud_clk,        
    input  logic       rst,           
    input  logic       rx_bit,  
    input  logic       full,        
    output logic [7:0] payload_out,     
    output logic       payload_valid,   
    output logic        wr_en,
    output logic       do_it,
    output logic       unsyn_we,
    output logic [7:0] data_out,
    output logic       burst_start,

    input logic  [3:0] burst_len,
    input logic  [2:0] burst_size 
);

    typedef enum logic [1:0] {
        IDLE,RECEIVE, CHECK
    } state_t;

    state_t state;
    state_t nxt_state;
    logic [4:0] bit_count;              
    logic [9:0] shift_reg; 
    logic frame_error;
    logic [7:0] frame_count;
    logic    switch;
    logic   [7:0] total_frame;

assign total_frame = ((burst_len+1) * (1 << burst_size) )+10; 
   
always_comb begin
	state <= nxt_state;
end 

    always_ff @(posedge baud_clk or posedge rst) begin
      if (rst) begin
            //state         <= IDLE;
		nxt_state <= IDLE;
            bit_count     <= 4'b0;
            shift_reg     <= 10'b0;
            payload_out   <= 8'b0;
            payload_valid <= 1'b0;
            frame_error   <= 1'b0; 
            wr_en         <= 1'b1;
	    do_it         <= 1'b0;
            frame_count   <= 128'b0;
	    switch        <= 1'b0;
            data_out      <= 8'b0;
	    unsyn_we      <= 1'b0;
	    burst_start   <= 1'b0;	
        end
    else begin
            payload_valid <= 1'b0;
            frame_error   <= 1'b0;
      case (state) 
                IDLE: begin
                  if (rx_bit == 1'b0) begin
                        shift_reg   <= 10'b0;
                        bit_count   <=  4'd0;
                        nxt_state       <= RECEIVE;
                        wr_en       <=1'b0;
                      
                  end
                end

                RECEIVE: begin
                  shift_reg <= {rx_bit,shift_reg[9:1]};  // only adding stop bit in the shift reg not the start bit
                       bit_count <= bit_count + 1;        
                   
                  if (bit_count == 4'd9) begin           // counting till 10, so payload + stop bits are in shift reg
                         nxt_state <= CHECK;
                         frame_count <= frame_count+1;
                         do_it <=1'b0;	
                         if(frame_count > 128'd8 && frame_count < (total_frame ))  begin  unsyn_we  <=1'b1; end
                         else       begin         wr_en     <=1'b1; end
                          		
                  end
                end
                     
                CHECK : begin   
                  if(shift_reg[9:8]==2'b11) begin         // check if last two bits in shift reg are 11                  
                   
                        if (frame_count > 128'd8 && !full && switch) begin
                                 data_out[7:0]  <=  shift_reg[7:0];
				   unsyn_we       <=  1'b0;	
				   burst_start  <= 1'b1;	
                         	end
                        else begin
                                 payload_out[7:0]   <= shift_reg[7:0]; 
                                 wr_en  <= 1'b0;
		                 do_it <= 1'b1;
			   end
			end
                  else begin
                    frame_error <=1'b1;
                  end
                  nxt_state <= IDLE;
                end
      endcase
    end
    if(frame_count == 128'd8) begin
       switch <= 1'b1;

    end
    if(frame_count == total_frame) begin
       burst_start <=1'b0;
       switch <= 1'b0;
       frame_count <=1'b0;
    end

end
endmodule
      
                  
                  

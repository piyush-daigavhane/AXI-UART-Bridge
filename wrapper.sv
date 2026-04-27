module uart_tx_fsm (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [31:0] fifo_data,
  input  logic        fifo_empty,
  output logic        read_en,
  output logic [10:0] tx_frame,
  output logic        tx_valid
);

typedef enum logic [2:0] {
  IDLE, READ_FIFO, SEND_BYTE0, SEND_BYTE1, SEND_BYTE2, SEND_BYTE3
} state_t;

state_t state, next_state;
logic [31:0] data_reg;
logic [7:0] current_byte;

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
    data_reg <= 32'h0;
  end else begin
    state <= next_state;
    if (state == READ_FIFO && !fifo_empty)
      data_reg <= fifo_data;
  end
end

always_comb begin
  next_state = state;
  read_en = 1'b0;
  tx_valid = 1'b0;
  current_byte = 8'h0;
  
  case (state)
    IDLE: begin
      if (!fifo_empty) next_state = READ_FIFO;
    end
    
    READ_FIFO: begin
      read_en = 1'b1;
      next_state = SEND_BYTE0;
    end
    
    SEND_BYTE0: begin
      current_byte = data_reg[7:0];
      tx_valid = 1'b1;
      next_state = SEND_BYTE1;
    end
    
    SEND_BYTE1: begin
      current_byte = data_reg[15:8];
      tx_valid = 1'b1;
      next_state = SEND_BYTE2;
    end
    
    SEND_BYTE2: begin
      current_byte = data_reg[23:16];
      tx_valid = 1'b1;
      next_state = SEND_BYTE3;
    end
    
    SEND_BYTE3: begin
      current_byte = data_reg[31:24];
      tx_valid = 1'b1;
      next_state = IDLE;
    end
  endcase
end

assign tx_frame = {2'b11, current_byte, 1'b0}; // stop bits + data + start bit

endmodule

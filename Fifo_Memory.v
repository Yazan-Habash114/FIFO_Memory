module fifo_memory(
  input wire wr,
  input wire rd,
  input wire clk,
  input wire rst_n,
  input wire [7:0] data_in,
  output reg [7:0] data_out,
  output fifo_full,
  output fifo_empty, 
  output fifo_threshold,
  output fifo_underflow,
  output fifo_overflow
);

  // Function to find the next value of the current write index value but if 4 bit width
  function automatic [3:0] find_next_write(input [3:0] write_ptr);
    find_next_write = write_ptr + 1'b1;
  endfunction

  localparam [3:0] THRESHOLD = 4'd7;
  reg [3:0] threshold_counter = 4'b0;
  reg [7:0] mem [16];
  reg [3:0] read_index = 1'b0;
  reg [3:0] write_index = 1'b0;


  assign fifo_full = find_next_write(write_index) == read_index ? 1'b1 : 1'b0;
  assign fifo_empty = (read_index == write_index) ? 1'b1 : 1'b0;
  assign fifo_threshold = (threshold_counter < THRESHOLD) ? 1'b1 : 1'b0;
  assign fifo_underflow = (fifo_empty && rd)  ? 1'b1 : 1'b0;
  assign fifo_overflow = (fifo_full && wr)  ? 1'b1 : 1'b0;


  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      write_index <= 1'b0;
      read_index <= 1'b0;
      data_out <= 8'bxxxx_xxxx;
      threshold_counter <= 4'd0;
    end else begin
      if(rd == 1'b1 && ~fifo_empty) begin
        data_out <= mem[read_index];
        mem[read_index] <= 8'bxxxx_xxxx;
        read_index <= read_index +1'b1;
        threshold_counter <= threshold_counter - 1'b1;
      end else if(wr == 1'b1 && ~fifo_full)begin
        mem[write_index] <= data_in;
        write_index <= write_index +1'b1;
        threshold_counter <= threshold_counter + 1'b1;
      end

      if(fifo_overflow &&  mem[write_index] === 8'bxxxxxxxx) begin
        mem[write_index] <= data_in;
        threshold_counter <= 4'd15;
      end

      if(fifo_underflow && mem[read_index] === 8'bxxxxxxxx) begin
        data_out <= 8'bxxxx_xxxx;    
      end else begin 
        data_out <= mem[read_index];
        if (fifo_empty) begin
          threshold_counter <= 4'd0;
        end
      end
    end
  end
endmodule

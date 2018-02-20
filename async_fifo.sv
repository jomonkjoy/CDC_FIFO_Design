module async_fifo_dpram #(
  parameter ADDR_WIDTH = 3,
  parameter DATA_WIDTH = 8
) (
  input  logic                  clk,
  input  logic                  wen,
  input  logic [ADDR_WIDTH-1:0] waddr,
  input  logic [DATA_WIDTH-1:0] wdata,
  input  logic [ADDR_WIDTH-1:0] raddr,
  output logic [DATA_WIDTH-1:0] rdata
);
  
  localparam ADDR_DEPTH = 2**ADDR_WIDTH;
  logic [DATA_WIDTH-1:0] mem[ADDR_DEPTH];
  
  always_ff @(posedge clk) begin
    if (wen) begin
      mem[waddr] <= wdata;
    end
  end
  
  assign rdata = mem[raddr];
  
endmodule

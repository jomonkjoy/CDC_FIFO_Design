//  1-deep / 2-register FIFO synchronizer
module multibit_fifo_sync #(
  parameter DATA_WIDTH = 32
) (
  input  logic                  aclk,
  input  logic                  areset,
  input  logic                  avalid,
  input  logic [DATA_WIDTH-1:0] adata,
  output logic                  aready,
  input  logic                  bclk,
  input  logic                  breset,
  output logic                  bvalid,
  output logic [DATA_WIDTH-1:0] bdata,
  input  logic                  bready
);

endmodule

module multibit_fifo_dpram #(
  parameter DATA_WIDTH = 8
) (
  input  logic                  clk,
  input  logic                  wen,
  input  logic                  waddr,
  input  logic [DATA_WIDTH-1:0] wdata,
  input  logic                  raddr,
  output logic [DATA_WIDTH-1:0] rdata
);
  
  logic [DATA_WIDTH-1:0] mem[0:1];
  
  always_ff @(posedge clk) begin
    if (wen) begin
      mem[waddr] <= wdata;
    end
  end
  
  assign rdata = mem[raddr];
  
endmodule

module multibit_fifo_double_sync (
  input  logic clk,
  input  logic reset,
  input  logic d,
  output logic q
);
  
  logic q0;
  // Double Sync-Single-bit-CDC
  always_ff @(posedge clk) begin
    if (reset) begin
      {q,q0} <= '0;
    end else begin
      {q,q0} <= {q0,d};
    end
  end
  
endmodule

module async_fifo_dpram #(
  parameter ADDR_WIDTH = 3,
  parameter DATA_WIDTH = 8
) (
  input  logic                  wclk,
  input  logic                  wreset,
  input  logic                  wen,
  input  logic [DATA_WIDTH-1:0] wdata,
  output logic                  wfull,
  input  logic                  rclk,
  input  logic                  rreset,
  input  logic                  ren,
  output logic [DATA_WIDTH-1:0] rdata,
  output logic                  rempty
);
  
  logic [ADDR_WIDTH-0:0] wptr,rptr;
  logic [ADDR_WIDTH-0:0] r_wptr,w_rptr;
  logic [ADDR_WIDTH-1:0] waddr,raddr;
  
  gray_sync #( .SYNC_STAGE (SYNC_STAGE) ) gray_sync_wptr (
    .clk  (rclk), .din  (wptr), .dout (r_wptr) );
  
  gray_sync #( .SYNC_STAGE (SYNC_STAGE) ) gray_sync_rptr (
    .clk  (wclk), .din  (rptr), .dout (w_rptr) );
  
  async_fifo_dpram #( .ADDR_WIDTH (ADDR_WIDTH), .DATA_WIDTH (DATA_WIDTH) ) async_fifo_dpram (
    .clk(wclk), .wen(wincr), .waddr(waddr), .wdata(wdata), .raddr(raddr), .rdata(rdata) );
  
endmodule

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
// Data-Sync : synchronize single-bit data
// Min 3 stage pipeline to mitegate metastability due to setup and hold time violations
// use ASYNC_REG and max_delay[with min-period(freq1,freq2)] constraint with async-clock groups {clk1,clk2}
module data_sync #(
  parameter SYNC_STAGE = 3
) (
  input  logic clk,
  input  logic din,
  output logic dout
);
  
  (* ASYNC_REG = "TRUE" *) 
  logic [SYNC_STAGE-1:0] sync_reg;
  always_ff @(posedge clk) begin
    sync_reg <= {sync_reg[SYNC_STAGE-2:0],din};
  end
  assign dout = sync_reg[SYNC_STAGE-1];
  
endmodule
// gray-code synchronizer using Data-Sync
module gray_sync #(
  parameter DATA_WIDTH = 4,
  parameter SYNC_STAGE = 3
) (
  input  logic clk,
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
);
  
  generate for(genvar i=0; i<DATA_WIDTH; i++) begin : gen_sync
    data_sync #(
      .SYNC_STAGE (SYNC_STAGE)
    ) data_sync (
      .clk  (clk), 
      .din  (din[i]),
      .dout (dout[i])
    );
  end endgenerate
  
endmodule

module sync_fifo #(
  parameter int SYNC_STAGE = 3,
  parameter int ADDR_WIDTH = 3,
  parameter int DATA_WIDTH = 8
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
  logic wincr,rincr;
  // write/read increment logic
  assign wincr = wen & ~wfull;
  assign rincr = ren & ~rempty;
  // Write-domain to read-domain synchronizer
  gray_sync #( .DATA_WIDTH (ADDR_WIDTH+1), .SYNC_STAGE (SYNC_STAGE) ) gray_sync_wptr (
    .clk  (rclk), .din  (wptr), .dout (r_wptr) 
  );
  // Read-domain to write-domain synchronizer
  gray_sync #( .DATA_WIDTH (ADDR_WIDTH+1), .SYNC_STAGE (SYNC_STAGE) ) gray_sync_rptr (
    .clk  (wclk), .din  (rptr), .dout (w_rptr) 
  );
  // FIFO dualport memory buffer
  async_fifo_dpram #( .ADDR_WIDTH (ADDR_WIDTH), .DATA_WIDTH (DATA_WIDTH) ) async_fifo_dpram (
    .clk(wclk), .wen(wincr), .waddr(waddr), .wdata(wdata), .raddr(raddr), .rdata(rdata) 
  );
  // Read pointer & empty generation logic
  rptr_empty #( .ADDR_WIDTH (ADDR_WIDTH) ) rptr_empty (
    .clk(rclk), .reset(rreset), .rincr(rincr), .r_wptr(r_wptr), .rptr(rptr), .raddr(raddr), .rempty(rempty) 
  );
  // Write pointer & full generation logic
  wptr_full #( .ADDR_WIDTH (ADDR_WIDTH) ) wptr_full (
    .clk(wclk), .reset(wreset), .wincr(wincr), .w_rptr(w_rptr), .wptr(wptr), .waddr(waddr), .wfull(wfull) 
  );
  
endmodule

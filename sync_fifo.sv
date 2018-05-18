module sync_fifo_core #(
  parameter int SYNC_STAGE = 3,
  parameter int ADDR_WIDTH = 3,
  parameter int DATA_WIDTH = 8
) (
  input  logic                  clk,
  input  logic                  reset,
  input  logic                  wen,
  input  logic [DATA_WIDTH-1:0] wdata,
  output logic                  wfull,
  input  logic                  ren,
  output logic [DATA_WIDTH-1:0] rdata,
  output logic                  rempty
);
  
  logic [ADDR_WIDTH-0:0] wptr,rptr;
  logic [ADDR_WIDTH-1:0] waddr,raddr;
  logic wincr,rincr;
  // write/read increment logic
  assign wincr = wen & ~wfull;
  assign rincr = ren & ~rempty;
  // FIFO dualport memory buffer
  sync_fifo_dpram #( .ADDR_WIDTH (ADDR_WIDTH), .DATA_WIDTH (DATA_WIDTH) ) sync_fifo_dpram (
    .clk(clk), .wen(wincr), .waddr(waddr), .wdata(wdata), .raddr(raddr), .rdata(rdata) 
  );
  // Read pointer & empty generation logic
  rptr_empty #( .ADDR_WIDTH (ADDR_WIDTH) ) rptr_empty (
    .clk(clk), .reset(reset), .rincr(rincr), .wptr(wptr), .rptr(rptr), .raddr(raddr), .rempty(rempty) 
  );
  // Write pointer & full generation logic
  wptr_full #( .ADDR_WIDTH (ADDR_WIDTH) ) wptr_full (
    .clk(clk), .reset(reset), .wincr(wincr), .rptr(rptr), .wptr(wptr), .waddr(waddr), .wfull(wfull) 
  );
  
endmodule

module sync_fifo_dpram #(
  parameter int ADDR_WIDTH = 3,
  parameter int DATA_WIDTH = 8
) (
  input  logic                  clk,
  input  logic                  wen,
  input  logic [ADDR_WIDTH-1:0] waddr,
  input  logic [DATA_WIDTH-1:0] wdata,
  input  logic [ADDR_WIDTH-1:0] raddr,
  output logic [DATA_WIDTH-1:0] rdata
);
  
  localparam ADDR_DEPTH = 2**ADDR_WIDTH;
  // instantiation of a vendor's dual-port RAM
  (* ram_style = "distributed" *)
  logic [DATA_WIDTH-1:0] mem[ADDR_DEPTH];
  
  always_ff @(posedge clk) begin
    if (wen) begin
      mem[waddr] <= wdata;
    end
  end
  
  assign rdata = mem[raddr];
  
endmodule

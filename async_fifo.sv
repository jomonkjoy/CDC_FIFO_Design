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
  logic wincr,rincr;
  // write/read increment logic
  assign wincr = wen & ~wfull;
  assign rincr = ren & ~rempty;
  // Write-domain to read-domain synchronizer
  gray_sync #( .SYNC_STAGE (SYNC_STAGE) ) gray_sync_wptr (
    .clk  (rclk), .din  (wptr), .dout (r_wptr) 
  );
  // Read-domain to write-domain synchronizer
  gray_sync #( .SYNC_STAGE (SYNC_STAGE) ) gray_sync_rptr (
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

module rptr_empty #( 
  parameter ADDR_WIDTH = 4 
) (
  input  logic clk,
  input  logic reset,
  input  logic rincr,
  input  logic [ADDR_WIDTH-0:0] r_wptr,
  output logic [ADDR_WIDTH-0:0] rptr,
  output logic [ADDR_WIDTH-1:0] raddr,
  output logic rempty
);
  
  logic rempty_val;
  logic [ADDR_WIDTH:0] rbin;
  logic [ADDR_WIDTH:0] rgraynext, rbinnext;
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      rbin <= {ADDR_WIDTH+1{1'b0}};
      rptr <= {ADDR_WIDTH+1{1'b0}};
    end else begin
      rbin <= rbinnext;
      rptr <= rgraynext;
    end
  end
  
  assign raddr      = rbin[ADDR_WIDTH-1:0];
  assign rbinnext   = rbin + rincr;
  assign rgraynext  = (rbinnext>>1) ^ rbinnext;
  assign rempty_val = (rgraynext == r_wptr);
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      rempty <= 1'b1;
    end else begin
      rempty <= rempty_val;
    end
  end
  
endmodule

module wptr_full #( 
  parameter ADDR_WIDTH = 4 
) (
  input  logic clk,
  input  logic reset,
  input  logic wincr,
  input  logic [ADDR_WIDTH-0:0] w_rptr,
  output logic [ADDR_WIDTH-0:0] wptr,
  output logic [ADDR_WIDTH-1:0] waddr,
  output logic wfull
);
  
  logic wfull_val;
  logic [ADDR_WIDTH:0] wbin;
  logic [ADDR_WIDTH:0] wgraynext, wbinnext;
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      wbin <= {ADDR_WIDTH+1{1'b0}};
      wptr <= {ADDR_WIDTH+1{1'b0}};
    end else begin
      wbin <= wbinnext;
      wptr <= wgraynext;
    end
  end
  
  assign waddr     = wbin[ADDR_WIDTH-1:0];
  assign wbinnext  = wbin + wincr;
  assign wgraynext = (wbinnext>>1) ^ wbinnext;
  assign wfull_val = (wgraynext=={~w_rptr[ADDR_WIDTH:ADDR_WIDTH-1], w_rptr[ADDR_WIDTH-2:0]});
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      wfull <= 1'b0;
    end else begin
      wfull <= wfull_val;
    end
  end
  
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

module axis_downsizer #(
  parameter int ADDR_WIDTH = 4,
  parameter int DATA_WIDTH = 8,
  parameter int DATA_RATIO = 8,
  parameter int M_DATA_WIDTH = DATA_WIDTH,
  parameter int S_DATA_WIDTH = DATA_RATIO*DATA_WIDTH
  ) (
  input  logic                    aclk,
  input  logic                    areset,
  
  input  logic [S_DATA_WIDTH-1:0] s_axis_tdata,
  input  logic                    s_axis_tvalid,
  input  logic                    s_axis_tlast,
  output logic                    s_axis_tready,
  
  output logic [M_DATA_WIDTH-1:0] m_axis_tdata,
  output logic                    m_axis_tvalid,
  output logic                    m_axis_tlast,
  input  logic                    m_axis_tready
  );
  
  localparam int MSEL_WIDTH = $clog2(DATA_RATIO);
  logic [MSEL_WIDTH-1:0] mux_sel;
  logic [DATA_RATIO-1:0] wen;
  logic [DATA_WIDTH-1:0] wdata[DATA_RATIO];
  logic [DATA_RATIO-1:0] wfull;
  logic [DATA_RATIO-1:0] ren;
  logic [DATA_WIDTH-1:0] rdata[DATA_RATIO];
  logic [DATA_RATIO-1:0] rempty;
  
  assign s_axis_tready = ~(|wfull);
  assign m_axis_tvalid = ~(|rempty);
  assign m_axis_tdata = rdata[mux_sel];
  
  always_ff @(posedge clk) begin
    if (reset) begin
      mux_sel <= {MSEL_WIDTH{1'b0}};
    end else if (mux_sel >= DATA_RATIO-1) begin
      mux_sel <= {MSEL_WIDTH{1'b0}};
    end else begin
      mux_sel <= mux_sel + 1'b1;
    end
  end
  
  generate for(genvar i=0; i<=DATA_RATIO; i++) begin : gen
    sync_fifo_core #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
    ) fifo_core_inst (
      .clk    (clk),
      .reset  (reset),
      .wen    (wen[i]),
      .wdata  (wdata[i]),
      .wfull  (wfull[i]),
      .ren    (ren[i]),
      .rdata  (rdata[i]),
      .rempty (rempty[i])
    );
    assign wen[i] = s_axis_tvalid && s_axis_tready;
    assign ren[i] = mux_sel == i ? m_axis_tvalid && m_axis_tready : 1'b0;
    assign wdata[i] = s_axis_tdata[DATA_WIDTH*i+:DATA_WIDTH];
  end endgenerate
  
endmodule

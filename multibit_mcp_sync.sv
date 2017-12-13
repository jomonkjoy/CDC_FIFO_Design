// Multi-Cycle Path (MCP ) formulation toggle-pulse generation with ready-ack
module multibit_mcp_sync #(
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
  
  logic [DATA_WIDTH-1:0] data;
  // Transmit data sample register
  always_ff @(posedge aclk) begin
    if (avalid && aready) begin
      data <= adata;
    end
  end
  // generate aenable-using toggle-FF
  logic aenable,benable;
  always_ff @(posedge aclk) begin
    if (areset) begin
      aenable <= 1'b0;
    end else begin
      aenable <= aenable ^ (avalid & aready);
    end
  end
  // Receive data sample register
  always_ff @(posedge bclk) begin
    if (bvalid && bready) begin
      bdata <= data;
    end
  end
  // generate back-using toggle-FF
  logic aack,back;
  always_ff @(posedge bclk) begin
    if (breset) begin
      back <= 1'b0;
    end else begin
      back <= back ^ (bvalid & bready);
    end
  end
  // Transmit FSM
  multibit_mcp_tx_fsm
  multibit_mcp_tx_fsm_inst (
    .clk(aclk),
    .reset(areset),
    .valid(avalid),
    .ack(aack),
    .ready(aready)
  );
  // Receive FSM
  multibit_mcp_rx_fsm
  multibit_mcp_rx_fsm_inst (
    .clk(bclk),
    .reset(breset),
    .enable(benable),
    .ready(bready),
    .valid(bvalid)
  );
  // Sync back to aclk
  multibit_mcp_double_sync_pulsegen
  multibit_mcp_double_sync_pulsegen_aack (
    .clk(aclk),
    .reset(areset),
    .d(back),
    .p(aack)
  );
  // Sync aenable to benable
  multibit_mcp_double_sync_pulsegen
  multibit_mcp_double_sync_pulsegen_benable (
    .clk(bclk),
    .reset(breset),
    .d(aenable),
    .p(benable)
  );
  
endmodule

module multibit_mcp_tx_fsm (
  input  logic clk,
  input  logic reset,
  input  logic valid,
  input  logic ack,
  output logic ready
);
  
  enum logic {IDLE=1'b1,BUSY=1'b0} state;
  
  always_ff @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
    end else begin
      case (state) // parallel_case
        IDLE : state <= valid ? BUSY : IDLE;
        BUSY : state <= ack   ? IDLE : BUSY;
      endcase
    end
  end
  
  assign ready = state;
  
endmodule

module multibit_mcp_rx_fsm (
  input  logic clk,
  input  logic reset,
  input  logic enable,
  input  logic ready,
  output logic valid
);
  
  enum logic {IDLE=1'b0,VALID=1'b1} state;
  
  always_ff @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
    end else begin
      case (state) // parallel_case
        IDLE  : state <= enable ? VALID : IDLE;
        VALID : state <= ready  ? IDLE  : VALID;
      endcase
    end
  end
  
  assign valid = state;
  
endmodule

module multibit_mcp_double_sync_pulsegen (
  input  logic clk,
  input  logic reset,
  input  logic d,
  output logic p
);
  
  logic q0,q;
  logic q_r;
  // Double Sync-Single-bit-CDC
  always_ff @(posedge clk) begin
    if (reset) begin
      {q,q0} <= '0;
    end else begin
      {q,q0} <= {q0,d};
    end
  end
  // Pulse generator
  always_ff @(posedge clk) begin
    if (reset) begin
      q_r <= '0;
    end else begin
      q_r <= q;
    end
  end
  assign p = q^q_r;
  
endmodule

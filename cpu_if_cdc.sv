module cpu_if_cdc #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input  logic                  cpu_s_clk,
  input  logic                  cpu_s_reset,
  input  logic                  cpu_s_write,
  input  logic                  cpu_s_read,
  input  logic [ADDR_WIDTH-1:0] cpu_s_address,
  input  logic [DATA_WIDTH-1:0] cpu_s_write_data,
  output logic [DATA_WIDTH-1:0] cpu_s_read_data,
  output logic                  cpu_s_access_ready,
  output logic                  cpu_s_access_complete,
  
  input  logic                  cpu_m_clk,
  input  logic                  cpu_m_reset,
  output logic                  cpu_m_write,
  output logic                  cpu_m_read,
  output logic [ADDR_WIDTH-1:0] cpu_m_address,
  output logic [DATA_WIDTH-1:0] cpu_m_write_data,
  input  logic [DATA_WIDTH-1:0] cpu_m_read_data,
  input  logic                  cpu_m_access_ready,
  input  logic                  cpu_m_access_complete
);
  
  logic cpu_s_access_valid;
  logic cpu_m_access_valid;
  
  multibit_mcp_sync #(
    .DATA_WIDTH (ADDR_WIDTH+DATA_WIDTH+1)
  ) sync_request (
    .aclk   (cpu_s_clk),
    .areset (cpu_s_reset),
    .avalid (cpu_s_access_valid),
    .adata  ({cpu_s_write,cpu_s_address,cpu_s_write_data}),
    .aready (cpu_s_access_ready),
    .bclk   (cpu_m_clk),
    .breset (cpu_m_reset),
    .bvalid (cpu_m_access_valid),
    .bdata  ({cpu_m_write,cpu_m_address,cpu_m_write_data}),
    .bready (cpu_m_access_ready)
  );
  
  assign cpu_s_access_valid = cpu_s_write|cpu_s_read;
  assign cpu_m_read = cpu_m_access_valid&(~cpu_m_write);
  
  multibit_mcp_sync #(
    .DATA_WIDTH (DATA_WIDTH)
  ) sync_response (
    .aclk   (cpu_m_clk),
    .areset (cpu_m_reset),
    .avalid (cpu_m_access_complete),
    .adata  (cpu_m_read_data),
    .aready (),
    .bclk   (cpu_s_clk),
    .breset (cpu_s_reset),
    .bvalid (cpu_s_access_complete),
    .bdata  (cpu_s_read_data),
    .bready (1'b1)
  );
  
endmodule

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
  
endmodule

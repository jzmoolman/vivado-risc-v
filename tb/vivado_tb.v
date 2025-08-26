`timescale 1ns / 1ps

module vivado_tb();
  reg  clk;
  reg  mem_ok;
  reg  reset;
  wire out;


  localparam CLK_PERIOD = 10;

  initial clk = 1'b0;
  initial mem_ok = 1'b1;
  initial reset = 1'b0;
  always #(CLK_PERIOD / 2.0) clk = ~clk;

  soc_wrapper_tb dut (
      .clock (clk),
      .mem_ok(mem_ok),
      .reset (reset)
  );

endmodule

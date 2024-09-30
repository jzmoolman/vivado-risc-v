module Adder(
  input  [3:0] auto_in_1, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  input  [3:0] auto_in_0, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  output [3:0] auto_out // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
);
  assign auto_out = auto_in_0 + auto_in_1; // @[src/main/scala/CompileObj.scala 51:55]
endmodule
module MaxPeriodFibonacciLFSR(
  input   clock,
  input   reset,
  output  io_out_0, // @[src/main/scala/chisel3/util/random/PRNG.scala 42:22]
  output  io_out_1, // @[src/main/scala/chisel3/util/random/PRNG.scala 42:22]
  output  io_out_2, // @[src/main/scala/chisel3/util/random/PRNG.scala 42:22]
  output  io_out_3 // @[src/main/scala/chisel3/util/random/PRNG.scala 42:22]
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg  state_0; // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
  reg  state_1; // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
  reg  state_2; // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
  reg  state_3; // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
  wire  _T = state_3 ^ state_2; // @[src/main/scala/chisel3/util/random/LFSR.scala 15:41]
  assign io_out_0 = state_0; // @[src/main/scala/chisel3/util/random/PRNG.scala 78:10]
  assign io_out_1 = state_1; // @[src/main/scala/chisel3/util/random/PRNG.scala 78:10]
  assign io_out_2 = state_2; // @[src/main/scala/chisel3/util/random/PRNG.scala 78:10]
  assign io_out_3 = state_3; // @[src/main/scala/chisel3/util/random/PRNG.scala 78:10]
  always @(posedge clock) begin
    state_0 <= reset | _T; // @[src/main/scala/chisel3/util/random/PRNG.scala 55:{49,49}]
    if (reset) begin // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
      state_1 <= 1'h0; // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
    end else begin
      state_1 <= state_0;
    end
    if (reset) begin // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
      state_2 <= 1'h0; // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
    end else begin
      state_2 <= state_1;
    end
    if (reset) begin // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
      state_3 <= 1'h0; // @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
    end else begin
      state_3 <= state_2;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  state_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  state_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  state_3 = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AdderDriver(
  input        clock,
  input        reset,
  output [3:0] auto_out_1, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  output [3:0] auto_out_0 // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
);
  wire  randomAddend_prng_clock; // @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
  wire  randomAddend_prng_reset; // @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
  wire  randomAddend_prng_io_out_0; // @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
  wire  randomAddend_prng_io_out_1; // @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
  wire  randomAddend_prng_io_out_2; // @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
  wire  randomAddend_prng_io_out_3; // @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
  wire [1:0] randomAddend_lo = {randomAddend_prng_io_out_1,randomAddend_prng_io_out_0}; // @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
  wire [1:0] randomAddend_hi = {randomAddend_prng_io_out_3,randomAddend_prng_io_out_2}; // @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
  MaxPeriodFibonacciLFSR randomAddend_prng ( // @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
    .clock(randomAddend_prng_clock),
    .reset(randomAddend_prng_reset),
    .io_out_0(randomAddend_prng_io_out_0),
    .io_out_1(randomAddend_prng_io_out_1),
    .io_out_2(randomAddend_prng_io_out_2),
    .io_out_3(randomAddend_prng_io_out_3)
  );
  assign auto_out_1 = {randomAddend_hi,randomAddend_lo}; // @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
  assign auto_out_0 = {randomAddend_hi,randomAddend_lo}; // @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
  assign randomAddend_prng_clock = clock;
  assign randomAddend_prng_reset = reset;
endmodule
module AdderMonitor(
  input        clock,
  input        reset,
  input  [3:0] auto_node_sum_in, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  input  [3:0] auto_node_seq_in_1, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  input  [3:0] auto_node_seq_in_0, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  output       io_error // @[src/main/scala/CompileObj.scala 78:16]
);
  wire [3:0] _io_error_T_1 = auto_node_seq_in_0 + auto_node_seq_in_1; // @[src/main/scala/CompileObj.scala 94:79]
  assign io_error = auto_node_sum_in != _io_error_T_1; // @[src/main/scala/CompileObj.scala 94:40]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset) begin
          $fwrite(32'h80000002,"%d + %d = %d",auto_node_seq_in_0,auto_node_seq_in_1,auto_node_sum_in); // @[src/main/scala/CompileObj.scala 91:15]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module AdderTestHarness(
  input   clock,
  input   reset
);
  wire [3:0] adder_auto_in_1; // @[src/main/scala/CompileObj.scala 103:27]
  wire [3:0] adder_auto_in_0; // @[src/main/scala/CompileObj.scala 103:27]
  wire [3:0] adder_auto_out; // @[src/main/scala/CompileObj.scala 103:27]
  wire  drivers_clock; // @[src/main/scala/CompileObj.scala 105:53]
  wire  drivers_reset; // @[src/main/scala/CompileObj.scala 105:53]
  wire [3:0] drivers_auto_out_1; // @[src/main/scala/CompileObj.scala 105:53]
  wire [3:0] drivers_auto_out_0; // @[src/main/scala/CompileObj.scala 105:53]
  wire  drivers_1_clock; // @[src/main/scala/CompileObj.scala 105:53]
  wire  drivers_1_reset; // @[src/main/scala/CompileObj.scala 105:53]
  wire [3:0] drivers_1_auto_out_1; // @[src/main/scala/CompileObj.scala 105:53]
  wire [3:0] drivers_1_auto_out_0; // @[src/main/scala/CompileObj.scala 105:53]
  wire  monitor_clock; // @[src/main/scala/CompileObj.scala 107:29]
  wire  monitor_reset; // @[src/main/scala/CompileObj.scala 107:29]
  wire [3:0] monitor_auto_node_sum_in; // @[src/main/scala/CompileObj.scala 107:29]
  wire [3:0] monitor_auto_node_seq_in_1; // @[src/main/scala/CompileObj.scala 107:29]
  wire [3:0] monitor_auto_node_seq_in_0; // @[src/main/scala/CompileObj.scala 107:29]
  wire  monitor_io_error; // @[src/main/scala/CompileObj.scala 107:29]
  Adder adder ( // @[src/main/scala/CompileObj.scala 103:27]
    .auto_in_1(adder_auto_in_1),
    .auto_in_0(adder_auto_in_0),
    .auto_out(adder_auto_out)
  );
  AdderDriver drivers ( // @[src/main/scala/CompileObj.scala 105:53]
    .clock(drivers_clock),
    .reset(drivers_reset),
    .auto_out_1(drivers_auto_out_1),
    .auto_out_0(drivers_auto_out_0)
  );
  AdderDriver drivers_1 ( // @[src/main/scala/CompileObj.scala 105:53]
    .clock(drivers_1_clock),
    .reset(drivers_1_reset),
    .auto_out_1(drivers_1_auto_out_1),
    .auto_out_0(drivers_1_auto_out_0)
  );
  AdderMonitor monitor ( // @[src/main/scala/CompileObj.scala 107:29]
    .clock(monitor_clock),
    .reset(monitor_reset),
    .auto_node_sum_in(monitor_auto_node_sum_in),
    .auto_node_seq_in_1(monitor_auto_node_seq_in_1),
    .auto_node_seq_in_0(monitor_auto_node_seq_in_0),
    .io_error(monitor_io_error)
  );
  assign adder_auto_in_1 = drivers_1_auto_out_0; // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 363:18]
  assign adder_auto_in_0 = drivers_auto_out_0; // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 363:18]
  assign drivers_clock = clock;
  assign drivers_reset = reset;
  assign drivers_1_clock = clock;
  assign drivers_1_reset = reset;
  assign monitor_clock = clock;
  assign monitor_reset = reset;
  assign monitor_auto_node_sum_in = adder_auto_out; // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 365:18]
  assign monitor_auto_node_seq_in_1 = drivers_1_auto_out_1; // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 365:18]
  assign monitor_auto_node_seq_in_0 = drivers_auto_out_1; // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 365:18]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (monitor_io_error & ~reset) begin
          $fwrite(32'h80000002,"something went wrong"); // @[src/main/scala/CompileObj.scala 117:19]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule

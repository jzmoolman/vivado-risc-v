module TLPUF(
  input         clock,
  input         reset,
  output        auto_in_a_ready, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  input         auto_in_a_valid, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  input  [1:0]  auto_in_a_bits_size, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  input  [9:0]  auto_in_a_bits_source, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  input         auto_in_d_ready, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  output        auto_in_d_valid, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  output [1:0]  auto_in_d_bits_size, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  output [9:0]  auto_in_d_bits_source, // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
  output [63:0] auto_in_d_bits_data // @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
);

  wire w_fire = auto_in_d_ready & auto_in_a_valid;
  wire w_busy = 1'b0;
  reg r_source;
  reg r_state = 1'b0;



  fpga_puf fpga_puf_inst(
    .clk_i(clock),
    .rstn_i(~reset),
    .trig_i(w_fire),
    .busy_o(w_busy),
    .id_o(auto_in_d_bits_data)
    );

  always @(posedge clock) begin
      if (r_state == 1'b0) begin
        if ( w_fire) begin
          r_source <= auto_in_a_bits_source;
          r_state <= 1'b1;
        end
      end else begin
          if ( ~w_busy) begin
             r_state <= 1'b0;
          end
      end
  end


  assign auto_in_d_source = r_source;
  assign auto_in_d_valid = ~w_busy & r_state;
  assign auto_in_d_ready = ~w_busy & ~r_state;
endmodule

FIRRTL version 1.2.0
circuit AdderTestHarness :
  module Adder :
    input clock : Clock
    input reset : Reset
    output auto : { flip in_1 : UInt<4>, flip in_0 : UInt<4>, out : UInt<4>} @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]

    wire nodeIn : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1214:17]
    nodeIn is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1217:7]
    wire nodeIn_1 : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1214:17]
    nodeIn_1 is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1217:7]
    wire nodeOut : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1205:17]
    nodeOut is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1208:7]
    auto.out <= nodeOut @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 380:12]
    nodeIn <= auto.in_0 @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 378:16]
    nodeIn_1 <= auto.in_1 @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 378:16]
    node _nodeOut_T = add(nodeIn, nodeIn_1) @[src/main/scala/CompileObj.scala 51:55]
    node _nodeOut_T_1 = tail(_nodeOut_T, 1) @[src/main/scala/CompileObj.scala 51:55]
    nodeOut <= _nodeOut_T_1 @[src/main/scala/CompileObj.scala 51:26]

  module MaxPeriodFibonacciLFSR :
    input clock : Clock
    input reset : Reset
    output io : { flip seed : { valid : UInt<1>, bits : UInt<1>[4]}, flip increment : UInt<1>, out : UInt<1>[4]} @[src/main/scala/chisel3/util/random/PRNG.scala 42:22]

    wire _state_WIRE : UInt<1>[4] @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    _state_WIRE[0] <= UInt<1>("h1") @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    _state_WIRE[1] <= UInt<1>("h0") @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    _state_WIRE[2] <= UInt<1>("h0") @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    _state_WIRE[3] <= UInt<1>("h0") @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    reg state : UInt<1>[4], clock with :
      reset => (reset, _state_WIRE) @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
    when io.increment : @[src/main/scala/chisel3/util/random/PRNG.scala 69:22]
      node _T = xor(state[3], state[2]) @[src/main/scala/chisel3/util/random/LFSR.scala 15:41]
      state[0] <= _T @[src/main/scala/chisel3/util/random/PRNG.scala 70:11]
      state[1] <= state[0] @[src/main/scala/chisel3/util/random/PRNG.scala 70:11]
      state[2] <= state[1] @[src/main/scala/chisel3/util/random/PRNG.scala 70:11]
      state[3] <= state[2] @[src/main/scala/chisel3/util/random/PRNG.scala 70:11]
    when io.seed.valid : @[src/main/scala/chisel3/util/random/PRNG.scala 73:22]
      state[0] <= io.seed.bits[0] @[src/main/scala/chisel3/util/random/PRNG.scala 74:11]
      state[1] <= io.seed.bits[1] @[src/main/scala/chisel3/util/random/PRNG.scala 74:11]
      state[2] <= io.seed.bits[2] @[src/main/scala/chisel3/util/random/PRNG.scala 74:11]
      state[3] <= io.seed.bits[3] @[src/main/scala/chisel3/util/random/PRNG.scala 74:11]
    io.out <= state @[src/main/scala/chisel3/util/random/PRNG.scala 78:10]

  module AdderDriver :
    input clock : Clock
    input reset : Reset
    output auto : { out_1 : UInt<4>, out_0 : UInt<4>} @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]

    wire nodeOut : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1205:17]
    nodeOut is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1208:7]
    wire x1_nodeOut : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1205:17]
    x1_nodeOut is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1208:7]
    auto.out_0 <= nodeOut @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 380:12]
    auto.out_1 <= x1_nodeOut @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 380:12]
    inst randomAddend_prng of MaxPeriodFibonacciLFSR @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
    randomAddend_prng.clock <= clock
    randomAddend_prng.reset <= reset
    randomAddend_prng.io.seed.valid <= UInt<1>("h0") @[src/main/scala/chisel3/util/random/PRNG.scala 92:24]
    randomAddend_prng.io.seed.bits[0] is invalid @[src/main/scala/chisel3/util/random/PRNG.scala 93:23]
    randomAddend_prng.io.seed.bits[1] is invalid @[src/main/scala/chisel3/util/random/PRNG.scala 93:23]
    randomAddend_prng.io.seed.bits[2] is invalid @[src/main/scala/chisel3/util/random/PRNG.scala 93:23]
    randomAddend_prng.io.seed.bits[3] is invalid @[src/main/scala/chisel3/util/random/PRNG.scala 93:23]
    randomAddend_prng.io.increment <= UInt<1>("h1") @[src/main/scala/chisel3/util/random/PRNG.scala 94:23]
    node randomAddend_lo = cat(randomAddend_prng.io.out[1], randomAddend_prng.io.out[0]) @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
    node randomAddend_hi = cat(randomAddend_prng.io.out[3], randomAddend_prng.io.out[2]) @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
    node randomAddend = cat(randomAddend_hi, randomAddend_lo) @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
    nodeOut <= randomAddend @[src/main/scala/CompileObj.scala 71:55]
    x1_nodeOut <= randomAddend @[src/main/scala/CompileObj.scala 71:55]

  module MaxPeriodFibonacciLFSR_1 :
    input clock : Clock
    input reset : Reset
    output io : { flip seed : { valid : UInt<1>, bits : UInt<1>[4]}, flip increment : UInt<1>, out : UInt<1>[4]} @[src/main/scala/chisel3/util/random/PRNG.scala 42:22]

    wire _state_WIRE : UInt<1>[4] @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    _state_WIRE[0] <= UInt<1>("h1") @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    _state_WIRE[1] <= UInt<1>("h0") @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    _state_WIRE[2] <= UInt<1>("h0") @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    _state_WIRE[3] <= UInt<1>("h0") @[src/main/scala/chisel3/util/random/PRNG.scala 46:28]
    reg state : UInt<1>[4], clock with :
      reset => (reset, _state_WIRE) @[src/main/scala/chisel3/util/random/PRNG.scala 55:49]
    when io.increment : @[src/main/scala/chisel3/util/random/PRNG.scala 69:22]
      node _T = xor(state[3], state[2]) @[src/main/scala/chisel3/util/random/LFSR.scala 15:41]
      state[0] <= _T @[src/main/scala/chisel3/util/random/PRNG.scala 70:11]
      state[1] <= state[0] @[src/main/scala/chisel3/util/random/PRNG.scala 70:11]
      state[2] <= state[1] @[src/main/scala/chisel3/util/random/PRNG.scala 70:11]
      state[3] <= state[2] @[src/main/scala/chisel3/util/random/PRNG.scala 70:11]
    when io.seed.valid : @[src/main/scala/chisel3/util/random/PRNG.scala 73:22]
      state[0] <= io.seed.bits[0] @[src/main/scala/chisel3/util/random/PRNG.scala 74:11]
      state[1] <= io.seed.bits[1] @[src/main/scala/chisel3/util/random/PRNG.scala 74:11]
      state[2] <= io.seed.bits[2] @[src/main/scala/chisel3/util/random/PRNG.scala 74:11]
      state[3] <= io.seed.bits[3] @[src/main/scala/chisel3/util/random/PRNG.scala 74:11]
    io.out <= state @[src/main/scala/chisel3/util/random/PRNG.scala 78:10]

  module AdderDriver_1 :
    input clock : Clock
    input reset : Reset
    output auto : { out_1 : UInt<4>, out_0 : UInt<4>} @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]

    wire nodeOut : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1205:17]
    nodeOut is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1208:7]
    wire x1_nodeOut : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1205:17]
    x1_nodeOut is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1208:7]
    auto.out_0 <= nodeOut @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 380:12]
    auto.out_1 <= x1_nodeOut @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 380:12]
    inst randomAddend_prng of MaxPeriodFibonacciLFSR_1 @[src/main/scala/chisel3/util/random/PRNG.scala 91:22]
    randomAddend_prng.clock <= clock
    randomAddend_prng.reset <= reset
    randomAddend_prng.io.seed.valid <= UInt<1>("h0") @[src/main/scala/chisel3/util/random/PRNG.scala 92:24]
    randomAddend_prng.io.seed.bits[0] is invalid @[src/main/scala/chisel3/util/random/PRNG.scala 93:23]
    randomAddend_prng.io.seed.bits[1] is invalid @[src/main/scala/chisel3/util/random/PRNG.scala 93:23]
    randomAddend_prng.io.seed.bits[2] is invalid @[src/main/scala/chisel3/util/random/PRNG.scala 93:23]
    randomAddend_prng.io.seed.bits[3] is invalid @[src/main/scala/chisel3/util/random/PRNG.scala 93:23]
    randomAddend_prng.io.increment <= UInt<1>("h1") @[src/main/scala/chisel3/util/random/PRNG.scala 94:23]
    node randomAddend_lo = cat(randomAddend_prng.io.out[1], randomAddend_prng.io.out[0]) @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
    node randomAddend_hi = cat(randomAddend_prng.io.out[3], randomAddend_prng.io.out[2]) @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
    node randomAddend = cat(randomAddend_hi, randomAddend_lo) @[src/main/scala/chisel3/util/random/PRNG.scala 95:17]
    nodeOut <= randomAddend @[src/main/scala/CompileObj.scala 71:55]
    x1_nodeOut <= randomAddend @[src/main/scala/CompileObj.scala 71:55]

  module AdderMonitor :
    input clock : Clock
    input reset : Reset
    output auto : { flip node_sum_in : UInt<4>, flip node_seq_in_1 : UInt<4>, flip node_seq_in_0 : UInt<4>} @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]
    output io : { error : UInt<1>} @[src/main/scala/CompileObj.scala 78:16]

    wire nodeSeqIn : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1214:17]
    nodeSeqIn is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1217:7]
    wire nodeSeqIn_1 : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1214:17]
    nodeSeqIn_1 is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1217:7]
    wire nodeSumIn : UInt<4> @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1214:17]
    nodeSumIn is invalid @[rocket-chip/src/main/scala/diplomacy/Nodes.scala 1217:7]
    nodeSeqIn <= auto.node_seq_in_0 @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 378:16]
    nodeSeqIn_1 <= auto.node_seq_in_1 @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 378:16]
    nodeSumIn <= auto.node_sum_in @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 378:16]
    node _T = asUInt(reset) @[src/main/scala/CompileObj.scala 91:15]
    node _T_1 = eq(_T, UInt<1>("h0")) @[src/main/scala/CompileObj.scala 91:15]
    when _T_1 : @[src/main/scala/CompileObj.scala 91:15]
      printf(clock, UInt<1>("h1"), "%d + %d = %d", nodeSeqIn, nodeSeqIn_1, nodeSumIn) : printf @[src/main/scala/CompileObj.scala 91:15]
    node _io_error_T = add(nodeSeqIn, nodeSeqIn_1) @[src/main/scala/CompileObj.scala 94:79]
    node _io_error_T_1 = tail(_io_error_T, 1) @[src/main/scala/CompileObj.scala 94:79]
    node _io_error_T_2 = neq(nodeSumIn, _io_error_T_1) @[src/main/scala/CompileObj.scala 94:40]
    io.error <= _io_error_T_2 @[src/main/scala/CompileObj.scala 94:18]

  module AdderTestHarness :
    input clock : Clock
    input reset : UInt<1>
    output auto : { } @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 374:18]

    inst adder of Adder @[src/main/scala/CompileObj.scala 103:27]
    adder.clock <= clock
    adder.reset <= reset
    inst drivers of AdderDriver @[src/main/scala/CompileObj.scala 105:53]
    drivers.clock <= clock
    drivers.reset <= reset
    inst drivers_1 of AdderDriver_1 @[src/main/scala/CompileObj.scala 105:53]
    drivers_1.clock <= clock
    drivers_1.reset <= reset
    inst monitor of AdderMonitor @[src/main/scala/CompileObj.scala 107:29]
    monitor.clock <= clock
    monitor.reset <= reset
    monitor.auto.node_sum_in <= adder.auto.out @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 365:18]
    adder.auto.in_0 <= drivers.auto.out_0 @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 363:18]
    monitor.auto.node_seq_in_0 <= drivers.auto.out_1 @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 365:18]
    adder.auto.in_1 <= drivers_1.auto.out_0 @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 363:18]
    monitor.auto.node_seq_in_1 <= drivers_1.auto.out_1 @[rocket-chip/src/main/scala/diplomacy/LazyModule.scala 365:18]
    when monitor.io.error : @[src/main/scala/CompileObj.scala 116:39]
      node _T = bits(reset, 0, 0) @[src/main/scala/CompileObj.scala 117:19]
      node _T_1 = eq(_T, UInt<1>("h0")) @[src/main/scala/CompileObj.scala 117:19]
      when _T_1 : @[src/main/scala/CompileObj.scala 117:19]
        printf(clock, UInt<1>("h1"), "something went wrong") : printf @[src/main/scala/CompileObj.scala 117:19]



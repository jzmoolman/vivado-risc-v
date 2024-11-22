//
//package freechips.rocketchip.subsystem
//
//  import chisel3._
//  import chisel3.util._
//
//  import org.chipsalliance.cde.config._
//  import freechips.rocketchip.diplomacy._
//
//  import freechips.rocketchip.regmapper._
//  import freechips.rocketchip.tilelink._
//
//  class MemoryEncryptionController(val mec: MemoryEncryptionControllerParameters )
//                                  (implicit p: Parameters)
//    extends LazyModule {
//
//    val node: TLAdapterNode = TLAdapterNode(
//      clientFn = { cp =>
//        println(cp)
//        cp
//      },
//      managerFn = { mp =>
//        println(mp)
//        mp
//      })
//
//    lazy val module = new Impl
//
//    class Impl extends LazyModuleImp(this) {
//      (node.in zip node.out) foreach { case ((in, edgeIn), (out, edgeOut)) =>
//        println(s"out $out")
//        println(s"in $in")
//        out <> in
//      }
//    }
//  }
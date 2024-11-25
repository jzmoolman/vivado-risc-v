package freechips.rocketchip.subsystem

//
//import freechips.rocketchip.diplomacy.LazyModule
//import freechips.rocketchip.tile.XLen
//import jzm.mec.{BankedMecKey, MemoryEncryptionController, MemoryEncryptionControllerParameters}
//import org.chipsalliance.cde.config.{Config, Field}
//
//
//case class MemoryEncryptionControllerParams(
//                                           ee: Boolean,
//                                           writeBytes : Int,
////                                           )
//case object MemoryEncryptionControllerKey extends Field[MemoryEncryptionControllerParams]
//
//class WithMemoryEncryptionController(ee: Boolean  = true
//                        ) extends Config((site, here, up) => {
//
//  case MemoryEncryptionControllerKey => MemoryEncryptionControllerParams(
//      ee = ee,
//      writeBytes = site(XLen)/8,
//   )
//  case BankedMecKey => up(BankedMecKey, site).copy(coherenceManager = { context =>
//    implicit val p = context.p
//    val sbus = context.tlBusWrapperLocationMap(SBUS)
//    val cbus = context.tlBusWrapperLocationMap.lift(CBUS).getOrElse(sbus)
//    val MemoryEncryptionControllerParams(
//      ee,
//      writeBytes
//    ) = p(MemoryEncryptionControllerKey)
//
//    val mec = LazyModule(new MemoryEncryptionController(
//      MemoryEncryptionControllerParameters(
//        ee = ee,
//        blockBytes = sbus.blockBytes,
//        beatBytes = sbus.beatBytes,
//        )))
//
////    ElaborationAkrtefacts.add("mec.json", mec.module.json)
//    (mec.node, mec.node, None)
//  })
//})

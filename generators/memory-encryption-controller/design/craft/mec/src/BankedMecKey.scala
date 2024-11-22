//package jzm.mec
//
//import org.chipsalliance.cde.config._
//import chisel3.util.isPow2
//import freechips.rocketchip.subsystem.CoherenceManagerWrapper.{CoherenceManagerInstantiationFn, broadcastManager}
//
//case object BankedMecKey extends Field(BankedMecParams())
//case class BankedMecParams (
//   nBanks: Int = 1,
//   coherenceManager: CoherenceManagerInstantiationFn = broadcastManager                        )
//{
//  require (isPow2(nBanks) || nBanks == 0)
//}

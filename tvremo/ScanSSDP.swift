//
//  ScanSSDP.swift
//  tvremo

import Foundation

class ScanSSDP {
    var ssdp:SSDP = SSDP()
    func startDiscovery() {
        let netinfo = MyNetworkInfo()
        DispatchQueue.global(qos: .userInitiated).async() {
            self.ssdp.doSSDP(myipaddr: netinfo.getIPv4Address())
        }
        
    }
}

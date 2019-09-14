//
//  MyNetworkInfo.swift
//  tvremo
//

import Foundation

class MyNetworkInfo {
    private var ipv4Address: String = ""

    init() {
        self.refresh()
    }

    // ネットワーク情報の更新
    func refresh() {
        var mask: String
        (self.ipv4Address, mask) = self.getWiFiIPv4Address()
    }

    func getIPv4Address() -> (String) {
        return self.ipv4Address
    }

    private func getWiFiIPv4Address() -> (String, String) {
        var address: String = ""
        var netmask: String = ""

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0 else { return ("", "") }
        guard let firstAddr = ifaddr else { return ("", "") }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 interface:
            let addrFamily: UInt8 = interface.ifa_addr.pointee.sa_family
            //if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)

                    var mask = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_netmask, socklen_t(interface.ifa_netmask.pointee.sa_len), &mask, socklen_t(mask.count), nil, socklen_t(0), NI_NUMERICHOST)
                    netmask = String(cString: mask)
                }
            }
        }
        freeifaddrs(ifaddr)

        return (address, netmask)
    }
}

//
//  Panasonic.swift
//  tvremo
//

import Foundation

//
// ビエラの「TVリモート機能」がオンにする
// ネットワーク設定 > TVリモート設定 > TVリモート機能
class PanasonicTV: TV {
    private var user: String?
    private var password: String?
    private var ipAddress: String?

    override func set(ipAddress: String?, user: String?, password: String?) {
        self.ipAddress = ipAddress
        self.user = user
        self.password = password
    }
}

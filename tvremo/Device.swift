//
//  Device.swift
//  tvremo
//

import Foundation

class Device: NSObject, NSCoding{
    var name: String = ""
    var v4addr: String = ""
    var uuid: String = ""
    var deviceType: String = "" // Not save in userdefault

    var tvctl: TV?

    enum Vender: String {
        case TOSHIBA
        case SONY
        case SHARP
        case LG
        case MITSUBISHI
        case PANASONIC

        case UNKNOWN
    }

    private var privateVender: Vender = Vender.UNKNOWN
    var vender: Vender {
        get {
            return self.privateVender
        }
        set(value) {
            self.privateVender = value
            self.setTVctl()
        }
    }

    private var _username: String = ""
    var username: String {
        get {
            return self._username
        }
        set(value) {
            self._username = value
            self.tvctl?.set(ipAddress: self.v4addr, user: self.username, password: self.password)
        }
    }

    private var _password: String = ""
    var password: String {
        get {
            return self._password
        }
        set(value) {
            self._password = value
            self.tvctl?.set(ipAddress: self.v4addr, user: self.username, password: self.password)
        }
    }

    // for NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.v4addr, forKey: "v4addr")
        aCoder.encode(self.uuid, forKey: "uuid")
        aCoder.encode(self.vender.rawValue, forKey: "vender")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.password, forKey: "password")
    }

    // for NSCoding
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.v4addr = aDecoder.decodeObject(forKey: "v4addr") as! String
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as! String
        self.vender = Vender(rawValue: aDecoder.decodeObject(forKey: "vender") as! String) ?? Vender.UNKNOWN
        self.username = aDecoder.decodeObject(forKey: "username") as! String
        self.password = aDecoder.decodeObject(forKey: "password") as! String

        self.setTVctl()
    }

    override init() {
        super.init()
        self.privateVender = Vender.UNKNOWN
    }

    private func setTVctl() {
        switch self.privateVender {
        case .TOSHIBA:
            self.tvctl = ToshibaTV()
            self.tvctl?.set(ipAddress: self.v4addr, user: self.username, password: self.password)
        case .SHARP:
            self.tvctl = SharpTV()
            self.tvctl?.set(ipAddress: self.v4addr, user: self.username, password: self.password)
        case .LG: break
        case .MITSUBISHI: break
        case .PANASONIC: break
        case .SONY: break
        case .UNKNOWN: break
        }
        // self.tvctl?.set(ipAddress: self.ipAddress, user: self.username, password: self.password)
    }


    func describe() -> String {
        var str: String = ""
        str += "Name: " + name
        str += "\nv4Addr: " + v4addr
        str += "\nUUID: " + uuid
        str += "\nVender: " + vender.rawValue
        str += "\nUsername: " + username
        str += "\nPassword: " + password
        str += "\n"

        return str
    }

}

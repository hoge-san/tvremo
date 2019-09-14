//
//  DeviceSSDP.swift
//  tvremo
//

import Foundation

class DeviceSSDP {
    // Information from first SSDP Discovery
    var v4addr: String = ""
    var location: String = ""
    var server: String = ""
    var uuid: String = ""
    var data: String = ""  // all data from first SSDP Discovery

    // Information from SSDP location
    // Device Section
    var name: String = ""
    
    var deviceType: String = ""
    var friendlyName: String = ""
    var manufacturer: String = ""
    var modelName: String = ""
    var modelNumber: String = ""
    var serialNumber: String = ""

    var locationData: String = "" // all data from SSDP location



    enum SSDPKey : String {
        case location     = "location"
        case data         = "data"
        case uuid         = "uuid"

        case deviceType   = "deviceType"
        case friendlyName = "friendlyName"
        case manufacturer = "manufacturer"
        case modelName    = "modelName"
        case modelNumber  = "modelNumber"
        case serialNumber = "serialNumber"

        case locationData = "locationData"
    }

    // This valuable is sent to server
    var dic: Dictionary <String, String> = Dictionary()

    func set(key: SSDPKey, val: String){
        if(val == "") {
            dic[key.rawValue] = nil
        } else {
            dic[key.rawValue] = val
        }
    }

    func get(key: SSDPKey) -> (String){
        if(dic[key.rawValue] == nil) {
            return ""
        }
        return dic[key.rawValue]!
    }

    func getMacAddressFromUUID() -> (String) {
        let array = self.uuid.components(separatedBy:"-")
        if(array.count != 5) {
            return ""
        }
        let type = array[2].prefix(1)
        if(type == "1") {
            var mac:String = array[4]
            mac.insert(":", at: mac.index(mac.startIndex, offsetBy: 10))
            mac.insert(":", at: mac.index(mac.startIndex, offsetBy: 8))
            mac.insert(":", at: mac.index(mac.startIndex, offsetBy: 6))
            mac.insert(":", at: mac.index(mac.startIndex, offsetBy: 4))
            mac.insert(":", at: mac.index(mac.startIndex, offsetBy: 2))
            //            print("AAA")
            //            print("DeviceSSID: UUID:" + self.uuid + ", MAC Address: " + mac)
            //            print(mac)
            return mac // UUID Type 1の5つめはMACアドレス
        }
        return ""
    }

    func print() -> (String) {
        var s:String = ""
        s = "Manufacturer: " + manufacturer +
            "\nModelName: " + modelName +
            "\nFriendlyName: " + friendlyName +
            "\nDeviceType: " + deviceType +
        "\n"

        return s
    }

    func printAll() -> (String) {
        var s:String = ""
        s = "Location: " + location +
            "\nManufacturer: " + manufacturer +
            "\nModelName: " + modelName +
            "\nFriendlyName: " + friendlyName +
            "\nDeviceType: " + deviceType +
            "\nUUID: " + uuid +
            "\nData: " + data +
        "\n"

        return s
    }

    func getData() -> (Dictionary<String, String>) {
        set(key: SSDPKey.location, val: location)
        set(key: SSDPKey.data, val: data)
        set(key: SSDPKey.uuid, val: uuid)

        set(key: SSDPKey.deviceType, val: deviceType)
        set(key: SSDPKey.friendlyName, val: friendlyName)
        set(key: SSDPKey.manufacturer, val: manufacturer)
        set(key: SSDPKey.modelName, val: modelName)
        set(key: SSDPKey.modelNumber, val: modelNumber)
        set(key: SSDPKey.serialNumber, val: serialNumber)
        set(key: SSDPKey.locationData, val: locationData)
        return dic
    }
}


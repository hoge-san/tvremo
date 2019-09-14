//
//  DeviceManager.swift
//  tvremo
//
import Foundation

class DeviceManager {
    static var shared = DeviceManager()
    static var devices: Array<Device> = []

    static func load() {
        if let storedData = UserDefaults.standard.object(forKey: "devices") as? Data {
            if let unarchivedObject = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storedData) as? [Device] {
                DeviceManager.devices = unarchivedObject
            }
        }
        DeviceManager.refresh()
    }

    static func save() {
        let archivedData = try! NSKeyedArchiver.archivedData(withRootObject: DeviceManager.devices, requiringSecureCoding: false)
        UserDefaults.standard.set(archivedData, forKey: "devices")
    }

    static let semaphore = DispatchSemaphore(value: 1)
    private static var refreshing: Bool = false
    static func refresh() {
        if DeviceManager.devices.count == 0 { return }
        if DeviceManager.refreshing { return }
        print("Device Manager refresh")
        DeviceManager.refreshing = true
        DispatchQueue.global().async  {
            // print("Device Manager refresh start wait")
            // semaphore.wait()
            print("Device Manager refresh started")
            refreshIP()
            // semaphore.signal()
            DeviceManager.refreshing = false
            print("Device Manager refresh end")
        }
    }

    // 同期メソッド
    private static func refreshIP() {
        let ssdp:SSDP = SSDP()
        let netinfo = MyNetworkInfo()
        ssdp.doSSDPDiscover(myipaddr: netinfo.getIPv4Address())
        for device in devices {
            for ssdpDevice in ssdp.firstfoundDevices {
                if device.uuid == ssdpDevice.uuid {
                    if device.v4addr != ssdpDevice.v4addr {
                        print("change IP Addr: " + device.name)
                        print("From: " + device.v4addr + ", To: " + ssdpDevice.v4addr)
                        device.v4addr = ssdpDevice.v4addr
                        DeviceManager.save()
                    }
                    break
                }
            }
        }
    }

    static func add(device: Device){
        for d in devices {
            if d.uuid == device.uuid {
                print("duplicate registerd device")
                print(device.describe())
                return
            }
        }
        DeviceManager.devices.append(device)
        DeviceManager.save()
    }

    static func change(device: Device) {
        for d in devices {
            if d.uuid == device.uuid {
                d.username = device.username
                d.password = device.password
                print("change registerd device")
                print(d.describe())
                DeviceManager.save()
                return
            }
        }
    }

    static func delete(device: Device) {
        for i in 0 ..< devices.count {
            if devices[i].uuid == device.uuid {
                devices.remove(at: i)
                DeviceManager.save()
                return
            }
        }
    }
}

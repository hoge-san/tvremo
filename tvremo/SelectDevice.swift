//
//  SelectDevice.swift
//  tvremo

import UIKit

class SelectDevice: UIViewController {
    var devices: Array<Device> = []

    let ssdp:SSDP = SSDP()
    let netinfo = MyNetworkInfo()

    var selectedDevice: Device?

    @IBOutlet weak var registerDeviceTableView: UITableView!

    @IBOutlet weak var ssdpDeviceTableView: UITableView!

    private var ActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ssdpDeviceTableView.delegate = self
        self.ssdpDeviceTableView.dataSource = self
        self.registerDeviceTableView.delegate = self
        self.registerDeviceTableView.dataSource = self

        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.ssdpDeviceTableView.center
        ActivityIndicator.hidesWhenStopped = true
        ActivityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(ActivityIndicator)

        self.scanDevice()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SelectDevice: viewWillAppear")
        registerDeviceTableView.reloadData()
        ssdpDeviceTableView.reloadData()
    }

    @IBAction func refreshAction(_ sender: Any) {
        self.scanDevice()
    }

    private func appendDevice(device: DeviceSSDP, vender: Device.Vender, deviceName: String) {
        for d in self.devices {
            if d.v4addr == device.v4addr && d.vender == vender {
                print("SelectDevice: same IP Addr for device." + device.v4addr)
                print("Old: " + d.deviceType)
                print("New: " + device.deviceType)
                if vender == .TOSHIBA || vender == .PANASONIC || vender == .MITSUBISHI {
                    if device.deviceType.contains("schemas-upnp-org:device:MediaRenderer") ||
                        device.deviceType.contains("schemas-upnp-org:device:MediaServer") {
                        d.uuid = device.uuid
                        d.name = deviceName
                    }
                } else if vender == .LG {
                    if device.deviceType.contains("schemas-upnp-org:device:Basic") {
                        d.uuid = device.uuid
                        d.name = deviceName
                    }
                } else if vender == .SHARP || vender == .SONY {
                    if device.deviceType.contains("schemas-upnp-org:device:MediaRenderer") ||
                        device.deviceType.contains("schemas-upnp-org:device:MediaServer") ||
                        device.deviceType.contains("dial-multiscreen-org:device:dial") {
                        d.uuid = device.uuid
                        d.name = deviceName
                    }
                }
                return
            }
        }

        let d = Device()
        d.name = deviceName
        d.vender = vender
        d.uuid = device.uuid
        d.v4addr = device.v4addr
        d.deviceType = device.deviceType
        self.devices.append(d)
    }

    func scanDevice() {
        self.netinfo.refresh()
        devices.removeAll()
        self.ActivityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async() {
            self.ssdp.doSSDP(myipaddr: self.netinfo.getIPv4Address())
            print("----- FoundDevice ------")
            for device in self.ssdp.finalFoundDevices {
                if device.manufacturer.uppercased().contains("TOSHIBA") {
                    print(device.printAll())
                    self.appendDevice(device: device, vender: Device.Vender.TOSHIBA, deviceName: device.friendlyName)
                } else if device.manufacturer.uppercased().contains("SONY") {
                    print(device.printAll())
                    self.appendDevice(device: device, vender: Device.Vender.SONY, deviceName: device.friendlyName)
                } else if device.manufacturer.uppercased().contains("SHARP") {
                    print(device.printAll())
                    if let range = device.modelName.range(of: "\n") {
                        device.modelName.replaceSubrange(range, with: "")
                    }
                    self.appendDevice(device: device, vender: Device.Vender.SHARP, deviceName: device.modelName)
                } else if device.manufacturer.uppercased().contains("LG Electronics") {
                    print(device.printAll())
                    self.appendDevice(device: device, vender: Device.Vender.LG, deviceName: device.modelNumber)
                } else if device.manufacturer.uppercased().contains("MITSUBISHI") {
                    print(device.printAll())
                    self.appendDevice(device: device, vender: Device.Vender.MITSUBISHI, deviceName: device.modelNumber)
                } else if device.manufacturer.uppercased().contains("PANASONIC") {
                    print(device.printAll())
                    self.appendDevice(device: device, vender: Device.Vender.PANASONIC, deviceName: device.modelNumber)
                }
            }
            DispatchQueue.main.async {
                self.ActivityIndicator.stopAnimating()
                self.ssdpDeviceTableView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectDeviceDetail" {
            let choiceVC = (segue.destination as? SelectDeviceDetail)!
            choiceVC.device = self.selectedDevice
        }
        if segue.identifier == "toChangeDeviceDetail" {
            let choiceVC = (segue.destination as? ChangeDeviceDetail)!
            choiceVC.device = self.selectedDevice
        }
    }
}

extension SelectDevice: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(registerDeviceTableView) {
            return DeviceManager.devices.count
        }
        return self.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEqual(registerDeviceTableView) {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "registerDevice", for: indexPath)
            (cell.viewWithTag(1) as? UILabel)?.text = DeviceManager.devices[indexPath.row].name
            (cell.viewWithTag(2) as? UILabel)?.text = DeviceManager.devices[indexPath.row].vender.rawValue
            return cell
        }

        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ssdpDevice", for: indexPath)
        // セルに表示する値を設定する
        (cell.viewWithTag(1) as? UILabel)?.text = self.devices[indexPath.row].name
        (cell.viewWithTag(2) as? UILabel)?.text = self.devices[indexPath.row].vender.rawValue

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEqual(registerDeviceTableView) {
            selectedDevice = DeviceManager.devices[indexPath.row]
            performSegue(withIdentifier: "toChangeDeviceDetail", sender: nil)
        } else {
            selectedDevice = self.devices[indexPath.row]
            performSegue(withIdentifier: "toSelectDeviceDetail", sender: nil)
        }
    }
}

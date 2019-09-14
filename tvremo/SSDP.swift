//
//  SSDP.swift
//  tvremo
//

import Foundation

class SSDP: NSObject, XMLParserDelegate{
    var xmldelegate: XMLParserDelegate?
    var xmlTargetName: String = ""
    var currentDeviceSSDP: DeviceSSDP = DeviceSSDP()
    var firstfoundDevices: Array<DeviceSSDP> = []
    var foundDevices: Set<SSDPInfo> = []
    var finalFoundDevices: Array<DeviceSSDP> = []

    var currentIpAddress: String = ""
    var sock: Int32 = 0
    let semaphore = DispatchSemaphore(value: 0)

    func get(v4addr: String) -> (Array<DeviceSSDP>){
        var ssdp: Array<DeviceSSDP> = []
        for d in self.finalFoundDevices {
            if(v4addr == d.v4addr) {
                ssdp.append(d)
            }
        }
        return ssdp
    }

    func finishSSDP() {
        semaphore.signal()
    }

    func doSSDPDiscover(myipaddr: String){
        self.sock = initSSDP(myipaddr)
        if self.sock < 0 { return }

        self.firstfoundDevices.removeAll()
        let bufSize:Int = 2048
        var buf = [CChar](repeating:0, count:bufSize)
        let ipaddrSize: Int = 16
        var ipaddr = [CChar](repeating:0, count:ipaddrSize)
        var result:Int32 = 0

        sendSSDP(self.sock)
        repeat {
            result = Int32(recvSSDP(self.sock, &buf, Int32(bufSize), &ipaddr, Int32(ipaddrSize)));
            if result < 0  { break }
            // var location: String = ""
            // var server: String = ""
            // var uuid: String = ""
            let (location, server, uuid) = self.getLocation(data: String.init(cString: buf))
            //print("SSDP: Location " + location)
            var same: Bool = false
            for d in self.firstfoundDevices {
                if d.location == location  { same = true }
            }
            if(same == false) {
                print("SSDP: UUID=" + uuid + ", Location=" + location)
                let device: DeviceSSDP = DeviceSSDP()
                device.v4addr   = String.init(cString: ipaddr)
                device.location = location
                device.server   = server
                device.uuid     = uuid
                device.data     = String.init(cString: buf)
                self.firstfoundDevices.append(device)
                // print(device.printAll()) // Debug
            }
        } while (result >= 0)
        finalSSDP(self.sock)
        self.sock = 0
    }

    func doSSDP(myipaddr: String){
        doSSDPDiscover(myipaddr: myipaddr)
        if self.firstfoundDevices.count == 0   { return }

        for d in self.firstfoundDevices {
            let s = SSDPInfo(ssdp: self)

            self.foundDevices.insert(s)
            s.start(deviceSSDP: d) // 非同期メソッド
        }
        semaphore.wait()
    }

    func finishGetSSDPInfo(s: SSDPInfo) {
         print("finishGetSSDPInfo" + s.device.printAll())
        self.finalFoundDevices.append(s.device)
        self.foundDevices.remove(s)
        if (self.foundDevices.count <= 0) {
            self.finishSSDP()
        }
    }

    func finishNotGetSSDPInfo(s: SSDPInfo) {
        // SSDPから取得したURLの応答がない場合には、削除する
        self.foundDevices.remove(s)
        if (self.foundDevices.count <= 0) {
            self.finishSSDP()
        }
    }

    func getLocation(data:String) -> (String,String,String){
        var location:String = ""
        var server:String = ""
        var uuid:String = ""
        data.enumerateLines { (line, stop) -> () in
            if(line.localizedCaseInsensitiveContains("location:")) {
                let i = line.index(line.startIndex, offsetBy: 9)
                location = String(line[i...])
                location = location.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if(line.localizedCaseInsensitiveContains("server:")) {
                let i = line.index(line.startIndex, offsetBy: 7)
                server = String(line[i...])
            }
            if(line.localizedCaseInsensitiveContains("USN:")) {
                if(line.localizedCaseInsensitiveContains("uuid:")){
                    let startIndex = line.range(of: "uuid:")!.upperBound
                    let endIndex: String.Index
                    if(line.localizedCaseInsensitiveContains("::")){
                        endIndex = line.range(of: "::")!.lowerBound
                    } else {
                        endIndex = line.endIndex
                    }

                    uuid = String(line[startIndex..<endIndex])
                }
            }
        }
        return(location, server, uuid)
    }
}

class SSDPInfo: NSObject, XMLParserDelegate{
    let parentSSDP: SSDP
    var device: DeviceSSDP = DeviceSSDP()
    var xmldelegate: XMLParserDelegate?
    var xmlTargetName: String = ""

    init(ssdp: SSDP) {
        self.parentSSDP = ssdp
        super.init()
    }

    func start(deviceSSDP: DeviceSSDP) {
        let urlString: String = deviceSSDP.location
        self.device = deviceSSDP

        // let ipaddr = deviceSSDP.v4addr
        // print("getSSDPInfo() SSDP GET: " + ipaddr + ", URL:" + urlString)

        var request: URLRequest  = URLRequest(url: NSURL(string: urlString)! as URL)
        request.httpMethod = "GET"

        let session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 5
            configuration.timeoutIntervalForResource = 5
            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        }()


        let task = session.dataTask(with: request, completionHandler:
        {
            (data, request, error) in

            guard error == nil else {
                // print("==== Timeout: " + urlString)
                self.parentSSDP.finishNotGetSSDPInfo(s: self)
                return
            }
            guard let data = data else {
                // print("No SSDP Data")
                self.parentSSDP.finishNotGetSSDPInfo(s: self)
                return
            }

            //必要はないがnilチェック
            let res = request as? HTTPURLResponse
            guard res != nil else{
                // print("response is nil")
                self.parentSSDP.finishNotGetSSDPInfo(s: self)
                return
            }
            //200番代だけをパスさせる
            guard (200 <= res!.statusCode && res!.statusCode < 300) else {
                // print("response status is not equal to 2XX : " ,res!.statusCode)
                self.parentSSDP.finishNotGetSSDPInfo(s: self)
                return
            }

            self.device.locationData = String(data: data, encoding: .utf8)!
            // print("=== Location Data" + self.device.locationData)
            let parser = XMLParser(data: data)
            parser.delegate = self;
            parser.parse()
        })

        task.resume()
    }

    //    func URLSession(session: URLSession, dataTask: URLSessionDataTask, didReceiveData data: NSData) {
    //    }

    // Start parse
    func parserDidStartDocument(_ parser: XMLParser) {

    }

    // start element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.xmlTargetName = elementName
    }

    // found element
    func parser(_ parser: XMLParser, foundCharacters string: String){
        let str = string.trimmingCharacters(in: .whitespacesAndNewlines)

        switch(self.xmlTargetName) {
        case "deviceType":
            //print("SSDP: deviceType: " + str)
            if(self.device.deviceType == ""){
                self.device.deviceType = str
            }
            break
        case "friendlyName":
            //print("SSDP: friendlyName: " + str)
            if(self.device.friendlyName == ""){
                self.device.friendlyName = str
            }
            break
        case "manufacturer":
            //print("SSDP: manufacturer: " + str)
            if(self.device.manufacturer == ""){
                self.device.manufacturer = str
            }
            break
        case "modelName":
            //print("SSDP: modelName: " + str)
            if(self.device.modelName == ""){
                self.device.modelName = str
            }
            break
        case "modelNumber":
            //print("SSDP: modelNumber: " + str)
            if(self.device.modelNumber == ""){
                self.device.modelNumber = str
            }
            break
        case "serialNumber":
            //print("SSDP: serialNumber: " + str)
            if(self.device.serialNumber == ""){
                self.device.serialNumber = str
            }
            break
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?)
    {
        self.xmlTargetName = ""
    }

    // パース後の最後に呼ばれる
    func parserDidEndDocument(_ parser: XMLParser) {
        self.parentSSDP.finishGetSSDPInfo(s: self)
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parentSSDP.finishGetSSDPInfo(s: self)
    }


}

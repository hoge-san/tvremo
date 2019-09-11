//
//  Sharp.swift
//  tvremo
//

import Foundation
import Network

class SharpTV: TV {
    private var user: String?
    private var password: String?
    private var ipAddress: String?

    override func set(ipAddress: String?, user: String?, password: String?) {
        self.ipAddress = ipAddress
        self.user = user
        self.password = password
    }

    override func power()         { self.sharpTVCtl(message: "POWR0   ", recvfunc: nil) } // 電源OFF
    override func volUp()         { self.sharpTVCtl(message: "VOLM????", recvfunc: recvfuncVolUp) } // 音量アップ
    override func volDown()       { self.sharpTVCtl(message: "VOLM????", recvfunc: recvfuncVolDown) } // 音量ダウン
    override func mute()          { self.sharpTVCtl(message: "MUTE0   ", recvfunc: nil) } // 消音
    override func channelUp()     { self.sharpTVCtl(message: "CHUP-   ", recvfunc: nil) } // チャンネルアップ
    override func channelDown()   { self.sharpTVCtl(message: "CHDW-   ", recvfunc: nil) } // チャンネルダウン
    override func recordingList() { self.sharpTVCtl(message: "        ", recvfunc: nil) } // 録画リスト
    override func guide()         { self.sharpTVCtl(message: "        ", recvfunc: nil) } // 番組ガイド

    var connection: NWConnection?


    func recvfuncVolUp(volume: String) {
        guard let currentVol = Int(volume) else { return }
        print("current Volume: " + String(currentVol))
        var message = "VOLM" + String(currentVol + 1)
        for _ in message.count ..< 8 {
            message += " "
        }
        print("message: " + message)
        self.sharpTVCtl(message: message, recvfunc: nil)
    }

    func recvfuncVolDown(volume: String) {
        guard let currentVol = Int(volume) else { return }
        print("current Volume: " + String(currentVol))
        var message = "VOLM" + String(currentVol - 1)
        for _ in message.count ..< 8 {
            message += " "
        }
        print("message: " + message)
        self.sharpTVCtl(message: message, recvfunc: nil)
    }

    func sharpTVCtl(message: String, recvfunc: ((String) -> Void )?) {
        guard let ipAddress = self.ipAddress else { return }
        let host = NWEndpoint.Host(ipAddress)
        let port = NWEndpoint.Port(integerLiteral: 10002)

        self.connection = NWConnection(host: host, port: port, using: .tcp)
        /// コネクションのステータス監視のハンドラを設定
        self.connection?.stateUpdateHandler = { (newState) in
            switch newState {
            case .ready:
                NSLog("Ready to send")
                self.send(text: message)
            case .waiting(let error):
                NSLog("\(#function), \(error)")
            case .failed(let error):
                NSLog("\(#function), \(error)")
            case .setup: break
            case .cancelled: break
            case .preparing: break
            @unknown default: break
            }
        }

        /// コネクションの開始
        let queue = DispatchQueue(label: "label")
        self.connection?.start(queue: queue)
        if recvfunc != nil {
            self.receive(recvfunc: recvfunc!)
        }
    }

    func send(text: String) {
        let username = self.user ?? ""
        let password = self.password ?? ""
        let message = username + "\r" + password + "\r" + text + "\r"
        let data = message.data(using: .utf8)!

        /// メッセージの送信
        connection?.send(content: data, completion: .contentProcessed { (error) in
            if let error = error {
                NSLog("\(#function), \(error)")
            } else {
                print("send message. " + message)
            }
        })
    }

    func receive(recvfunc: @escaping (String) -> Void) {
        /// コネクションからデータを受信
        self.connection?.receive(minimumIncompleteLength: 0, maximumLength: Int(UInt32.max)) { [weak self] (data, _, _, error) in
            if let data = data {
                let text = String(data: data, encoding: .utf8)!
                // print("Recieve:" + text)
                if text.hasPrefix("Login:") || text.hasPrefix("Password:"){
                    self?.receive(recvfunc: recvfunc)
                    return
                }
                recvfunc(text)
            } else {
                NSLog("\(#function), Received data is nil")
            }
            if self?.connection != nil {
                self?.connection?.cancel()
                self?.connection = nil
                print("Connection Closed.")
            }
        }
    }
}

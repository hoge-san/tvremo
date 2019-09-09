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

    override func power()         { self.sharpTVCtl(message: "POWR0   ") } // 電源
    override func volUp()         { self.sharpTVCtl(message: "        ") } // 音量アップ
    override func volDown()       { self.sharpTVCtl(message: "        ") } // 音量ダウン
    override func mute()          { self.sharpTVCtl(message: "MUTE0   ") } // 消音
    override func channelUp()     { self.sharpTVCtl(message: "CHUP-   ") } // チャンネルアップ
    override func channelDown()   { self.sharpTVCtl(message: "CHDW-   ") } // チャンネルダウン
    override func recordingList() { self.sharpTVCtl(message: "        ") } // 録画リスト
    override func guide()         { self.sharpTVCtl(message: "        ") } // 番組ガイド

    var connection: NWConnection?

    func sharpTVCtl(message: String){
        print("ctl: " + message)
        self.initTCPconnection(message: message)
    }
    func initTCPconnection(message: String) {
        guard let ipAddress = self.ipAddress else { return }
        let host = NWEndpoint.Host(ipAddress)
        let port = NWEndpoint.Port(integerLiteral: 80)

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
            }
        }

        /// コネクションの開始
        let queue = DispatchQueue(label: "label")
        self.connection?.start(queue: queue)
    }

    func send(text: String) {
        let username = self.user ?? ""
        let password = self.password ?? ""
        let message = username + "\r" + password + "\r" + text + "\r"
        let data = message.data(using: .utf8)!

        /// メッセージの送信
        connection?.send(content: data, completion: .contentProcessed { [unowned self] (error) in
            if let error = error {
                NSLog("\(#function), \(error)")
            } else {
                print("non error")
                print(String(data: data, encoding: .utf8)!)
                sleep(1)
                // let message = message(text: text, isReceived: false)
                //self.messages.acceptAppending(message)
            }
        })
    }
}

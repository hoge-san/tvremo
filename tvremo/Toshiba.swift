//
//  Toshiba.swift
//  tvremo
//

import Foundation

class ToshibaTV: TV, URLSessionTaskDelegate {
    private var user: String?
    private var password: String?
    private var ipAddress: String?

    override func set(ipAddress: String?, user: String?, password: String?) {
        self.ipAddress = ipAddress
        self.user = user
        self.password = password
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cnt = challenge.previousFailureCount
        print("previous failure count: ", cnt)
        guard cnt == 0 else {
            print("== cancel credential")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        print("== add credential")
        let user = self.user ?? ""
        let password = self.password ?? ""
        let cred = URLCredential(user: user, password: password, persistence: .forSession)
        completionHandler(.useCredential, cred)
    }

    override func power()         { self.getUrl(key: "40BF12") } // 電源
    override func volUp()         { self.getUrl(key: "40BF1A") } // 音量アップ
    override func volDown()       { self.getUrl(key: "40BF1E") } // 音量ダウン
    override func mute()          { self.getUrl(key: "40BF10") } // 消音
    override func channelUp()     { self.getUrl(key: "40BF1B") } // チャンネルアップ
    override func channelDown()   { self.getUrl(key: "40BF1F") } // チャンネルダウン
    override func recordingList() { self.getUrl(key: "40BE28") } // 録画リスト
    override func guide()         { self.getUrl(key: "40BF6E") } // 番組ガイド

    private func getUrl(key: String) {
        guard let ipAddress = self.ipAddress else { return }
        let urlString = "http://" + ipAddress +  "/remote/remote.htm?key=" + key
        guard let url = URL(string: urlString) else { return  }

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.setValue("plain/text", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            print(data)
            /*
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: [])
                print(object)
            } catch let e {
                print(e)
            }
 */

        }
        task.resume()
    }

}


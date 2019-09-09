//
//  TV.swift
//  tvremos
//

import Foundation

protocol TVctl {
    func power()   // 電源
    func volUp()   // 音量アップ
    func volDown() // 音量ダウン
    func mute()    // 消音
    func channelUp()   // チャンネルアップ
    func channelDown()  // チャンネルダウン
    func recordingList()//録画リスト
    func guide() // 番組ガイド
}

class TV: NSObject, TVctl {
    func set(ipAddress: String?, user: String?, password: String?) {}
    func power() { }
    func volUp() { }
    func volDown() { }
    func mute() { }
    func channelUp() { }
    func channelDown() { }
    func recordingList() { }
    func guide() { }
}

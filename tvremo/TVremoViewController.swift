//
//  TVremoViewController.swift
//  tvremo


import UIKit
import Intents

class TVremoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private var selectedDevice: Device?
    @IBOutlet private weak var tvPickerView: UIPickerView!
    
    @IBOutlet private weak var powerButton: UIButton!
    @IBOutlet private weak var volDownButton: UIButton!
    @IBOutlet private weak var volUpButton: UIButton!
    @IBOutlet private weak var muteButton: UIButton!
    @IBOutlet private weak var channelDownButton: UIButton!
    @IBOutlet private weak var channelUpButton: UIButton!
    @IBOutlet private weak var recordingListButton: UIButton!

    @IBAction func powerButtonAction(_ sender: Any)
    { self.prepareIntent(control: .power) ;self.selectedDevice?.tvctl?.power() }
    @IBAction func volDownButtonAction(_ sender: Any)
    { self.prepareIntent(control: .volumeDown) ; self.selectedDevice?.tvctl?.volDown() }
    @IBAction func volUpButtonAction(_ sender: Any) { self.selectedDevice?.tvctl?.volUp() }
    @IBAction func muteButtonAction(_ sender: Any)
    { self.prepareIntent(control: .mute) ;self.selectedDevice?.tvctl?.mute() }
    @IBAction func channelDownButtonAction(_ sender: Any) { self.selectedDevice?.tvctl?.channelDown() }
    @IBAction func channelUpButtonAction(_ sender: Any) { self.selectedDevice?.tvctl?.channelUp() }
    @IBAction func recordingListButtonAction(_ sender: Any) { self.selectedDevice?.tvctl?.recordingList() }

    enum TVcontrol {
        case volumeDown
        case power
        case mute
    }

    private func prepareIntent(control: TVcontrol) {
        var intent: INIntent
        switch control {
        case .volumeDown:
            let intent0 = VolumeDownIntent()
            intent0.device = selectedDevice?.name
            intent0.uuid = selectedDevice?.uuid
            intent = intent0
        case .power:
            let intent0 = PowerIntent()
            intent0.device = selectedDevice?.name
            intent0.uuid = selectedDevice?.uuid
            intent = intent0
        case .mute:
            let intent0 = MuteIntent()
            intent0.device = selectedDevice?.name
            intent0.uuid = selectedDevice?.uuid
            intent = intent0
            
        }

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tvPickerView.delegate = self
        tvPickerView.dataSource = self

        DeviceManager.load()
        self.selectedDevice = DeviceManager.getDevice(index: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TVremoViewController viewWillAppear")
        DeviceManager.refresh()
        tvPickerView.reloadAllComponents()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DeviceManager.getDeviceCount()
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DeviceManager.getDevice(index: row)?.name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedDevice = DeviceManager.getDevice(index: row)
    }
}

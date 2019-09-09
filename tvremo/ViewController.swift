//
//  ViewController.swift
//  tvremo
//

import UIKit

class ViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    private var username: String?
    private var password: String?
    private var ipAddress: String?
    private var maker: String?

    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var ipAddressTextField: UITextField!
    @IBOutlet private weak var makerTextField: UITextField!
    
    @IBOutlet private weak var powerButton: UIButton!
    @IBOutlet private weak var volDownButton: UIButton!
    @IBOutlet private weak var volUpButton: UIButton!
    @IBOutlet private weak var muteButton: UIButton!
    @IBOutlet private weak var channelDownButton: UIButton!
    @IBOutlet private weak var channelUpButton: UIButton!
    @IBOutlet private weak var recordingListButton: UIButton!
    
    @IBAction func powerButtonAction(_ sender: Any) { self.tvctl?.power() }
    @IBAction func volDownButtonAction(_ sender: Any) { self.tvctl?.volDown() }
    @IBAction func volUpButtonAction(_ sender: Any) { self.tvctl?.volUp() }
    @IBAction func muteButtonAction(_ sender: Any) { self.tvctl?.mute() }
    @IBAction func channelDownButtonAction(_ sender: Any) { self.tvctl?.channelDown() }
    @IBAction func channelUpButtonAction(_ sender: Any) { self.tvctl?.channelUp() }
    @IBAction func recordingListButtonAction(_ sender: Any) { self.tvctl?.recordingList() }

    @IBAction func passwordEditingDidEnd(_ sender: UITextField) {
        self.password = sender.text
        print("set password: " + (self.password ?? "None"))
        UserDefaults.standard.set(self.password, forKey: "password")
        self.tvctl?.set(ipAddress: self.ipAddress, user: self.username, password: self.password)
    }
    
    @IBAction func usernameEditingDidEnd(_ sender: UITextField) {
        self.username = sender.text
        print("set username: " + (self.username ?? "None"))
        UserDefaults.standard.set(self.username, forKey: "username")
        self.tvctl?.set(ipAddress: self.ipAddress, user: self.username, password: self.password)
    }
    @IBAction func ipAddressEditingDidEnd(_ sender: UITextField) {
        self.ipAddress = sender.text
        print("set ipAddress: " + (self.ipAddress ?? "None"))
        UserDefaults.standard.set(self.ipAddress, forKey: "ipAddress")
        self.tvctl?.set(ipAddress: self.ipAddress, user: self.username, password: self.password)
    }

    var pickerView: UIPickerView = UIPickerView()
    let list = ["TOSHIBA", "SHARP"]

    
    var tvctl: TV?

    func setTVctl() {
        if self.maker == "TOSHIBA" {
            self.tvctl = ToshibaTV()
        } else if self.maker == "SHARP" {
            self.tvctl = SharpTV()
        }
        self.tvctl?.set(ipAddress: self.ipAddress, user: self.username, password: self.password)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.username = UserDefaults.standard.string(forKey: "username")
        self.password = UserDefaults.standard.string(forKey: "password")
        self.ipAddress = UserDefaults.standard.string(forKey: "ipAddress")
        self.maker = UserDefaults.standard.string(forKey: "maker")
        self.usernameTextField.text = self.username
        self.passwordTextField.text = self.password
        self.ipAddressTextField.text = self.ipAddress
        self.makerTextField.text = self.maker

        print("ipAddress: " + (self.ipAddress ?? "None"))
        print("username: " + (self.username ?? "None"))
        print("password: " + (self.password ?? "None"))
        print("Maker: " + (self.maker ?? "None"))

        self.setTVctl()

        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        self.makerTextField.inputView = pickerView
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }


    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.makerTextField.text = list[row]
        self.maker = list[row]
        UserDefaults.standard.set(self.maker, forKey: "maker")
        setTVctl()
    }

    func cancel() {
        self.makerTextField.text = ""
        self.makerTextField.endEditing(true)
    }

    func done() {
        self.makerTextField.endEditing(true)
    }
}


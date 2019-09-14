//
//  ChangeDeviceDetail.swift
//  tvremo

import UIKit

class ChangeDeviceDetail: UIViewController {
    var device: Device?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var venderLabel: UILabel!
    @IBOutlet weak var v4addrLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = device?.name
        venderLabel.text = (device?.vender).map { $0.rawValue }
        v4addrLabel.text = device?.v4addr
        usernameTextField.text = device?.username
        passwordTextField.text = device?.password
    }

    @IBAction func passwordEditingDidEnd(_ sender: UITextField) {
        print("passwordEditingDidEnd")
        device?.password = sender.text ?? ""
    }

    @IBAction func usernameEditingDidEnd(_ sender: UITextField) {
        device?.username = sender.text ?? ""
    }

    @IBAction func deleteAction(_ sender: Any) {
        DeviceManager.delete(device: device!)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func registerAction(_ sender: Any) {
        DeviceManager.change(device: device!)
        self.dismiss(animated: true, completion: nil)
    }
}

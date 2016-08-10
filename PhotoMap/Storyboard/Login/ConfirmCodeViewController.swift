//
//  ConfirmCodeViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/7/31.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AWSCognitoIdentityProvider


class ConfirmCodeViewController: UIViewController {
    
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var resentCodeButton: UIButton!
    
    var user: AWSCognitoIdentityUser!
    var sentTo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        setupRx()
    }
    
    func setupRx() {
        
        codeTextField
            .rx_text
            .map { $0.characters.count == 6 }
            .bindTo(confirmButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
        confirmButton.rx_tap
            .subscribeNext { [unowned self] in self.confirm() }
            .addDisposableTo(disposeBag)
        
        resentCodeButton.rx_tap
            .subscribeNext { [unowned self] in self.resentCode() }
            .addDisposableTo(disposeBag)
    }
    
    let pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
    
    func confirm() {
        
        title = "正在验证..."
        
        user.confirmSignUp(codeTextField.text!).continueWithBlock { task in
            Queue.Main.execute {
                switch task.error {
                case let error?:
                    self.title = "验证失败..."
                    print(error.localizedDescription)
                    
                case nil:
                    self.title = "验证成功"
                    (self.navigationController?.viewControllers.first as? LoginViewController)?.usernameTextField.text = self.user.username
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                }
            }
            return nil
        }
        
    }
    
    func resentCode() {
        
        title = "正在重新发送验证码..."
        
        user.resendConfirmationCode().continueWithBlock { task in
            Queue.Main.execute {
                switch task.error {
                case let error?:
                    self.title = "验证码发送失败..."
                    print(error.localizedDescription)
                    
                case nil:
                    self.title = "验证发送成功"

                }
            }
            return nil
        }
    }
    
    func updateUI() {
        sentToLabel.text = "Code sent to:  \(sentTo ?? "")"
        usernameTextField.text = user.username
    }
}

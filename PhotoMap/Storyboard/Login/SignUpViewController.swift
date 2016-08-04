//
//  SignUpViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/7/31.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AWSCognitoIdentityProvider

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    let disposeBag = DisposeBag()
    
    func setupRx() {
        
        let usernameValid = usernameTextField
            .rx_text
            .map { !$0.isEmpty }
        
        let passwordValid = passwordTextField
            .rx_text
            .map { $0.characters.count > 7 }
        
        let phoneValid = phoneTextField
            .rx_text
            .map { !$0.isEmpty }
        
        let emailValid = emailTextField
            .rx_text
            .map { !$0.isEmpty }
        
        Observable
            .combineLatest(usernameValid, passwordValid, phoneValid, emailValid) { $0 && $1 && $2 && $3 }
            .bindTo(signUpButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
        signUpButton.rx_tap
            .subscribeNext { [unowned self] in self.signUp() }
            .addDisposableTo(disposeBag)
    }
    
    let pool = LoginProvider.sharedInstance().pool

    func signUp() {
        
        title = "正在注册..."
        
        
        let attributes = [
            AWSCognitoIdentityUserAttributeType(name: "phone_number", value: phoneTextField.text),
            AWSCognitoIdentityUserAttributeType(name: "email", value: emailTextField.text),
            ]
        
        pool.signUp(usernameTextField.text!, password: passwordTextField.text!, userAttributes: attributes, validationData: nil)
            .continueWithBlock { task in
                print("task.error", task.error)
                print("task.result", task.result)
                switch (task.error, task.result) {
                case let (error?, _):
                    Queue.Main.execute { self.title = "注册失败..." }
                    print(error.localizedDescription)
                case let (_, result?) where result.user.confirmedStatus != .Confirmed :
                    Queue.Main.execute {
                        self.title = "请输入验证码."
                        self.performSegueWithIdentifier("ConfirmCode", sender: result.codeDeliveryDetails??.destination)
                    }
                default:
                    Queue.Main.execute { self.title = "注册成功" }
                }
                
                return nil
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ConfirmCode" {
            let ccvc = segue.destinationViewController as! ConfirmCodeViewController
            ccvc.user = pool.getUser(usernameTextField.text!)
            ccvc.sentTo = sender as? String
        }
    }
    
}

extension AWSCognitoIdentityUserAttributeType {
    
    convenience init(name: String, value: String?) {
        self.init()
        self.name = name
        self.value = value
    }
}

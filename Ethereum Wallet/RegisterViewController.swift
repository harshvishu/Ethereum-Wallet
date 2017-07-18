//
//  RegisterViewController.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import UIKit
import Reusable
import Alamofire


class RegisterViewController: UIViewController , StoryboardSceneBased{
    
    // storyboard
    static var storyboard: UIStoryboard = Storyboards.loginRegister
    
    @IBOutlet weak var ipName: UITextField!
    @IBOutlet weak var ipEmail: UITextField!
    @IBOutlet weak var ipPasswd: UITextField!
    @IBOutlet weak var ipPhone: UITextField!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var buttonAlter: UIButton!
    
    var request: Request?
    
    // Enum for Login/Register Mode
    private enum Mode: Int{
        case login
        case register
    }
    
    // mode
    private var mode: Mode = .login
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // present login view initially
        ipName.isHidden = true
        ipPhone.isHidden = true
        
        buttonSubmit.setTitle(StringConstants.login.capitalized , for: .normal)
    }
    
    @IBAction func actionSubmit(_ sender: Any) {
        
        // get text from input fields
        let email = ipEmail.text ?? ""
        let name = ipPasswd.text ?? ""
        let phone = ipPhone.text ?? ""
        let passwd = ipPasswd.text ?? ""
        
        if !email.matches(rex: RexPatterns.email){
            alert(StringConstants.invalid_email, message: StringConstants.prompt_invalid_email)
            return
        }
        
        if mode == .register{
            if name.isEmpty{
                alert(StringConstants.no_name, message: StringConstants.prompt_no_name)
                return
            }
            
            if phone.isEmpty{
                alert(StringConstants.invalid_phone, message: StringConstants.prompt_invalid_phone)
                return
            }
        }
        
        if passwd.isEmpty{
            alert(StringConstants.invalid_password, message: StringConstants.prompt_invalid_password)
            return
        }
        
        let progressView = ActivityProgressView.loadFromNib()
        self.view.addMaximized(view: progressView)
        
        if mode == .login{
            let urlRequest = Api.login(email: email, password: passwd)
            
            progressView.set(message: StringConstants.signingIn)

            request = Alamofire.request(urlRequest)
                .debugLog()
                .responseString{print($0)}
                .responseObject{[weak self] (response: DataResponse<UserLoginResponse>) in
                    guard let `self` = self
                        else {return}
                    
                    progressView.removeFromSuperview()
                    
                    if case let .success(json) = response.result{
                        
                        //                        print("received \(json)")
                        
                        if let token = json.token{
                            
                            UserData.token = token
                            NotificationCenter.default.post(name: NotificationNames.didLogin, object: nil)
                            
                            // return here
                            return
                        }
                        
                        if let error = json.error{
                            
                            // fetch the error code
                            let message = error.message
                            
                            self.alert("Alert!", message: message)
                            return
                        }
                        
                        // todo pending errors
                        self.alert("Unable to process!", message: StringConstants.something_went_wrong.capitalized)
                        
                    }
                        
                    else if case let .failure(error) = response.result{
                        guard error.localizedDescription != StringConstants.cancelled else {
                            return
                        }
                        self.alert("", message: error.localizedDescription)
                    }
            }
            
        }else{
            let urlRequest = Api.register(email: email, password: passwd, name: name, phone: phone)
            
            progressView.set(message: StringConstants.creatingAccount)
            
            request = Alamofire.request(urlRequest)
//                .debugLog()
//                .responseString{print($0)}
                .responseObject{ [weak self] (response: DataResponse<UserRegisterResponse>) in
                    
                    guard let `self` = self
                        else {return}
                    
                    // remove progress view
                    progressView.removeFromSuperview()

                    
                    if case let .success(json) = response.result{
                        
                        if let token = json.token{
                            
                            UserData.token = token
                            NotificationCenter.default.post(name: NotificationNames.didLogin, object: nil)
                            
                            // return here
                            return
                        }else if let meta = json.meta{
                            
                            // fetch the error code
                            let errmsg = meta.body.errmsg
                            
                            if errmsg.contains("email_1 dup"){
                                self.alert("Email address already in use", message: StringConstants.login_user_message)
                                
                                // we found the error
                                return
                            }
                            if errmsg.contains("phone_1 dup"){
                                self.alert("Phone number already in use", message: StringConstants.login_user_message)
                                
                                // we found the error
                                return
                            }
                        }
                        
                        self.alert("Unable to process!", message: StringConstants.something_went_wrong.capitalized)
                        
                    }else if case let .failure(error) = response.result{
                        guard error.localizedDescription != StringConstants.cancelled else {
                            return
                        }
                        self.alert("", message: error.localizedDescription)
                    }
                    
            }
        }
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        
        // cancel request is moving out of this controller
        if parent == nil{
            request?.cancel()
        }
    }
    
    @IBAction func actionAlter(_ sender: Any) {
        
        func changeMode(){
            if mode == .login {
                mode = .register
            }else {
                mode = .login
            }
            
            let isHidden = mode == .login
            let buttonSubmitText = mode == .login ? StringConstants.login.capitalized : StringConstants.register.capitalized
            let buttonAltertext = mode == .login ? StringConstants.register_user_message.capitalized : StringConstants.login_user_message
            
            UIView.animate(withDuration: 0.250, animations: { [unowned self] in
                self.ipName.isHidden = isHidden
                self.ipPhone.isHidden = isHidden
                self.buttonSubmit.setTitle(buttonSubmitText, for: .normal)
                self.buttonAlter.setTitle(buttonAltertext, for: .normal)
            })
        }
        
        
        changeMode()
        
    }
}

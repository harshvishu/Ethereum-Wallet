//
//  SendEtherViewController.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/17/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import UIKit
import Reusable
import AVFoundation
import QRCodeReader
import Alamofire

class SendEtherViewController: UIViewController, StoryboardSceneBased {
    static var storyboard: UIStoryboard = Storyboards.wallet
    
    @IBOutlet weak var ipAmount: UITextField!
    
    // hold the request
    var request: Request?
    var account: Account?
    
    var toUser: String?
    
    @IBOutlet weak var imageViewQRCode: UIImageView!
    
    lazy private var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = StringConstants.fundsTransfer
        
        guard  account != nil else {
            alert(StringConstants.alert, message: StringConstants.accountNotAvailable, ok: StringConstants.ok, action: { _ in
                self.finish()
            })
            return
        }
        
        // Do any additional setup after loading the view.
        readerVC.delegate = self
        
    }
    
    @IBAction func actionSendFunds(_ sender: Any) {
        
        guard let toUser = toUser, !toUser.isEmpty else {
            alert(StringConstants.alert, message: StringConstants.scanNoUserAlert, ok: StringConstants.ok, action: { _ in
                self.actionScan(sender)
            })
            return
        }
        
        guard let amount = ipAmount.text, !amount.isEmpty else{
            alert(StringConstants.alert, message: StringConstants.invalidAmount, ok: StringConstants.ok, action: { _ in
                self.ipAmount.becomeFirstResponder()
            })
            return
        }
        
        
        let progressView = ActivityProgressView.loadFromNib()
        view.addMaximized(view: progressView)
        progressView.set(message: StringConstants.transferingFunds)
        
        request =  Alamofire.request(Api.sendFunds(to: toUser, amount: amount))
            .responseString{print($0)}
            .responseObject{ [weak self] (response: DataResponse<FundsTransferResponse>) in
                guard let `self` = self
                    else {return}
                
                defer{
                    progressView.removeFromSuperview()
                }
                
                if case let .success(json) = response.result{
                    
                    
                    if let _ = json.transaction{
                        self.alert(StringConstants.fundsTransfer, message: StringConstants.transferSuccessful, ok: StringConstants.ok, action: { _ in
                            self.finish()
                        })
                        // return here
                        return
                    }
                    
                    if let message = json.error?.message{
                        
                        // present Create Wallet controller
                        if message.contains(StringConstants.walletNotFoundError){
                            
                            let createWalletController = CreateWalletViewController.instantiate()
                            createWalletController.modalPresentationStyle = .overCurrentContext
                            self.present(createWalletController, animated: true, completion: nil)
                            
                        }
                        
                        // todo pending errors
                        self.alert(StringConstants.alert, message: message)
                        return
                    }
                    
                    // todo pending errors
                    self.alert("Unable to process!", message: StringConstants.something_went_wrong.capitalized)
                    
                }else if case let .failure(error) = response.result{
                    guard error.localizedDescription != StringConstants.cancelled else {
                        return
                    }
                    self.alert("", message: error.localizedDescription)
                }
            }
            .debugLog()
    }
    
    func finish(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionScan(_ sender: Any) {
        
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
}

extension SendEtherViewController: QRCodeReaderViewControllerDelegate{
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
        
        debugPrint(result.value)
        
        toUser = result.value
        
        imageViewQRCode.setQRCodefrom(string: result.value)
        
        ipAmount.becomeFirstResponder()
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
        
    }
}

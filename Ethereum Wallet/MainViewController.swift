//
//  MainViewController.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import UIKit
import Reusable
import Alamofire

class MainViewController: UIViewController, StoryboardSceneBased {
    static var storyboard: UIStoryboard = Storyboards.main
    
    fileprivate let sectionHeader = 0
    fileprivate let sectionTransactions = 1
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var labelBalance: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var numberFormatter:NumberFormatter = {
        // set balance for locale format
        // Rupee symbol for india
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    
    
    // transactions
    fileprivate var transactions: [RecentTransactionsResponse.Transaction] = []
    
    // hold network request
    var requests: [Request] = []
    
    var account: Account?{
        didSet{
            self.setBalanceTextLabel()
            // fetch transactions
            self.fetchTransactions()
        }
    }
    
    var balance: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up title
        let titleView = UILabel()
        titleView.text = StringConstants.appName
        titleView.font = UIFont(name: "Menlo", size: 24)
        titleView.sizeToFit()
        
        navigationItem.titleView = titleView
        
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "sign-out").tint(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)), style: .done, target: self, action: #selector(signOut(_:)))
        navigationItem.setRightBarButton(rightButton, animated: false)
        
        // register cell for header
        tableView.register(cellType: WalletTransactionsHeaderView.self)
        tableView.register(cellType: TransactionTableViewCell.self)
        
        tableView.estimatedRowHeight = 72
        tableView.estimatedSectionHeaderHeight = 72
        tableView.delegate = self
        tableView.dataSource = self
        
        // empty footer
        tableView.tableFooterView = UIView()
        
        // fetch walle tinformation
        
        fetchWallet()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedAccountInfo(_:)), name: NotificationNames.walletCreated, object: nil)
    }
    
    func receivedAccountInfo(_ notification: Notification){
        if let account = notification.userInfo?[StringConstants.dictKeyAccount] as? Account{
            self.account = account
        }
    }
    
    // Make network request & check if wallet exists
    private func fetchWallet(){
        // add a blur effect on screent till we are fetching data
        let progressView = ActivityProgressView.loadFromNib()
        
        view.addMaximized(view: progressView)
        
        let request = Alamofire.request(Api.wallet())
            .responseObject{ [weak self] (response: DataResponse<WalletResponse>) in
                guard let `self` = self
                    else {return}
                
                defer{
                    progressView.removeFromSuperview()
                }
                
                if case let .success(json) = response.result{
                    
                    if let balanceString = json.balance, let balance = Double(balanceString),
                        let account = json.account{
                        
                        self.balance = self.numberFormatter.string(from: NSNumber(value: balance))
                        self.account = account
                        
                        // return here
                        return
                    }
                    
                    if let message = json.error?.message{
                        
                        // present Create Wallet controller
                        if message.contains(StringConstants.walletNotFoundError){
                            
                            let createWalletController = CreateWalletViewController.instantiate()
                            createWalletController.modalPresentationStyle = .overCurrentContext
                            self.present(createWalletController, animated: true, completion: nil)
                            return
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
        //            .debugLog()
        //            .responseString{print($0)}
        
        // append to requests
        requests.append(request)
    }
    
    
    
    private func fetchTransactions(){
        print(">>>>>>> FETCH  TRANSACTIONS")
        
        let request = Alamofire.request(Api.history())
            //            .responseString{print($0)}
            .responseObject{[weak self] (response: DataResponse<RecentTransactionsResponse>) in
                guard let `self` = self
                    else {return}
                
                defer{
                    self.tableView.reloadData()
                }
                
                if case let .success(json) = response.result{
                    
                    if let status = json.status{
                        if status == 1{
                            let transactions = json.transactions
                            self.transactions = transactions
                        }
                        // return here
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
        
        requests.append(request)
    }
    
    // set the balance
    private func setBalanceTextLabel(){
        if balance == nil || balance!.isEmpty{
            balance = numberFormatter.string(from: NSNumber(value: 0.00))
        }
        
        self.labelBalance.text = balance
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil{
            // cancel all request when moving away from this controller
            requests.forEach{$0.cancel()}
            
        }
    }
    
    // signout
    func signOut(_ sender: Any) {
        alert(StringConstants.signOut, message: StringConstants.areYouSure, cancellable: true ,ok: StringConstants.ok) { _ in
            logout()
        }
    }
}

// tableView: delegate
extension MainViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == sectionHeader{
            return nil
        }
        return indexPath
    }
}
// tableView : datasource
extension MainViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sectionHeader{
            return 1
        }
        
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(at: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // header for sections with transactions
        if section == 1{
            return StringConstants.recentTransactions.uppercased()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    private func configureCell(at indexPath: IndexPath) -> UITableViewCell{
        if indexPath.section == sectionHeader{
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WalletTransactionsHeaderView.self)
            
            print(">>>>>CONFIGURE HEADER")
            if let account = account{
                let viewModel = TransactionHeaderViewModel(viewController: self, account: account)
                cell.configure(delegate: viewModel)
            }else{
                print(">>>>> NO  ACCOUNT")
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: TransactionTableViewCell.self)
        
        // fetch the transaction
        let transaction = transactions[indexPath.row]
        
        if let account = account{
            let viewModel = TransactionViewModel(transaction: transaction, account: account)
            cell.configure(delegate: viewModel)
        }
        return cell
    }
}

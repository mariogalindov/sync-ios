//
//  Quickstart_token_bank_ViewController.swift
//
//  Created by Gabriel Villarreal on 30/06/16.
//  Copyright © 2016 Paybook.Inc. All rights reserved.
//

import UIKit
import Paybook

class Quickstart_token_bank_ViewController: UIViewController {

    var timer : Timer!
    var count = 1
    
    var user : User!
    var session : Session!
    var site : Site!
    var credential : Credentials!
    var sat_sync_completed = false
    
    
    @IBOutlet weak var tokenInput: UITextField!
    
    @IBAction func sendToken(_ sender: AnyObject) {
        
        let params : NSDictionary = ["token": tokenInput.text ?? ""]
        print("Send token: \(params)")
        
        self.credential.set_twofa(self.session, id_user: nil, params: params, completionHandler: {
            response, error in
            if response != nil && response == true{
                self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.checkStatus), userInfo: nil, repeats: true)
            }else{
                print("\(error?.message)")
            }
        })
        
    }
    
    
    
    func getUsers(){
        User.get(){
            response,error in
            if response != nil {
                self.user = response![0]
                print("User: \(self.user.name) \(self.user.id_user)")
                self.createSession()
            }
        }
    }
    
    func createSession(){
        
        self.session = Session(id_user: self.user.id_user, completionHandler: {
            session_response, error in
            
            if session_response != nil {
                self.session = session_response
                self.getCatalogueSite()
            }else{
                print("No se pudo crear la session: \(error?.message)")
            }
        })
        
    }
    
    func getCatalogueSite(){
        Catalogues.get_sites(self.session, id_user: nil, is_test: nil, completionHandler: {
            sites_array, error in
            
            if sites_array != nil{
                
                print("\nCatalago de Sites:")
                for site in sites_array!{
                    
                    if site.name == "Banorte en su empresa" {
                        print ("selected: \(site.name) \(site.id_site)")
                        self.site = site
                    }else{
                        print(site.name)
                    }
                    
                }
                
                if self.site != nil{
                    self.createCredential()
                }
                
            }
            
        })
        
        
    }
    
    
    func createCredential(){
        let data = [
            "username" : "YOUR_BANK_USERNAME",
            "password" : "YOUR_BANK_PASSWORD"
        ]
        
        _ = Credentials(session: self.session, id_user: nil, id_site: site.id_site, credentials: data as NSDictionary, completionHandler: {
            credential_response , error in
            if credential_response != nil {
                
                self.credential = credential_response
                print("\nCheck Status:")
                self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.checkStatus), userInfo: nil, repeats: true)
                
                
            }else{
                print("No se pudo crear las credenciales: \(error?.message)")
            }
            
        })
    }
    
    
    func checkStatus(){
        
        credential.get_status(self.session, id_user: nil, completionHandler: {
            response, error in
            
            print("response status:",response,"error",error)
            if response != nil{
                
                let status = response![response!.count-1]
                
                switch status["code"] as! Int{
                case 100,101,102:
                    print("Processing...\(status["code"])")
                    break
                case 200,201,202,203:
                    print("Success...\(status["code"])")
                    self.timer.invalidate()
                    self.getTransactions()
                    break
                case 401,405,406,411:
                    print("User Error \(status)")
                    self.timer.invalidate()
                    break
                case 410:
                    print("Waiting for two-fa \(status["code"])")
                    self.timer.invalidate()
                    break
                case 500,501,504,505,508:
                    print("System Error \(status["code"])")
                    self.timer.invalidate()
                    break
                default :
                    break
                }
            }else{
                print("Fail: \(error?.message)")
                
            }
            
            
        })
        
    }

    
    func getTransactions(){
        Transaction.get(self.session, id_user: nil, completionHandler: {
            transaction_array, error in
            if transaction_array != nil {
                print("\nTransactions: ")
                for transaction in transaction_array! {
                    print("$\(transaction.amount), \(transaction.description) ")
                }
                self.getAttachments()
                
            }else{
                print("Problemas al consultar las transacciones: \(error?.message)")
            }
            
        })
    }
    
    
    func getAttachments(){
        Attachments.get(session, id_user: nil, completionHandler: {
            attachments_array, error in
            if attachments_array != nil {
                print("\nAttachments: ")
                for attachment in attachments_array! {
                    print("Attachment type : \(attachment.id_attachment_type), id_transaction: \(attachment.id_transaction) ")
                }
                
                
            }else{
                print("Problemas al consultar los attachments: \(error?.message)")
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        sendToken(self)
        
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Paybook.api_key = "YOUR_API_KEY"
        getUsers()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}

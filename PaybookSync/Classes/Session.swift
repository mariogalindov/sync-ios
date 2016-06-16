//
//  Session.swift
//  Pods
//
//  Created by Gabriel Villarreal on 08/06/16.
//
//

import Foundation
import Alamofire


public class Session: Paybook {
    
    public var token : String!
    public var id_user : String!
    
    
    
    
    // ** MARK Convenience INIT
    
    /** To init a Session you can use this code
     
     _ = Session(id_user: "[id_user]", completionHandler: {
     session , error in
     print("Session created in API = \(session?.token); error = \(error)")
     })
     
     */
    
    public convenience init(id_user: String, completionHandler: ((Session?, NSError?) -> ())?){
        self.init()
        
        self.id_user = id_user
        
        
        var data = [
            "id_user" : id_user
        ]
        
        let url = "sessions"
        
        
        Paybook.call("POST", endpoint: url, parameters: data, completionHandler: {
            response, error in
            
            if response != nil {
                if var responseObject = response!["response"] as? NSDictionary{
                    self.token = responseObject["token"] as? String
                    if completionHandler != nil {
                        completionHandler!(self,error)
                    }
                }
                
                
            }else{
                if completionHandler != nil {
                    completionHandler!(nil,error)
                }
            }

        
        })
        
        
        
        
    }
    
   
    // ** MARK Class Methods
    
    /** Example to delete a Session
     
     Session.delete("[token]", completionHandler: {
        responseObject, error in
        print("responseObject = \(responseObject); error = \(error)")
        return
     })
     
     */
    
    public class func delete(token: String, completionHandler: ((NSDictionary?, NSError?) -> ())?){
        
        
        
        let url = "sessions/\(token)"
        
        self.call("DELETE", endpoint: url, parameters: nil, completionHandler: {
            response, error in
            
            if response != nil {
                if completionHandler != nil {
                    completionHandler!(response,error)
                }
                
            }else{
                if completionHandler != nil {
                    completionHandler!(nil,error)
                }
            }
            
        })
        
        
        
        
        
    }
    
   
    
    // ** MARK Instance Methods
    
    /** Example to validate Session
     
     mySession.validate() {
        responseObject , error in
        print("responseObject = \(responseObject); error = \(error)")
        return
     }
    
    */
    
    public func validate(completionHandler: ((NSDictionary?, NSError?) -> ())?) {//-> [User]?{
        
        
        let url = "sessions/\(self.token)/verify"
        
        
        Paybook.call("GET", endpoint: url, parameters: nil, completionHandler: {
            response, error in
            
            if response != nil {
                if completionHandler != nil {
                    completionHandler!(response,error)
                }
                
            }else{
                if completionHandler != nil {
                    completionHandler!(nil,error)
                }
            }
            
        })
    }
    
    

    
    
    
    
}

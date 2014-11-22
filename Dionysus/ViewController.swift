//
//  ViewController.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/6/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var passwordField: UITextField?
    @IBOutlet var tokenLabel: UILabel?
    @IBOutlet var usernameField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func generateAuth() {
        func success(request: NSURLRequest, token: String!)  -> Void {
            self.updateTokenInfo()
        }
        
        func failure(request: NSURLRequest, json: NSDictionary!)  -> Void {
            self.updateTokenInfo()
        }
        
        WebOperations.login(success, failure: failure)
    }
    
    @IBAction func fetchDevices() {
        func success(request: NSURLRequest, deviceList: [Device]!)  -> Void {
            if deviceList.count > 0 {
                self.tokenLabel!.text = deviceList[0].valueForKey(kAliasKey) as? String
            }
        }
        
        WebOperations.fetchDevices(success, failure: nil)
    }
    
    func updateTokenInfo() {
        if let token = WebOperations.authToken() {
            self.tokenLabel!.text = "Token Generated"
            self.tokenLabel!.textColor = UIColor.greenColor()
        } else {
            self.tokenLabel!.text = "Error Generating Token"
            self.tokenLabel!.textColor = UIColor.redColor()
        }
    }
}


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
        // Do any additional setup after loading the view, typically from a nib.
        
        if WebOperations.AuthToken() == nil {
            self.generateAuth()
        } else {
            self.updateTokenInfo()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func generateAuth() {
        func successOrFailure(request: NSURLRequest, json: NSDictionary!)  -> Void {
            self.updateTokenInfo()
        }
        
        WebOperations.login(self.usernameField!.text, password: self.passwordField!.text, completion: successOrFailure, failure: successOrFailure)
    }
    
    func updateTokenInfo() {
        if let token = WebOperations.AuthToken() {
            self.tokenLabel!.text = "Token Generated"
            self.tokenLabel!.textColor = UIColor.greenColor()
        } else {
            self.tokenLabel!.text = "Error Generating Token"
            self.tokenLabel!.textColor = UIColor.redColor()
        }
    }
}


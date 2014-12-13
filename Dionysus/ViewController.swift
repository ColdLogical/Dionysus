//
//  ViewController.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/6/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var currentEnvironmentLabel: UILabel?
    @IBOutlet var defaultDeviceLabel: UILabel?
    @IBOutlet var environmentField: UITextField?
    @IBOutlet var passwordField: UITextField?
    @IBOutlet var tokenLabel: UILabel?
    @IBOutlet var usernameField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WebOperations.authToken() == nil {
            generateAuth()
        } else {
            updateTokenInfo()
        }
        
        updateEnvironment()
        updateDefaultDevice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func generateAuth() {
        func success(request: NSURLRequest, token: String!) {
            self.updateTokenInfo()
        }
        
        func failure(request: NSURLRequest, error: NSError) {
            self.updateTokenInfo()
        }
        
        WebOperations.login(success, failure: failure)
    }
    
    @IBAction func fetchDevices() {
        func success(request: NSURLRequest, deviceList: [Device]!) {
            updateDefaultDevice()
        }
        
        WebOperations.fetchDevices(success, failure: nil)
    }
    
    @IBAction func fetchFavorites() {
        func success(request: NSURLRequest, channels: [Channel]!) {
            
        }
    }
    
    @IBAction func setEnvironment() {
        WebOperations.setBaseURL(self.environmentField!.text)
        generateAuth()
    }
    
    //MARK: Operational
    func updateDefaultDevice() {
        if let device = Device.defaultDevice() {
            self.defaultDeviceLabel!.text = device.valueForKey(kAliasKey) as? String
        }
    }
    
    func updateEnvironment() {
        let env = WebOperations.baseURL()
        self.currentEnvironmentLabel!.text = env
        self.environmentField!.text = env
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


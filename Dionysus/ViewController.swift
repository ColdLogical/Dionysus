//
//  ViewController.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 11/6/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import UIKit

/**
*       Containing app default view controller for managing data used by the watch extension
*/
class ViewController: UIViewController {
        /// Outlet to the label to display the current environment
        @IBOutlet var currentEnvironmentLabel: UILabel?
        /// Outlet to the label to display the default device
        @IBOutlet var defaultDeviceLabel: UILabel?
        /// Outlet to the text field to display or alter the environment endpoint
        @IBOutlet var environmentField: UITextField?
        /// Outlet to the text field to display or alter the password
        @IBOutlet var passwordField: UITextField?
        /// Outlet to the label to display if a token was generated
        @IBOutlet var tokenLabel: UILabel?
        /// Outlet to the text field to display or alter the username
        @IBOutlet var usernameField: UITextField?
        
        /**
        On load, generate an auth token if needed, and then update the environment and default device information
        */
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
        /**
        Generates an auth token and makes a call to update the UI with the received information
        */
        @IBAction func generateAuth() {
                func success(request: NSURLRequest, token: String!) {
                        self.updateTokenInfo()
                }
                
                func failure(request: NSURLRequest, error: NSError) {
                        self.updateTokenInfo()
                }
                
                WebOperations.login(success, failure: failure)
        }
        
        /**
        Makes a web operation call to fetch all the devices for the user, then updates the default device field
        */
        @IBAction func fetchDevices() {
                func success(request: NSURLRequest, deviceList: [Device]!) {
                        updateDefaultDevice()
                }
                
                WebOperations.fetchDevices(success, failure: nil)
        }
        
        /**
        Makes a web operation call to fetch the users favorite channels
        */
        @IBAction func fetchFavorites() {
                func success(request: NSURLRequest, channels: [Channel]!) {
                        
                }
        }
        
        /**
        Creates and presents a local notification
        */
        @IBAction func sendNotification() {
                let notif = UILocalNotification()
                notif.alertAction = "Your Mom"
                
                UIApplication.sharedApplication().presentLocalNotificationNow(notif)
        }
        
        /**
        Sets the environment URL in the user default suite and makes a call to regenerate the authorization token
        */
        @IBAction func setEnvironment() {
                WebOperations.setBaseURL(self.environmentField!.text)
                generateAuth()
        }
        
        //MARK: Operational
        /**
        Updates the default device label with the alias of the default device
        */
        func updateDefaultDevice() {
                if let device = Device.defaultDevice() {
                        self.defaultDeviceLabel!.text = device.valueForKey(kAliasKey) as? String
                }
        }
        
        /**
        Updates the environment label with the base URL used by the WebOperations class
        */
        func updateEnvironment() {
                let env = WebOperations.baseURL()
                self.currentEnvironmentLabel!.text = env
                self.environmentField!.text = env
        }
        
        /**
        Visually indicates if a token is currently generated or if there was a problem generating one
        */
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


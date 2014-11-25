//
//  DionysusXInterfaceController.swift
//  DionysusX
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit
import NotificationCenter

class DionysusInterfaceController: WKInterfaceController {
    @IBOutlet var tokenLabel: WKInterfaceLabel?
    let dataClass = WebOperations.self
    
    override init(context: AnyObject?) {
        super.init(context: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
        
        if dataClass.authToken() == nil {
            self.generateAuth()
        } else {
            self.updateTokenInfo()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
    
    @IBAction func generateAuth() {
        func success(request: NSURLRequest, token: String!)  -> Void {
            self.updateTokenInfo()
        }
        
        func failure(request: NSURLRequest, json: NSDictionary!)  -> Void {
            self.updateTokenInfo()
        }
        
        dataClass.login(success, failure: failure)
    }
    
    @IBAction func fetchDevices() {
        func success(request: NSURLRequest, deviceList: [Device]!)  -> Void {
            if deviceList.count > 0 {
                self.tokenLabel!.setText(deviceList[0].alias)
            }
        }
        
        dataClass.fetchDevices(success, failure: nil)
    }
    
    func updateTokenInfo() {
        if let token = dataClass.authToken() {
            self.tokenLabel!.setText(dataClass.authToken()!)
            self.tokenLabel!.setTextColor(UIColor.greenColor())
        } else {
            self.tokenLabel!.setText("Error Generating Token")
            self.tokenLabel!.setTextColor(UIColor.redColor())
        }
    }
}

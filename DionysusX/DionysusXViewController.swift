//
//  DionysusXViewController.swift
//  DionysusX
//
//  Created by Bush, Ryan M on 11/14/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import UIKit
import NotificationCenter

class DionysusXViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var tokenLabel: UILabel?
    let dataClass = MockOperations.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if dataClass.authToken() == nil {
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
        
        dataClass.login(successOrFailure, failure: successOrFailure)
    }
    
    func updateTokenInfo() {
        if let token = dataClass.authToken() {
            self.tokenLabel!.text = dataClass.authToken()!
            self.tokenLabel!.textColor = UIColor.greenColor()
        } else {
            self.tokenLabel!.text = "Error Generating Token"
            self.tokenLabel!.textColor = UIColor.redColor()
        }
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        self.tokenLabel!.text = NSStringFromUIEdgeInsets(defaultMarginInsets)
        self.preferredContentSize = CGSizeMake(0,375)
        return UIEdgeInsetsZero
    }
}

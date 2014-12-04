//
//  ChannelTuner.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 12/3/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit
import NotificationCenter

class ChannelTuner: WKInterfaceController {
    @IBOutlet var channelLabel: WKInterfaceLabel?
    @IBOutlet var inputLabel: WKInterfaceLabel?
    
    //Buttons
    @IBOutlet var zeroButton: WKInterfaceButton?
    @IBOutlet var oneButton: WKInterfaceButton?
    @IBOutlet var twoButton: WKInterfaceButton?
    @IBOutlet var threeButton: WKInterfaceButton?
    @IBOutlet var fourButton: WKInterfaceButton?
    @IBOutlet var fiveButton: WKInterfaceButton?
    @IBOutlet var sixButton: WKInterfaceButton?
    @IBOutlet var sevenButton: WKInterfaceButton?
    @IBOutlet var eightButton: WKInterfaceButton?
    @IBOutlet var nineButton: WKInterfaceButton?
    
    var currentInput: String?
    
    override init(context: AnyObject?) {
        super.init(context: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
    
    func addNumber(input: String!) {
        if currentInput == nil {
            currentInput = input
            inputLabel!.setText(currentInput)
        } else {
            if currentInput!.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) < 3 {
                currentInput! += input
                inputLabel!.setText(currentInput!)
            }
        }
    }
    
    @IBAction func clear() {
        currentInput = nil
        inputLabel!.setText("---")
        channelLabel!.setText("")
    }
    
    @IBAction func sendToTv() {
        WebOperations.tuneToChannel(currentInput!, deviceMacAddress: "000004A8C1BE", completion: nil, failure: nil)
    }
    
    //MARK: Button Presses
    @IBAction func zeroPressed() {
        addNumber("0")
    }
    
    @IBAction func onePressed() {
        addNumber("1")
    }
    
    @IBAction func twoPressed() {
        addNumber("2")
    }
    
    @IBAction func threePressed() {
        addNumber("3")
    }
    
    @IBAction func fourPressed() {
        addNumber("4")
    }
    
    @IBAction func fivePressed() {
        addNumber("5")
    }
    
    @IBAction func sixPressed() {
        addNumber("6")
    }
    
    @IBAction func sevenPressed() {
        addNumber("7")
    }
    
    @IBAction func eightPressed() {
        addNumber("8")
    }
    
    @IBAction func ninePressed() {
        addNumber("9")
    }
    
}

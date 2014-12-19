//
//  ChannelTunerInterfaceController.swift
//  Dionysus
//
//  Created by Bush, Ryan M on 12/3/14.
//  Copyright (c) 2014 Charter. All rights reserved.
//

import WatchKit

/**
*  WatchKit interface controller for channel tuning by number.
*/
class ChannelTunerInterfaceController: WKInterfaceController {
        /// WatchKit label for displaying the call sign of a channel, based on the current input.
        @IBOutlet var channelLabel: WKInterfaceLabel?
        /// WatchKit label for displaying the current input.
        @IBOutlet var inputLabel: WKInterfaceLabel?
        
        /// Outlet to the WatchKit button that will input 0.
        @IBOutlet var zeroButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 1.
        @IBOutlet var oneButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 2.
        @IBOutlet var twoButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 3.
        @IBOutlet var threeButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 4.
        @IBOutlet var fourButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 5.
        @IBOutlet var fiveButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 6.
        @IBOutlet var sixButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 7.
        @IBOutlet var sevenButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 8.
        @IBOutlet var eightButton: WKInterfaceButton?
        /// Outlet to the WatchKit button that will input 9.
        @IBOutlet var nineButton: WKInterfaceButton?
        
        /// Lazily loaded string that holds the current input.
        lazy var currentInput: String = String()
        
        /**
        Adds a number, that must be between 0 and 9, to the current input.
        
        :param: input The string to append to the current input
        */
        func addNumber(input: String!) {
                
                if currentInput.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) < 3 {
                        currentInput += input
                        inputLabel!.setText(currentInput)
                        
                        updateCallSign()
                }
        }
        
        /**
        Clears the current input and sets the text of the labels to default placeholders.
        */
        @IBAction func clear() {
                currentInput = String()
                inputLabel!.setText("---")
                channelLabel!.setText("")
        }
        
        /**
        Attempts to tune the currently inputted channel number to the default device.
        */
        @IBAction func sendToTv() {
                if let device = Device.defaultDevice() {
                        //NOTE: We assume this call always succeeds (cause we are moronic optimists), thus there is no implementation of completion or failure
                        WebOperations.tuneToChannel(currentInput, deviceMacAddress: device.macAddress, completion: nil, failure: nil)
                }
                //NOTE: It is technically possible to not have a default device. However, this should never happen with a valid Charter customer.
                //      Add code here to handle the user interface if we decide to handle the flow of not having a default device.
        }
        
        /**
        Updates the channelLabel with the call sign of the channel retrieved from core data, that has the same channel number that is currently inputted.
        */
        func updateCallSign() {
                if let results = DataManager.sharedInstance.fetchResults(kChannelKey, predicate: NSPredicate(format: "number = %@", currentInput)) {
                        if results.count > 0 {
                                if let channel = results[0] as? Channel {
                                        channelLabel!.setText(channel.valueForKey(kCallSign) as? String)
                                }
                        } else {
                                channelLabel!.setText("")
                        }
                }
        }
        
        //MARK: Button Presses
        /// Adds a 0 to the current input string.
        @IBAction func zeroPressed() {
                addNumber("0")
        }
        
        /// Adds a 1 to the current input string.
        @IBAction func onePressed() {
                addNumber("1")
        }
        
        /// Adds a 2 to the current input string.
        @IBAction func twoPressed() {
                addNumber("2")
        }
        
        /// Adds a 3 to the current input string.
        @IBAction func threePressed() {
                addNumber("3")
        }
        
        /// Adds a 4 to the current input string.
        @IBAction func fourPressed() {
                addNumber("4")
        }
        
        /// Adds a 5 to the current input string.
        @IBAction func fivePressed() {
                addNumber("5")
        }
        
        /// Adds a 6 to the current input string.
        @IBAction func sixPressed() {
                addNumber("6")
        }
        
        /// Adds a 7 to the current input string.
        @IBAction func sevenPressed() {
                addNumber("7")
        }
        
        /// Adds a 8 to the current input string.
        @IBAction func eightPressed() {
                addNumber("8")
        }
        
        /// Adds a 9 to the current input string.
        @IBAction func ninePressed() {
                addNumber("9")
        }
        
}

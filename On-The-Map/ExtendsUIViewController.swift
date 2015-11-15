//
//  ExtendsUIViewController.swift
//  On The Map
//
//  Created by Ryan Collins on 11/8/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftSpinner

extension UIViewController {

    
    func reloadData() {
        /* reload Parse data */
        ParseClient.sharedInstance().studentData = nil
    }
    

    /* Helper function to show alerts to user */
    func alertUserWithWithActions(title: String, message: String, actions: [UIAlertAction]) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            for action in actions {
                ac.addAction(action)
                
            }
            
            self.presentViewController(ac, animated: true, completion: nil)
            
        })
    }
    
    /* Create alert actions from alert messages and use callback function to handle any blocks */
    func alertController(withTitles titles: [String], message: String, callbackHandler: ((UIAlertAction)->Void)? ) -> UIAlertController {
        
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .ActionSheet)
        
        for title in titles.enumerate() {
            
            if let callbackHandler = callbackHandler {
                let action = UIAlertAction(title: title.element, style: .Default, handler: callbackHandler)
                alertController.addAction(action)
            } else {
                let action = UIAlertAction(title: title.element, style: .Default, handler: nil)
                alertController.addAction(action)
            }
            
            
            
        }
        
        return alertController
        
    }
    
    /* Helper function: construct an NSLocalizedError from an error string */
    func errorFromString(string: String) -> NSError? {
        
        return NSError(domain: "ParseClient", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(string)"])
        
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    /* Suscribe the view controller to the UIKeyboardWillShowNotification */
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /* Unsubscribe the view controller to the UIKeyboardWillShowNotification */
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    /* Hide keyboard when view is tapped */
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears, using notifications */
        if view.frame.origin.y == 0.0 {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    
    @IBAction func didTapLogoutUpInside(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        UdaciousClient.sharedInstance().logoutOfSession({success, error in
            if success {
                
                if FBSDKAccessToken.currentAccessToken() != nil {
                    let facebookLogin = FBSDKLoginManager()
                    facebookLogin.logOut()
                    
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                
                let logoutAction = UIAlertAction(title: "Logout", style: .Destructive) {Void in
                    
                    self.performSegueWithIdentifier("logoutSegue", sender: self)
                    return
                }
                
                self.alertUserWithWithActions("Logout?", message: "Are you sure you want to logout?", actions: [cancelAction, logoutAction])
                
            } else {
                
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                self.alertUserWithWithActions("Failed to logout", message: "Sorry, but we were unable to log you out.", actions: [action])
            }
        })
        appDelegate.userAuthenticated = false
    }
}

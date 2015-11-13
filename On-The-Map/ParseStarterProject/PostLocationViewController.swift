//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by Ryan Collins on 11/10/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

class PostLocationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var locationTextField: KaedeTextField!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
  
    @IBOutlet weak var linkTextField: KaedeTextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topViewContainer: UIView!
    
    let coordinateSpan = MKCoordinateSpan()
    let regionRadius: CLLocationDistance = 1000
    
    var isSubmittingURL = false
    var locationString: String? = nil
    var mediaURL: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkTextField.delegate = self
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureDisplay(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func didTapCancelButtonTouchUpInside(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {
            /* ToDo refresh view */
        })
    }
    
    /* If user is submitting a valid location, show on the map */
    @IBAction func userDidTapSubmitLocationUpInside(sender: AnyObject) {
        if isSubmittingURL == false {
            
            
            guard locationTextField.text != nil else {
    
                return
                
            }
            
            verifyLocation(locationTextField.text!)
            
        } else {
            
            if let mediaURL = linkTextField.text {
                guard let _ = NSURL(string: mediaURL) else {
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alertUserWithWithActions("Not a valid URL", message: "Sorry, but the url you provided is not valid.  Please share a new link.", actions: [okAction])
                    return
                    
                }
            
                ParseClient.sharedInstance().queryParseDataForObjectId({success, objectId, error in
                    
                    if error != nil {
                        
                        print(error)
                        
                    } else {
                        
                        let JSONBody = ParseClient.sharedInstance().makeDictionaryForPostLocation(mediaURL, mapString: self.locationString!)
                        
                        ParseClient.sharedInstance().updateLocationForObjectId(objectId!, JSONBody: JSONBody, completionHandler: {success, error in
                            
                            if error != nil {
                                
                                let newAction = UIAlertAction(title: "Post as New", style: .Default, handler: {Void in
                                    
                                    self.postNewLocationToParse(self.mediaURL!, locationString: self.locationString!)
                                
                                })
                                
                                let dismissAction = UIAlertAction(title: "Leave", style: .Destructive, handler: {Void in
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                })
                                
                                self.alertUserWithWithActions("Something went wrong", message: "An error occured while updating your location.  Submit as new or get out of here?", actions: [newAction, dismissAction])
                                
                            } else {
                                
                                /* refresh and present mapViewController */
                                self.dismissViewControllerAnimated(true, completion: nil)
                                
                            }
                            
                        })
                        
                    }
                    
                })
                
            } else {
                
                let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alertUserWithWithActions("Something's missing", message: "Please enter a valid string when submitting the URL", actions: [okAction])
                
            }
            
        }
    }
    
    func postNewLocationToParse(mediaURL: String, locationString: String) {
        
        let parameters = ParseClient.sharedInstance().makeDictionaryForPostLocation(mediaURL, mapString: locationString)
        
        ParseClient.sharedInstance().postDataToParse(parameters, completionHandler: {success, error in
            
            if error != nil {
                
                let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: nil)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: {Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                self.alertUserWithWithActions("Something went wrong", message: "An error occured while submitting your location, please retry or cancel submission.", actions: [retryAction, cancelAction])
                
            } else {
                
                /* refresh and present mapViewController */
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }
            
        })
        
        
    }
    
    func verifyLocation(location: String) {
        let geocoder = CLGeocoder()
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {

            geocoder.geocodeAddressString(location, completionHandler: { placemarks, error in
                
                if placemarks != nil {
                    
                    self.locationString = location
                    
                    let placemark = placemarks![0]
                    
                    self.isSubmittingURL = true
                    self.configureDisplay(false)
                    
                    UdaciousClient.sharedInstance().latitude = CLLocationDegrees(placemark.location!.coordinate.latitude)
                    UdaciousClient.sharedInstance().longitude = CLLocationDegrees(placemark.location!.coordinate.longitude)
                    
                    
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                    
                    
                   let coordinateRegion = MKCoordinateRegionMakeWithDistance(placemark.location!.coordinate, self.regionRadius * 2.0, self.regionRadius * 2.0)
                    
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    
                    self.mapView.addAnnotation(annotation)
                    
                } else {
                    
                let tryAgain = UIAlertAction(title: "Try again", style: .Default, handler: nil)
                
                self.alertUserWithWithActions("Could not verify location", message: "Sorry, but we could not verify your location. Please try again", actions: [tryAgain])
                
                }
                
            })
        
        dispatch_async(dispatch_get_main_queue(), {
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        })
        })
        
    }
    
    /* configure display for reset */
    func configureDisplay(reset: Bool) {
        
        
        mapView.hidden = reset
        linkTextField.hidden = reset
        linkTextField.hidden = reset
        
        locationTextField.hidden = !reset
        headerLabel.hidden = !reset
        helpLabel.hidden = !reset
        
        if !reset {
            topViewContainer.backgroundColor = UIColor.flatBlueColor()
        }
    }
    
}

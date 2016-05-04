//
//  AddGeotificationViewController.swift
//  Geotify
//
//  Created by Ken Toh on 24/1/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit

protocol AddGeotificationsViewControllerDelegate {
  func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,
    radius: Double, identifier: String, note: String, eventType: EventType)
}

class AddGeotificationViewController: UITableViewController {

  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var zoomButton: UIBarButtonItem!

  @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var radiusTextField: UITextField!
  @IBOutlet weak var noteTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var textFieldLocation: UITextField!
  var delegate: AddGeotificationsViewControllerDelegate!

    @IBAction func searchPlaces(sender: AnyObject) {
        print("Entering text field return")
        let address = textFieldLocation.text;
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address! ,  completionHandler: {
            (placemarks: [CLPlacemark]?, error:NSError?) -> Void in
            if(error != nil){
                let alert = UIAlertController(title: "Location Not Found!", message: "Please enter another address ", preferredStyle: UIAlertControllerStyle.Alert);
                let OKAction = UIAlertAction(title:  "OK" , style: .Default) { (action : UIAlertAction!) in
                }
                alert.addAction(OKAction)
                self.presentViewController(alert, animated: true,completion: nil);
                
            }else if let placemark = placemarks?[0]{
                self.annotateMap(placemark.location!.coordinate);
                
            }
            self.textFieldLocation.resignFirstResponder()

        })
        //return true;
    }
    
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.rightBarButtonItems = [addButton, zoomButton]
    addButton.enabled = false

    tableView.tableFooterView = UIView()
  }
    
    func annotateMap(newCoordinate : CLLocationCoordinate2D){
        let latDelta : CLLocationDegrees = 0.01
        let longDelta : CLLocationDegrees = 0.01
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let myLocation:CLLocationCoordinate2D = newCoordinate
        let theRegion:MKCoordinateRegion =
            MKCoordinateRegionMake(myLocation,theSpan)
        self.mapView.setRegion(theRegion, animated: true)
        self.mapView.mapType = MKMapType.Standard
        let myHomePin = MKPointAnnotation()
        myHomePin.coordinate = newCoordinate
        myHomePin.title = textFieldLocation.text
        self.mapView.addAnnotation(myHomePin)
    }

  @IBAction func textFieldEditingChanged(sender: UITextField) {
    addButton.enabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
  }

  @IBAction func onCancel(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction private func onAdd(sender: AnyObject) {
    let coordinate = mapView.centerCoordinate
    let radius = (radiusTextField.text! as NSString).doubleValue
    let identifier = NSUUID().UUIDString
    let note = noteTextField.text
    let eventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? EventType.OnEntry : EventType.OnExit
    delegate!.addGeotificationViewController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)
  }

  @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
    zoomToUserLocationInMapView(mapView)
  }
}

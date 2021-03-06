//
//  MapViewController.swift
//  Tertius
//
//  Created by Ryan Li on 9/19/15.
//  Copyright © 2015 Ryan Li. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    let locationManager = CLLocationManager()
    let overlayTransitionDelegate = OverlayTransitioningDelegate()
    var timer : NSTimer?

    @IBOutlet weak var mapView: GMSMapView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Treazure"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTreazure")
        locationManager.distanceFilter = 1;
        locationManager.delegate = self;
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "refresh", userInfo: nil, repeats: true)
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }
    // Mark: - Add Treazure
    func addTreazure() {
        performSegueWithIdentifier("PopAddTreazure", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PopAddTreazure" {
            let toViewController = segue.destinationViewController as UIViewController
            toViewController.transitioningDelegate = overlayTransitionDelegate
            toViewController.modalPresentationStyle = .Custom
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    func refresh() {
        mapView.clear()
        UserManager.sharedInstance.getMessagesOwnedByCurrentUser { messages, error in
            if let error = error {
                NSLog("Error %@", error.localizedDescription)
                return
            }
            NSLog("Message: %@", messages!)
            for message in messages! {
                let marker = PlaceMarker(message: message, placeType: .LeftAt)
                marker.map = self.mapView
            }
        }

        UserManager.sharedInstance.getMessagesFoundByCurrentUser { messages, error in
            if let error = error {
                NSLog("Error %@", error.localizedDescription)
                return
            }
            NSLog("Message: %@", messages!)
            for message in messages! {
                let marker = PlaceMarker(message: message, placeType: .PickedUpFrom)
                marker.map = self.mapView
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        struct ConstVar {
            static var firstShown = true
        }
        if let location = locations.first as CLLocation? {

            if ConstVar.firstShown {
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
                ConstVar.firstShown = false
            }
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                appDelegate.currentLocation = location
            }
            User.currentUser()!.currentLocation = PFGeoPoint(location: location)
            User.currentUser()!.saveInBackground()
            manager.stopUpdatingLocation()
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: manager, selector: "startUpdatingLocation", userInfo: nil, repeats: false)
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {

    }
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return false
    }
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        let placeMarker = marker as! PlaceMarker
        if let infoView = MarkerInfoView.instanceFromNib() {
            infoView.nameLabel.text = placeMarker.address
            infoView.placePhoto.image = UIImage(named: "Treasure")
            return infoView
        } else {
            return nil
        }
    }

    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
}
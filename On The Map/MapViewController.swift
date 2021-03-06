//
//  MapViewController.swift
//  On The Map
//
//  Created by Vinicius Carvalho on 12/09/2016.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIApplicationDelegate, CLLocationManagerDelegate {

    var appDelegate: AppDelegate!
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 2000
    var annotations: [MKAnnotation] = []

    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.hideKeyboardWhenTappedAround()
        getMapLocations()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.65, longitudeDelta: 0.65))
        
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {

        print("error:: \(error)")
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blueColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {

                if verifyUrl(toOpen) == false {

                    let failAlertGeneral = UIAlertController(title: "Yikes", message: "The url you're trying to open is invalid", preferredStyle: UIAlertControllerStyle.Alert)
                    failAlertGeneral.addAction(UIAlertAction(title: "Try Another", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(failAlertGeneral, animated: true, completion: nil)
                } else {

                    app.openURL(NSURL(string: toOpen)!)
                }
            }
        }
    }

    func getMapLocations() {

        if StudentModel.sharedInstance().studentLocation.isEmpty == true {

            refresh()
        } else if StudentModel.sharedInstance().studentLocation.isEmpty == false {

            self.annotations = []

            performUIUpdatesOnMain {

                for student in StudentModel.sharedInstance().studentLocation {

                    let lat = student.latitude
                    let long = student.longitude
                    let mediaURL = student.mediaURL
                    let annotation = MKPointAnnotation()
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

                    annotation.coordinate = coordinate
                    annotation.title = student.firstName + " " + student.lastName
                    annotation.subtitle = mediaURL
                    self.annotations.append(annotation)

                }
                self.mapView.addAnnotations(self.annotations)
            }
        }
    }

    func refresh() {

        if Reachability.isConnectedToNetwork() == false {

            failAlertGeneral("No Internet Connection", message: "Please check your connection", actionTitle: "OK")
        } else if Reachability.isConnectedToNetwork() == true {

            self.mapView.removeAnnotations(self.annotations)

            self.annotations = []

            Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in

                if errorString != nil {

                    performUIUpdatesOnMain {
                        
                         self.failAlertGeneral("Attention", message: "There was a problem with retrieving Student Location data", actionTitle: "OK")
                        
                    }
                } else {

                    if let studentLocation = studentLocation {

                        performUIUpdatesOnMain {

                            for student in studentLocation {

                                let lat = student.latitude
                                let long = student.longitude
                                let mediaURL = student.mediaURL
                                let annotation = MKPointAnnotation()
                                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

                                annotation.coordinate = coordinate
                                annotation.title = student.firstName + " " + student.lastName
                                annotation.subtitle = mediaURL
                                self.annotations.append(annotation)
                                
                            }
                            self.mapView.addAnnotations(self.annotations)
                        }
                    }
                }
            }
        }
    }

    @IBAction func buttonMethod(sender: AnyObject) {

        self.mapView.removeAnnotations(annotations)
        refresh()
    }

    func logOut() {

        Client.sharedInstance().deleteSession() { (result, error) in

            if error != nil {

                self.failAlertGeneral("LogOut Unsuccessful", message: "Something went wrong, please try again", actionTitle: "OK")
                
            } else {

                performUIUpdatesOnMain {

                    print("logout success \(result)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            }
        }
    }

    @IBAction func logOutButton(sender: AnyObject) {

        failLogOutAlert()
    }

    func failAlertGeneral(title: String, message: String, actionTitle: String) {

        let failAlertGeneral = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        failAlertGeneral.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failAlertGeneral, animated: true, completion: nil)
    }

    func failLogOutAlert() {

        let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: UIAlertControllerStyle.Alert)
        failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: UIAlertActionStyle.Default, handler: { alertAction in self.logOut() }))
        failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failLogoutAlert, animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    func verifyUrl(urlString: String?) -> Bool {

        if let urlString = urlString {

            if NSURL(string: urlString) != nil {

                return true
            }
        }
        return false
    }
}


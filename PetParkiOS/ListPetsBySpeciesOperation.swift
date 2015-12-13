//
//  ListPetsBySpeciesOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/13/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = "\(APILink)/api/pets"

protocol ListPetsBySpeciesDelegate: class {
    func didListPetsBySpecies(pets: [Pet])
}

class ListPetsBySpeciesOperation: URLSessionDataTaskOperation<PetParkList<Pet>>
{
    weak var delegate: ListPetsBySpeciesDelegate?
    
    init(speciesID: String) {
        let url = NSURL(string: "\(URL)/\(speciesID)/byspecies")!
        let urlRequest = URLRequest(url: url, method: "GET")
        
        super.init(request: urlRequest.request)
        
        name = "List Pets By Species Operation"
        
        self.onSuccess = { pets in
            self.delegate?.didListPetsBySpecies(pets.list)
        }
    }
}





////
////  ViewController.swift
////  Trax
////
////  Created by Gavril Tonev on 6/1/15.
////  Copyright (c) 2015 eDynamix. All rights reserved.
////
//
//import UIKit
//import MapKit
//import CoreLocation
//
//class GPXViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate{
//    
//    // MARK: Outlets and Variables
//    
//    @IBOutlet weak var mapView: MKMapView!{
//        didSet{
//            mapView.mapType = .Hybrid
//            mapView.delegate = self
//        }
//    }
//    
//    @IBAction func toBahamas(sender: UIButton) {
//        clearWaypoints()
//        appendSomeWaypoints()
//        handleWaypoints(waypoints)
//        
//        let location = waypoints.first!.coordinate
//        moveToLocation(location)
//    }
//    
//    @IBAction func addPoint(sender: UILongPressGestureRecognizer) {
//        if sender.state == UIGestureRecognizerState.Began{
//            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
//            let wp = EditableWaypoint(lattitude: coordinate.latitude, longitude: coordinate.longitude)
//            wp.name = "Dropped"
//            waypoints.append(wp)
//            handleWaypoints(waypoints)
//        }
//    }
//    
//    @IBAction func zoomToMyLocation(sender: UIButton) {
//        moveToLocation(mapView.userLocation.coordinate)
//    }
//    
//    var waypoints = [Waypoint]()
//    
//    var locationManager = CLLocationManager()
//    
//    var popoverHeight: CGFloat  = 90.0 + 100
//    
//    // MARK: Helper Functions
//    
//    func moveToLocation(location: CLLocationCoordinate2D, spanX: Double = 0.1, spanY: Double = 0.1, animated: Bool = true)
//    {
//        let span = MKCoordinateSpanMake(spanX,spanY)
//        let region = MKCoordinateRegion(center: location, span: span)
//        mapView.setRegion(region, animated: animated)
//    }
//    
//    func clearWaypoints(){
//        if mapView?.annotations != nil {
//            mapView.removeAnnotations(mapView.annotations as! [MKAnnotation])
//        }
//    }
//    
//    func handleWaypoints(wps: [Waypoint]){
//        mapView.addAnnotations(wps)
//        mapView.showAnnotations(wps, animated: true)
//    }
//    
//    func appendSomeWaypoints(){
//        var wp = Waypoint(lattitude: 25.074136, longitude: -77.391872)
//        wp.name = "Scuba Dive"
//        wp.info = "Found some sea turtles!"
//        wp.imageLarge = "http://www.thebahamasweekly.com/uploads/2/turtle.jpg"
//        wp.imageThumb = wp.imageLarge
//        waypoints.append(wp)
//        wp = Waypoint(lattitude: 25.071045, longitude: -77.392430)
//        wp.name = "Cool Hotel"
//        wp.info = "Best trip ever"
//        wp.imageLarge = "http://www.viajandoemfamilia.com.br/wp-content/uploads/2015/02/nassau.jpg"
//        wp.imageThumb = wp.imageLarge
//        waypoints.append(wp)
//        wp = Waypoint(lattitude: 25.071910, longitude: -77.393513)
//        wp.name = "The beaches"
//        wp.info = "Relax at the Bahamas"
//        wp.imageLarge = "http://bahamasresorts.us/photo/cheap-nassau-bahamas-rentals-3.jpg"
//        wp.imageThumb = wp.imageLarge
//        waypoints.append(wp)
//        wp = Waypoint(lattitude: 25.074462, longitude: -77.397845)
//        wp.name = "Sunset"
//        wp.info = "Take a walk"
//        wp.imageLarge = "https://c1.staticflickr.com/1/1/1186521_6e8a8053ce.jpg"
//        wp.imageThumb = wp.imageLarge
//        waypoints.append(wp)
//    }
//    
//    // MARK: Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        //--For the current location
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        mapView.showsUserLocation = true
//        //--For the current location
//        
//        let startingLocation = CLLocationCoordinate2D(latitude: 25, longitude: -77)
//        moveToLocation(startingLocation, spanX: 150, spanY: 150)
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        locationManager.stopUpdatingLocation()
//    }
//    
//    // MARK: Map Annotations
//    
//    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        //To prevent the user location to appear as a pin
//        if annotation.isKindOfClass(MKUserLocation){
//            return nil
//        }
//        
//        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("waypoint")
//        if view == nil{
//            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "waypoint")
//            view!.canShowCallout = true
//        } else {
//            view.annotation = annotation
//        }
//        
//        view.draggable = annotation is EditableWaypoint
//        view.leftCalloutAccessoryView = nil
//        view.rightCalloutAccessoryView = nil
//        if let waypoint = annotation as? Waypoint{
//            if waypoint.thumbnailURL != nil{
//                view.leftCalloutAccessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 59, height: 59))
//            }
//            if annotation is EditableWaypoint{
//                view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
//            }
//        }
//        return view
//    }
//    
//    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
//        mapView.deselectAnnotation(view.annotation, animated: false)
//        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure{
//            performSegueWithIdentifier("Edit Waypoint", sender: view)
//        } else if let waypoint = view.annotation as? Waypoint{
//            if waypoint.imageURL != nil{
//                performSegueWithIdentifier("Show Image", sender: view)
//            }
//        }
//    }
//    
//    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
//        if let waypoint = view.annotation as? Waypoint{
//            if waypoint.imageThumb != nil && view.leftCalloutAccessoryView == nil{
//                view.leftCalloutAccessoryView = UIButton(frame: CGRect(x:0,y:0,width: 59, height:59))
//            }
//            if let thumbnailButtonView = view.leftCalloutAccessoryView as? UIButton{
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value),0)) { () -> Void in
//                    if let imageData = NSData(contentsOfURL: waypoint.thumbnailURL!){  //Doesn't block main thread
//                        dispatch_async(dispatch_get_main_queue()){
//                            if let image = UIImage(data: imageData){
//                                thumbnailButtonView.setImage(image, forState: .Normal)
//                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    // MARK: Segues
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "Show Image" {
//            if let waypoint = (sender as? MKAnnotationView)?.annotation as? Waypoint {
//                if let wivc = segue.destinationViewController.contentViewController as? WaypointImageViewController{
//                    wivc.waypoint = waypoint
//                }
//                if let ivc = segue.destinationViewController.contentViewController as? ImageViewController{
//                    ivc.imageURL = waypoint.imageURL
//                    ivc.title = waypoint.name
//                }
//            }
//        } else if segue.identifier == "Edit Waypoint"{
//            if let waypoint = (sender as? MKAnnotationView)?.annotation as? EditableWaypoint{
//                if let editvc = segue.destinationViewController.contentViewController as? EditWaypointVC{
//                    if let ppc = editvc.popoverPresentationController{
//                        let coordinatePoint = mapView.convertCoordinate(waypoint.coordinate, toPointToView: mapView)
//                        ppc.sourceRect = (sender as! MKAnnotationView).popoverSourceRectForCoordinatePoint(coordinatePoint)
//                        //let minimumHeight = editvc.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
//                        editvc.preferredContentSize = CGSize(width: CGFloat(320), height: popoverHeight)
//                        ppc.delegate = self
//                    }
//                    editvc.waypointToEdit = waypoint
//                }
//            }
//        }
//    }
//    
//    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
//        return UIModalPresentationStyle.OverFullScreen
//    }
//    
//    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
//        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
//        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
//        visualEffectView.frame = navcon.view.bounds
//        navcon.view.insertSubview(visualEffectView, atIndex: 0)
//        return navcon
//    }
//}
//
//extension UIViewController{
//    var contentViewController: UIViewController{
//        if let navcon = self as? UINavigationController {
//            return navcon.visibleViewController
//        } else {
//            return self
//        }
//    }
//}
//
//extension MKAnnotationView{
//    func popoverSourceRectForCoordinatePoint(coordinatePoint: CGPoint) -> CGRect{
//        var popoverSourceRectCenter = coordinatePoint
//        popoverSourceRectCenter.x -= frame.width / 2 - centerOffset.x - calloutOffset.x
//        popoverSourceRectCenter.y -= frame.height / 2 - centerOffset.y - calloutOffset.y
//        return CGRect(origin: popoverSourceRectCenter, size: frame.size)
//    }
//}











//
//  MapViewController.swift
//  SidebarMenu
//
//  Created by Gavril Tonev on 12/11/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Hybrid
            mapView.delegate = self
        }
    }
    
    private var operationQueue = OperationQueue()
    
    private var locationManager = CLLocationManager()
    private var userFound: Bool = false
    private var pets = [Pet]() {
        didSet {
            if pets.count > 0 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.clearWaypoints()
                    self.handleWaypoints(self.pets)
                }
            }
        }
    }
    
    @IBAction func myLocationtapped(sender: UIButton) {
        moveToLocation(mapView.userLocation.coordinate)
    }
    
    @IBAction func searchBarButtonTapped(sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: "Search For Pet Species", preferredStyle: .ActionSheet)
        optionMenu.addAction(UIAlertAction(title: "All Pets!", style: UIAlertActionStyle.Default) { alert in
            self.getPetsBySpecies("ALL")
            })
        for petSpecies in SPECIES{
            optionMenu.addAction(UIAlertAction(title: petSpecies, style: UIAlertActionStyle.Default) { alert in
                self.getPetsBySpecies(petSpecies)
                })
        }
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func getPetsBySpecies(species: String) {
        if species == "ALL" {
            getPets()
            return
        }

        let listPetsBySpeciesOperation = ListPetsBySpeciesOperation(speciesID: species)
        listPetsBySpeciesOperation.delegate = self
        operationQueue.addOperation(listPetsBySpeciesOperation)
    }
    
    func getPets() {
        let listPetsOperation = ListPetsOperation()
        listPetsOperation.delegate = self
        operationQueue.addOperation(listPetsOperation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pet = sender as? Pet where segue.identifier == "showPetDetailsFromMap" {
            let petDetailsViewController = segue.destinationViewController as! PetDetailsViewController
            petDetailsViewController.pet = pet
            petDetailsViewController.isForeignUser = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getPets()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
}

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) { return nil }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("waypoint")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "waypoint")
            view!.canShowCallout = true
        } else { view?.annotation = annotation }
        
        view!.draggable = false
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = nil
        if let pet = annotation as? Pet{
            if pet.profilePicURL != nil{
                view!.leftCalloutAccessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 59, height: 59))
            }
//            if annotation is EditableWaypoint{
//                view!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
//            }
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        if let pet = view.annotation as? Pet {
            performSegueWithIdentifier("showPetDetailsFromMap", sender: pet)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let pet = view.annotation as? Pet{
            if pet.profilePicURL != nil && view.leftCalloutAccessoryView == nil{
                view.leftCalloutAccessoryView = UIButton(frame: CGRect(x:0,y:0,width: 59, height:59))
            }
            if let thumbnailButtonView = view.leftCalloutAccessoryView as? UIButton, profilePicURL = pet.profilePicURL {
                if let profilePic = pet.profilePic {
                    thumbnailButtonView.setImage(profilePic, forState: .Normal)
                    return
                }
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue),0)) {
                    if let imageData = NSData(contentsOfURL: NSURL(string: profilePicURL)!){  //Doesn't block main thread // woah much excitement
                        dispatch_async(dispatch_get_main_queue()){
                            if let image = UIImage(data: imageData){
                                thumbnailButtonView.setImage(image, forState: .Normal)
                                pet.profilePic = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !userFound { moveToLocation(mapView.userLocation.coordinate); userFound = true }
    }
    
    func moveToLocation(location: CLLocationCoordinate2D, spanX: Double = 0.01, spanY: Double = 0.01, animated: Bool = true)
    {
        let span = MKCoordinateSpanMake(spanX,spanY)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: animated)
    }
    
    func clearWaypoints(){
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations as [MKAnnotation])
        }
    }
    
    func handleWaypoints(wps: [MKAnnotation]){
        mapView.addAnnotations(wps)
        mapView.showAnnotations(wps, animated: true)
    }
}

extension MapViewController: ListPetsDelegate {
    func didListPets(pets: [Pet]) {
        self.pets = pets
    }
}

extension MapViewController: ListPetsBySpeciesDelegate {
    func didListPetsBySpecies(pets: [Pet]) {
        self.pets = pets
    }
}

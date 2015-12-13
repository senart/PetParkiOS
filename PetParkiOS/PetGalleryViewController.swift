//
//  PetGalleryViewController.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

class PetGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    private let operationQueue = OperationQueue()
    
    private var pets = [Pet]() { didSet { dispatch_async(dispatch_get_main_queue()) { self.collectionView.reloadData() } } }
    private var selectedPet: Pet!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PetGalleryCollectionViewCell
        
        cell.pet = pets[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedPet = pets[indexPath.row]
        performSegueWithIdentifier("showPetDetailsViewController", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPetDetailsViewController" {
            let petDetailsViewController = segue.destinationViewController as! PetDetailsViewController
            petDetailsViewController.pet = selectedPet
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.delegate = self
        let listPetsOperation = ListPetsOperation()
        listPetsOperation.delegate = self
        operationQueue.addOperation(listPetsOperation)
    }
}

extension PetGalleryViewController: ListPetsDelegate {
    func didListPets(pets: [Pet]) {
        self.pets = pets
    }
}

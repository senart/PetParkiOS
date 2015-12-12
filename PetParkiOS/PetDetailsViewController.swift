//
//  PetDetailsViewController.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

class PetDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var petProfilePicImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petBreedLabel: UILabel!
    @IBOutlet weak var petSpeciesLabel: UILabel!
    @IBOutlet weak var petAgeLabel: UILabel!
    @IBOutlet weak var petGenderLabel: UILabel!
    @IBOutlet weak var petWeightLabel: UILabel!
    
    private let operationQueue = OperationQueue()
    
    private var petImages = [PetImage]() { didSet { dispatch_async(dispatch_get_main_queue()) { self.collectionView.reloadData() } } }
    var pet: Pet!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PetDetailsCollectionViewCell
        
        cell.petImage = petImages[indexPath.row]
        
        return cell
    }
    
    func setupUI() {
        if let petProfilePic = pet.profilePic { petProfilePicImageView.image = petProfilePic }
        petProfilePicImageView.layer.cornerRadius = CGFloat(6)
        petProfilePicImageView.layer.masksToBounds = true
        
        petNameLabel.text = pet.name
        petBreedLabel.text = pet.breed
        petSpeciesLabel.text = pet.species
        petAgeLabel.text = "\(pet.age)"
        petGenderLabel.text = pet.gender
        petWeightLabel.text = "\(pet.weight)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.delegate = self
        let listPetImagesOperation = ListPetImagesOperation(id: pet.id)
        listPetImagesOperation.delegate = self
        operationQueue.addOperation(listPetImagesOperation)
    }
}

extension PetDetailsViewController: ListPetImagesDelegate {
    func didListPetImages(petImages: [PetImage]) {
        self.petImages = petImages
    }
}
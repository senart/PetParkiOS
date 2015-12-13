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
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
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
    var isForeignUser: Bool!
    private var foreignUser: Bool = true {
        didSet {
            cameraBarButton.enabled = !foreignUser
            cameraBarButton.tintColor = foreignUser ? UIColor.clearColor() : UIColor.blueColor()
        }
    }
    
    @IBAction func cameraBarButtonTapped(sender: UIBarButtonItem) {
        startCamera()
    }
    
    func startCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PetDetailsCollectionViewCell
        
        cell.petImage = petImages[indexPath.row]
        
        return cell
    }
    
    private func fetchPetImages() {
        let listPetImagesOperation = ListPetImagesOperation(id: pet.id)
        listPetImagesOperation.delegate = self
        operationQueue.addOperation(listPetImagesOperation)
    }
    
    func setupUI() {
        if let petProfilePic = pet.profilePic { petProfilePicImageView.image = petProfilePic }
        else if !foreignUser {
            petProfilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "startCamera"))
        }
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
        foreignUser = isForeignUser
        collectionView.delegate = self
        setupUI()
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(lpgr)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchPetImages()
    }
}

extension PetDetailsViewController: UIGestureRecognizerDelegate {
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        let p = gestureRecognizer.locationInView(self.collectionView)
        if let indexPath: NSIndexPath = self.collectionView?.indexPathForItemAtPoint(p) {
            let selectedPetImage = petImages[indexPath.row]
            
            let alert = UIAlertController(
                title: "\(pet.name) Profile Picture",
                message: "Set this as a profile picture?",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { action in
                let attatchPetProfilePictureOperation = AttatchPetProfilePictureOperation(id: self.pet.id, petImageID: selectedPetImage.id)
                self.operationQueue.addOperation(attatchPetProfilePictureOperation)
                self.petProfilePicImageView.image = selectedPetImage.image
                })
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension PetDetailsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let tempPetImage = PetImage(id: -1, petID: -1, imageURL: "")
            tempPetImage.image = image
            petImages.append(tempPetImage)
            if let imageData =  UIImageJPEGRepresentation(image, 0.3) {
                let uploadPicturesOperation = UploadPictureOperation(id: pet.id, jpgImageData: imageData)
                uploadPicturesOperation.delegate = self
                operationQueue.addOperation(uploadPicturesOperation)
            }else { print("Image resize failed") }
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PetDetailsViewController: UploadPictureDelegate {
    func didUploadImage(uploadedPetImage: PetImage) {
        dispatch_async(dispatch_get_main_queue()) {
            self.fetchPetImages()
        }
    }
}

extension PetDetailsViewController: ListPetImagesDelegate {
    func didListPetImages(petImages: [PetImage]) {
        self.petImages = petImages
    }
}
//
//  PetGalleryCollectionViewCell.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

class PetGalleryCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var pet: Pet? { didSet { updateUI() } }
    
    func updateUI() {
        guard let pet = pet else { return }
        
        if let profilePic = pet.profilePic { imageView.image = profilePic }
        else if let profilePicURL = pet.profilePicURL {
            activityIndicator.startAnimating()
            imageView.image = nil
            imageView.downloadedFrom(link: profilePicURL, contentMode: .ScaleAspectFill) { image in
                self.activityIndicator.stopAnimating()
                self.pet?.profilePic = image
            }
        }
    }
    
    private func config() {
        imageView.image = UIImage(named: "camera")
        imageView.layer.cornerRadius = CGFloat(6)
        imageView.layer.masksToBounds = true
        
        self.addSubview(activityIndicator)
        activityIndicator.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        config()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        config()
    }
}
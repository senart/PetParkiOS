//
//  MyPetsTableViewCell.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

class MyPetsTableViewCell: UITableViewCell
{
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petSpeciesLabel: UILabel!
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var pet: Pet? { didSet{ updateUI() } }
    
    func updateUI() {
        guard let pet = pet else { return }
        
        if let profilePic = pet.profilePic { profilePicImageView.image = profilePic }
        else if let profilePicURL = pet.profilePicURL {
            activityIndicator.startAnimating()
            profilePicImageView.image = nil
            profilePicImageView.downloadedFrom(link: profilePicURL, contentMode: .ScaleAspectFill) { image in
                self.activityIndicator.stopAnimating()
                self.pet?.profilePic = image
            }
        }
        petNameLabel.text = pet.name
        petSpeciesLabel.text = pet.species
    }
    
    private func config() {
        profilePicImageView.image = UIImage(named: "camera")
        profilePicImageView.layer.cornerRadius = CGFloat(6)
        profilePicImageView.layer.masksToBounds = true
        
        self.addSubview(activityIndicator)
        activityIndicator.center = CGPointMake(
            profilePicImageView.frame.size.width/2,
            profilePicImageView.frame.size.height/2
        )
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
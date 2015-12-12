//
//  PetDetailsCollectionViewCell.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

class PetDetailsCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var petImage: PetImage? { didSet{ updateUI() } }
    
    func updateUI() {
        guard let petImage = petImage else { return }
        
        if let image = petImage.image { imageView.image = image }
        else {
            activityIndicator.startAnimating()
            imageView.image = nil
            imageView.downloadedFrom(link: petImage.imageURL, contentMode: .ScaleAspectFill) { image in
                self.activityIndicator.stopAnimating()
                self.petImage?.image = image
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

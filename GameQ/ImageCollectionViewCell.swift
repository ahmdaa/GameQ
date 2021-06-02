//
//  ImageCollectionViewCell.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 12/3/20.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var gameImage: UIImageView!
    
    var downloadTask: URLSessionDownloadTask?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    func setImage(for details: GameDetails){
        if let smallURL = URL(string: details.background_image!) {
            downloadTask = gameImage.loadImage(url: smallURL)
        }
    }
}

/* extension UIImageView {
    func makeRoundCorners() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
} */

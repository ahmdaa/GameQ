//
//  OverviewCollectionViewCell.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 12/10/20.
//

import UIKit

class OverviewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var esrbImage: UIImageView!
    @IBOutlet weak var metascoreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var playtimeLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var metacriticImage: UIImageView!
    weak var viewController: UIViewController?
    var websiteURL: String?
    var metacriticURL: String?
    
    @IBAction func tappedWebsite(_ sender: Any) {
        if(websiteURL != nil && websiteURL != ""){
            if let url = URL(string: websiteURL!) {
                UIApplication.shared.open(url)
            }
        } else {
            let alert = makeAlert(title: "Not Available", message: "", actionTitle: "Close")
            viewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedReviews(_ sender: Any) {
        if(metacriticURL != nil && metacriticURL != ""){
            if let url = URL(string: metacriticURL!) {
                UIApplication.shared.open(url)
            } 
        } else {
            let alert = makeAlert(title: "Not Available", message: "", actionTitle: "Close")
            viewController?.present(alert, animated: true, completion: nil)
        }
    }
}

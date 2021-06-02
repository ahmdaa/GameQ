//
//  MoreCollectionViewCell.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 12/11/20.
//

import UIKit

class MoreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var platformsLabel: UILabel!
    @IBOutlet weak var storesLabel: UILabel!
    @IBOutlet weak var redditTitleLabel: UILabel!
    weak var viewController: UIViewController?
    var redditURL: String?
    var steamURL: String?
    var gameName: String = ""
    var twitchURL = "https://www.twitch.tv/directory/game/"
    
    @IBAction func tappedReddit(_ sender: Any) {
        if(redditURL != nil && redditURL != ""){
            if let url = URL(string: redditURL!) {
                UIApplication.shared.open(url)
            }
        } else {
            let alertController = UIAlertController(title: "Not available", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedSteam(_ sender: Any) {
        if(steamURL != nil && steamURL != ""){
            if let url = URL(string: steamURL!) {
                UIApplication.shared.open(url)
            }
        } else {
            let alertController = UIAlertController(title: "Not available", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedTwitch(_ sender: Any) {
        gameName = gameName.replacingOccurrences(of: " ", with: "%20")
        let urlString = twitchURL + gameName
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

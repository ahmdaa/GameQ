//
//  GameTableViewCell.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 12/12/20.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    var downloadTask: URLSessionDownloadTask?
    
    func setImage(for game: Game){
        if let imgURL = URL(string: game.image!) {
            downloadTask = gameImage.loadImage(url: imgURL)
        }
    }
}

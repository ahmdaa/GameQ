//
//  Functions.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 12/13/20.
//

import Foundation
import UIKit

func makeAlert(title: String, message: String, actionTitle: String) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
    alertController.addAction(action)
    alertController.view.layoutIfNeeded() // Avoid snapshotting
    return alertController
}

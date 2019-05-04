//
//  PostingsTableViewCell.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/26/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import UIKit
import CoreLocation

class PostingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var programLabel: UILabel!
    
    var currentLocation: CLLocation!
    var posting: Posting!
    
    func configureCell(posting: Posting) {
        nameLabel.text = posting.name
        programLabel.text = posting.programtext
    }
    
}

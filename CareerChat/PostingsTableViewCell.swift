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
  
    
    var currentLocation: CLLocation!
    var posting: Posting!
    
    func configureCell(posting: Posting) {
        nameLabel.text = posting.name
        
        //calculate distance here
//        guard let currentLocation = currentLocation else {
//            return
//        }
//        let distanceInMeters = currentLocation.distance(from: posting.location)
//        let distanceString = "Distance: \( (distanceInMeters * 0.00062137).roundTo(places: 2)) miles"
//        distanceLabel.text  = distanceString
    }
    
}

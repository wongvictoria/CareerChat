//
//  PostingReviewsTableViewCell.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/28/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import UIKit

class PostingReviewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
    
    var review: Review! {
        didSet{
            reviewTitleLabel.text = review.title
            reviewTextLabel.text = review.text
            
        }
    }
}


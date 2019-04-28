//
//  Reviews.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/27/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray: [Review] = []
    var db: Firestore!
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(posting: Posting, completed: @escaping() -> ()) {
        guard posting.documentID != "" else {
            return
        }
        db.collection("postings").document(posting.documentID).collection("reviews").addSnapshotListener{ (querySnapshot, error) in
            guard error == nil else {
                print ("*** ERROR: adding the snapshot listener\(error!.localizedDescription)")
                return completed()
            }
            self.reviewArray = []
            for document in querySnapshot!.documents {
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewArray.append(review)
            }
            completed()
        }
    }
}


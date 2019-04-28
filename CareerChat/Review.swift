//
//  Review.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/27/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title" : title, "text": text, "rating" : rating, "reviewUserID": reviewerUserID, "date" : timeIntervalDate, "documentID" : documentID]
    }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewUserID"] as! String
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: date, documentID: "")
    }
    
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    func saveData(posting: Posting, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let dataToSave = self.dictionary
        //if we have saved a record we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("postings").document(posting.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print ("*** ERROR Updating docuemnt \(self.documentID) \(error.localizedDescription)")
                    completed (false)
                } else {
                    print ("^^^ Document updated with ref ID \(ref.documentID)")
                    posting.updateAvergeRating {
                        completed(true)
                    }
                }
            }
        } else {
            var ref: DocumentReference? = nil // let firestore create the new documentID
            ref = db.collection("postings").document(posting.documentID).collection("reviews").addDocument(data: dataToSave) { error in
                if let error = error {
                    print ("*** ERROR creating document in spot \(posting.documentID) for new review doucmentID \(error.localizedDescription)")
                    completed (false)
                } else {
                    print ("^^^ Document updated with ref ID \(ref?.documentID ?? "unknown")")
                    spot.updateAvergeRating {
                        completed(true)
                    }
                }
            }
        }
    }
    
    func deleteData(posting: Posting, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("postings").document(posting.documentID).collection("reviews").document(documentID).delete()
            { error in
                if let error = error {
                    print("ERROR: deleted review documentID \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    spot.updateAvergeRating {
                        completed(true)
                    }
                }
        }
    }
}

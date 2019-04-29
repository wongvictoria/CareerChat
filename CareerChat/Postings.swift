//
//  Postings.swift
//  
//
//  Created by Victoria Wong on 4/26/19.
//

import Foundation
import Firebase

class Postings {
    var postingArray = [Posting]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping() -> ()) {
        db.collection("postings").addSnapshotListener{ (querySnapshot, error) in
            guard error == nil else {
                print ("*** ERROR: adding the snapshot listener\(error!.localizedDescription)")
                return completed()
            }
            self.postingArray = []
            for document in querySnapshot!.documents {
                let posting = Posting(dictionary: document.data())
                posting.documentID = document.documentID
                self.postingArray.append(posting)
            }
            print("posting array here \(self.postingArray[0].name)")
            completed()
        }
    }
}


//
//  Photos.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/27/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = [] // same as: var photoArray = [Photo]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(posting: Posting, completed: @escaping() -> ()) {
        guard posting.documentID != "" else {
            return
        }
        let storage = Storage.storage()
        db.collection("postings").document(posting.documentID).collection("photos").addSnapshotListener{ (querySnapshot, error) in
            guard error == nil else {
                print ("*** ERROR: adding the snapshot listener\(error!.localizedDescription)")
                return completed()
            }
            self.photoArray = []
            var loadAttempts = 0
            let storageRef = storage.reference().child(posting.documentID)
            for document in querySnapshot!.documents {
                let photo = Photo(dictionary: document.data())
                photo.documentUUID = document.documentID
                self.photoArray.append(photo)
                
                //loading in firebase storage images
                let photoRef = storageRef.child(photo.documentUUID)
                photoRef.getData(maxSize: 25 * 1025 * 1025) { data, error in
                    if let error = error {
                        print("*** ERROR: AN ERROR occurred while reading data from file ref: \(photoRef) \(error.localizedDescription)")
                        loadAttempts += 1
                        if loadAttempts >= (querySnapshot!.count) {
                            return completed()
                        }
                    } else {
                        let image = UIImage(data: data!)
                        photo.image = image!
                        loadAttempts += 1
                        if loadAttempts >= (querySnapshot!.count) {
                            return completed()
                        }
                    }
                }
            }
        }
    }
}

//
//  ProgramDetails.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/29/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import Foundation
import Firebase

class ProgramDetails {
    var programdetailArray: [ProgramDetail] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(posting: Posting, completed: @escaping() -> ()) {
        
        guard posting.documentID != "" else {
            return
        
        };db.collection("postings").addSnapshotListener{ (querySnapshot, error) in
            guard error == nil else {
                print ("*** ERROR: adding the snapshot listener\(error!.localizedDescription)")
                return completed()
            }
            self.programdetailArray = []
            for document in querySnapshot!.documents {
                let programdetail = ProgramDetail(dictionary: document.data())
                programdetail.documentID = document.documentID
                self.programdetailArray.append(programdetail)
            }
            completed()
        }
    }
}



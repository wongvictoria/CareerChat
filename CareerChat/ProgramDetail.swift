//
//  ProgramDetail.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/29/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import Foundation
import Firebase
import MapKit
import CoreLocation

class ProgramDetail: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String
    var address: String
    var text: String
    var date: Date
    var companyUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var companyNameText: String? {
        return name
    }
    
    var addressLabelText: String? {
        return address
    }
    
    var programText: String? {
        return text
    }
    
    var dateText: String? {
        return text
    }
    
    var descriptionText: String? {
        return text
    }
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["name": name, "address": address, "longitude": longitude, "latitude": latitude, "text": text, "companyUserID": companyUserID, "date": timeIntervalDate, "documentID" : documentID]
    }
    
    init(name: String, address: String, text: String, coordinate: CLLocationCoordinate2D, companyUserID: String, date: Date, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.text = text
        self.date = date
        self.companyUserID = companyUserID
        self.documentID = documentID
    }
    
    convenience override init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(name: "", address: "", text: "", coordinate: CLLocationCoordinate2D(), companyUserID: currentUserID, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let companyUserID = dictionary["companyUserID"] as! String
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.init(name: name, address: address, text: text, coordinate: coordinate, companyUserID: companyUserID, date: date, documentID: "")
    }
    
    
    func saveData(posting: Posting, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let dataToSave = self.dictionary
        //if we have saved a record we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("postings").document(posting.documentID).collection("programdetails").document(self.documentID)
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
            ref = db.collection("postings").document(posting.documentID).collection("programdetails").addDocument(data: dataToSave) { error in
                if let error = error {
                    print ("*** ERROR creating document in spot \(posting.documentID) for new review doucmentID \(error.localizedDescription)")
                    completed (false)
                } else {
                    print ("^^^ Document updated with ref ID \(ref?.documentID ?? "unknown")")
                    posting.updateAvergeRating {
                        completed(true)
                    }
                }
            }
        }
    }
    
    func deleteData(posting: Posting, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("postings").document(posting.documentID).collection("postingdetails").document(documentID).delete()
            { error in
                if let error = error {
                    print("ERROR: deleted postingdetail documentID \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    posting.updateAvergeRating {
                        completed(true)
                    }
                }
        }
    }
}

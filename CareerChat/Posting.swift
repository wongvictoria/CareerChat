//
//  Posting.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/26/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

class Posting: NSObject, MKAnnotation {
    var name: String
    var address: String
    var datetext: String
    var text: String
    var programtext: String
    var coordinate: CLLocationCoordinate2D
    var companyUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var latitude: CLLocationDegrees{
        return coordinate.latitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return address
    }
    
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "longitude": longitude, "latitude": latitude, "companyUserID": companyUserID]
    }
    init(name: String, address: String, text: String, datetext: String, programtext: String, coordinate: CLLocationCoordinate2D, companyUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.text = text
        self.datetext = datetext
        self.programtext = programtext
        self.coordinate = coordinate
        self.companyUserID = companyUserID
        self.documentID = documentID
        
    }
    convenience override init() {
        self.init(name: "", address: "", text: "", datetext: "", programtext: "", coordinate: CLLocationCoordinate2D(), companyUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let datetext = dictionary["datetext"] as! String? ?? ""
        let programtext = dictionary["programtext"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let companyUserID = dictionary["companyUserID"] as! String? ?? ""
        self.init(name: name, address: address, text: text, datetext: datetext, programtext: programtext, coordinate:  coordinate, companyUserID: companyUserID, documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        guard let companyUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR Could not save data becuase we don't have a valid companyUserID")
            return completed(false)
        }
        self.companyUserID = companyUserID
        // create dictionary representing  the data we want to save
        let dataToSave = self.dictionary
        //if we have saved a record we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("postings").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print ("*** ERROR Updating document \(self.documentID) \(error.localizedDescription)")
                    completed (false)
                } else {
                    print ("^^^ Document updated with ref ID \(ref.documentID)")
                    completed (true)
                }
            }
        } else {
            var ref: DocumentReference? = nil // let firestore create the new documentID
            ref = db.collection("postings").addDocument(data: dataToSave) { error in
                if let error = error {
                    print ("*** ERROR creating document \(self.documentID) \(error.localizedDescription)")
                    completed (false)
                } else {
                    print ("^^^ Document updated with ref ID \(ref?.documentID ?? "unknown")")
                    self.documentID = ref!.documentID
                    completed (true)
                }
            }
        }
    }
}

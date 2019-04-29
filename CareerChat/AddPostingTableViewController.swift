//
//  AddPostingTableViewController.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/28/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import MapKit
import Contacts

class AddPostingTableViewController: UITableViewController {
    
    @IBOutlet weak var companyNameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var programNameField: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var lookupPlaceButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    var posting: Posting!
    var programdetail: ProgramDetail!
    let regionDistance: CLLocationDistance = 750 
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        guard (posting) != nil else {
            print("*** ERROR: did not have a valid Posting in PostingDetailViewController.")
            return
        }
        if programdetail == nil {
            programdetail = ProgramDetail()
        }
        updateUserInterface()
        
        if posting == nil { //we are adding a new record, fields should be editable
            posting = Posting()
            getLocation()
            companyNameField.addBorder(width: 0.5, radius: 5.0, color: .black)
            addressField.addBorder(width: 0.5, radius: 5.0, color: .black)
        } else {
            companyNameField.isEnabled = false
            addressField.isEnabled = false
            companyNameField.backgroundColor = UIColor.clear
            addressField.backgroundColor = UIColor.white
            saveBarButton.title = ""
            cancelButton.title = ""
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    func updateUserInterface() {
        companyNameField.text = programdetail.name
        programNameField.text = programdetail.programText
        addressField.text = programdetail.address
        dateField.text = programdetail.dateText
        descriptionField.text  = programdetail.descriptionText
        enableDisableSaveButton()
        if programdetail.documentID == "" { // this is a new review
            addBordersToEditableObjects()
        } else {
            if programdetail.companyUserID == Auth.auth().currentUser?.email {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                deleteButton.isHidden = false
            } else { //this review was posted by another user
                cancelButton.title = ""
                saveBarButton.title = ""
            }
        }
    }
    
    func addBordersToEditableObjects() {
        companyNameField.addBorder(width: 0.5, radius: 5.0, color: .black)
        programNameField.addBorder(width: 0.5, radius: 5.0, color: .black)
        dateField.addBorder(width: 0.5, radius: 5.0, color: .black)
        descriptionField.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func enableDisableSaveButton() {
        if companyNameField.text != "" || programNameField.text != "" || dateField.text != "" || descriptionField.text != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    func saveThenSegue() {
        programdetail.text = companyNameField.text!
        programdetail.text = programNameField.text!
        programdetail.text = dateField.text!
        programdetail.text = descriptionField.text!
        programdetail.saveData(posting: posting) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: couldn't leave this view controller because data was not saved")
            }
        }
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func reviewTitleChanged(_ sender: UITextField) {
        enableDisableSaveButton()
        
    }
    
    @IBAction func returnTitleDonePressed(_ sender: UITextField) {
        saveThenSegue()
        
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        programdetail.deleteData(posting: posting) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR: delete unsuccessful")
            }
        }
    }
    
    @IBAction func lookupPlaceButtonPressed(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = (self as! GMSAutocompleteViewControllerDelegate)
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveThenSegue()
    }
}

extension AddPostingTableViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        posting.name = place.name!
        posting.address = place.formattedAddress ?? ""
        posting.coordinate = place.coordinate
        dismiss(animated: true, completion: nil)
        updateUserInterface()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension AddPostingTableViewController: CLLocationManagerDelegate {
    
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            print("I'm sorry - can't show location. User has not authorized it.")
        case .restricted:
            print("Access denied. Likely parental controls are restricting location services in this app.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard posting.name == "" else {
            return
        }
        let geoCoder = CLGeocoder()
        var name = ""
        var address = ""
        currentLocation = locations.last
        let currentLatitude = currentLocation.coordinate.latitude
        let currentLongitude = currentLocation.coordinate.longitude
        posting.coordinate = currentLocation.coordinate
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
            if placemarks != nil {
                let placemark = placemarks?.last
                name = placemark?.name ?? "name unknown"
                // need to import contacts in order to use the code:
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            } else {
                print ("***Error retrieving place. Error code: \(error!.localizedDescription)")
            }
            self.posting.name = name
            self.posting.address = address
            self.updateUserInterface()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location.")
    }
}



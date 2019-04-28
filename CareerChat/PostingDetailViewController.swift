//
//  PostingDetailViewController.swift
//  
//
//  Created by Victoria Wong on 4/27/19.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class PostingDetailViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    var posting: Posting!
    var reviews: Reviews!
    var photos: Photos!
    let regionDistance: CLLocationDistance = 750 //750 meters, or about half a mile
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        //mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePicker.delegate = self
        
        //mapView.delegate = self
        
        if posting == nil { //we are adding a new record, fields should be editable
            posting = Posting()
            getLocation()
            nameField.addBorder(width: 0.5, radius: 5.0, color: .black)
            addressField.addBorder(width: 0.5, radius: 5.0, color: .black)
        } else {
            nameField.isEnabled = false
            addressField.isEnabled = false
            nameField.backgroundColor = UIColor.clear
            addressField.backgroundColor = UIColor.white
            saveBarButton.title = ""
            cancelBarButton.title = ""
            navigationController?.setToolbarHidden(true, animated: true)
        }
        
        reviews = Reviews()
        photos = Photos()
        
        let region = MKCoordinateRegion(center: posting.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reviews.loadData(posting: posting) {
            self.tableView.reloadData()
            if self.reviews.reviewArray.count > 0 {
                var total = 0
                for review in self.reviews.reviewArray {
                    total = total + review.rating
                }
                let average = Double(total) / Double(self.reviews.reviewArray.count)
                self.averageRatingLabel.text = "\(average.roundTo(places: 1))"
            } else {
                self.averageRatingLabel.text = "-.-"
            }
        }
        photos.loadData(posting: posting) {
            self.tableView.reloadData()
        }
        photos.loadData(posting: posting) {
            self.collectionView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        posting.name = nameField.text!
        posting.address = addressField.text!
        switch segue.identifier ?? "" {
        case "AddReview" :
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ReviewTableViewController
            destination.posting = posting
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        case "ShowReview" :
            let destination = segue.destination as! ReviewTableViewController
            destination.posting = posting
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.review = reviews.reviewArray[selectedIndexPath.row]
        default:
            print("** ERROR: did not have a segue in SpotDetailViewController prepare(for segue:)")
        }
        
    }
    
    func disableTextEditing() {
        nameField.backgroundColor = UIColor.clear
        nameField.isEnabled = false
        nameField.noBorder()
        addressField.backgroundColor = UIColor.clear
        addressField.isEnabled = false
        addressField.noBorder()
    }
    
    func saveCancelAlert(title: String, message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.posting.saveData { success in
                self.saveBarButton.title = "Done"
                self.cancelBarButton.title = ""
                self.navigationController?.setToolbarHidden(true, animated: true)
                self.disableTextEditing()
                if segueIdentifier == "AddReview" {
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
                } else {
                    self.cameraOrLibraryAlert()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateUserInterface() {
        nameField.text = posting.name
        addressField.text = posting.address
        updateMap()
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(posting)
        mapView.setCenter(posting.coordinate, animated: true)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {_ in
            self.accessCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) {_ in
            self.accessLibrary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        saveBarButton.isEnabled = !(nameField.text == "")
        
    }
    @IBAction func textFieldReturnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
        posting.name = nameField.text!
        posting.address = addressField.text!
        updateUserInterface()
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        if posting.documentID == "" {
            saveCancelAlert(title: "This venue has not been saved", message: "You must save this venue before you can add a photo", segueIdentifier: "AddPhoto")
        } else {
            cameraOrLibraryAlert()
        }
    }
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        if posting.documentID == "" {
            saveCancelAlert(title: "This venue has not been saved", message: "You must save this venue before you review it", segueIdentifier: "AddReview")
        } else {
            performSegue(withIdentifier: "AddReview", sender: nil)
        }
        //saveCancelAlert performSegue(withIdentifier: "AddReview", sender: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        posting.name = nameField.text!
        posting.address = addressField.text!
        posting.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print ("***ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    @IBAction func lookupPlacePressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
}
extension PostingDetailViewController: GMSAutocompleteViewControllerDelegate {
    
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

extension PostingDetailViewController: CLLocationManagerDelegate {
    
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

extension PostingDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! PostingReviewsTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        return cell
    }
    
}

extension PostingDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photoArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PostingPhotosCollectionViewCell
        cell.photo = photos.photoArray[indexPath.row]
        return cell
    }
}

extension PostingDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = Photo()
        photo.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true) {
            photo.saveData(posting: self.posting) { (success) in
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessLibrary(){
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(title: "Camera not available", message: "There is no camera available on this device")
        }
        
    }
}


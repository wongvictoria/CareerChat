//
//  CommentTableViewController.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/28/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import UIKit
import Firebase

class CommentTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var reviewTitleField: UITextField!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var reviewTextView: UITextView!
   
    
    var posting: Posting!
    var review: Review!
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        guard (posting) != nil else {
            print("*** ERROR: did not have a valid Spot in ReviewDetailViewController.")
            return
        }
        if review == nil {
            review = Review()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameLabel.text = posting.name
        addressLabel.text = posting.address
        reviewTitleField.text = review.title
        enableDisableSaveButton()
        reviewTextView.text = review.text
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        reviewDateLabel.text = "posted: \(dateFormatter.string(from: review.date))"
        if review.documentID == "" { // this is a new comment
            addBordersToEditableObjects()
        } else {
            if review.reviewerUserID == Auth.auth().currentUser?.email {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                deleteButton.isHidden = false
            } else { //this review was posted by another user
                cancelBarButton.title = ""
                saveBarButton.title = ""
                postedByLabel.text = "Posted by: \(review.reviewerUserID)"
            }
        }
    }
    
    func addBordersToEditableObjects() {
        reviewTitleField.addBorder(width: 0.5, radius: 5.0, color: .black)
        reviewTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func enableDisableSaveButton() {
        if reviewTitleField.text != ""{
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    func saveThenSegue() {
        review.title = reviewTitleField.text!
        review.text = reviewTextView.text!
        review.saveData(posting: posting) { (success) in
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
            print("in 1")
            dismiss(animated: true, completion: nil)
        } else {
            print("in 2")
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
        leaveViewController()
        review.deleteData(posting: posting) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR: delete unsuccessful")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveThenSegue()
        leaveViewController()
    }
}




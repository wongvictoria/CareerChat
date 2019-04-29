//
//  AddPostingTableViewController.swift
//  CareerChat
//
//  Created by Victoria Wong on 4/28/19.
//  Copyright © 2019 Victoria Wong. All rights reserved.
//

import UIKit
import Firebase

class AddPostingTableViewController: UITableViewController {
    
    @IBOutlet weak var companyNameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var programNameField: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var lookupPlaceButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    var posting: Posting!
    var programdetail: ProgramDetail!

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
    }
    
    func updateUserInterface() {
        companyNameField.text = programdetail.name
        programNameField.text = programdetail.programText
        addressLabel.text = programdetail.address
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
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveThenSegue()
    }
}



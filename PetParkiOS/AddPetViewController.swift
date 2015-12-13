//
//  AddPetViewController.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

class AddPetViewController: UIViewController
{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var breedsPicker: UIPickerView!
    @IBOutlet weak var speciesButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    private let operationQueue = OperationQueue()
    // TODO: Create an API call for those
    private var species = ["Dog","Cat", "Turtle", "Rabbit", "Parrot", "Chameleon", "Snake", "Hamster"]
    private var selectedSpecies = "Dog"
    private var breeds = [Breed]() { didSet { dispatch_async(dispatch_get_main_queue()) { self.breedsPicker.reloadAllComponents() } } }
    private var breedPickerEnabled: Bool = false {
        didSet {
            breedsPicker.userInteractionEnabled = breedPickerEnabled
            breedsPicker.alpha = breedPickerEnabled ? CGFloat(1) : CGFloat(0.6)
        }
    }
    
    private var disableUI: Bool = false {
        didSet {
            nameTextField.enabled          = disableUI
            genderSegmentedControl.enabled = disableUI
            breedPickerEnabled             = disableUI
            speciesButton.enabled          = disableUI
            ageTextField.enabled           = disableUI
            weightTextField.enabled        = disableUI
            addButton.enabled              = disableUI
        }
    }
    
    @IBAction func speciesButtonTapped(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Select Species", preferredStyle: .ActionSheet)
        optionMenu.popoverPresentationController?.sourceView = sender
        optionMenu.popoverPresentationController?.sourceRect = sender.bounds
        
        for petSpecies in species{
            optionMenu.addAction(UIAlertAction(title: petSpecies, style: UIAlertActionStyle.Default) { alert in
                self.selectedSpecies = petSpecies
                self.listBreeds(petSpecies)
                sender.setTitle(petSpecies, forState: .Normal)
                })
        }
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(sender: UIButton) {
        sender.resignFirstResponder()
        if !validateFields() { return }
        disableUI = true
            
        let name = nameTextField.text!
        let gender = genderSegmentedControl.selectedSegmentIndex == 0 ? "Male" : "Female"
        let breed = breeds[breedsPicker.selectedRowInComponent(0)].breedID
        let age = ageTextField.text!
        let weight = weightTextField.text!
        
        let createPetOperation = CreatePetOperation(
            petName: name,
            gender: gender,
            species: selectedSpecies,
            breed: breed,
            age: age,
            weight: weight
        )
        createPetOperation.delegate = self
        self.operationQueue.addOperation(createPetOperation)
    }
    
    private func validateFields() -> Bool {
        var valid = true
        
        if let name = nameTextField.text where name != "" {} else {
            nameTextField.text = ""
            nameTextField.attributedPlaceholder = NSAttributedString(string: "please enter a valid pet name", attributes: [
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(12)
                ])
            valid = false
        }
        
        if let years = ageTextField.text where years != "" {} else {
            ageTextField.text = ""
            ageTextField.attributedPlaceholder = NSAttributedString(string: "please enter a valid age", attributes: [
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(12)
                ])
            valid = false
        }
        
        if let weight = weightTextField.text where weight != "" {} else {
            weightTextField.text = ""
            weightTextField.attributedPlaceholder = NSAttributedString(string: "unsupported weight", attributes: [
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(12)
                ])
            valid = false
        }
        
        return valid
    }
    
    func listBreeds(petSpecies: String) {
        let listBreedsOperation = ListBreedsOperation(speciesID: petSpecies)
        listBreedsOperation.delegate = self
        self.operationQueue.addOperation(listBreedsOperation)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breedsPicker.delegate = self
        breedsPicker.dataSource = self
        listBreeds(selectedSpecies)
    }
}

extension AddPetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return breeds.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if breeds.count != 0 { return breeds[row].breedID }
        return nil
    }
}

extension AddPetViewController: ListBreedsDelegate {
    func didListBreeds(breeds: [Breed]) {
        self.breeds = breeds
    }
}

extension AddPetViewController: CreatePetOperationDelegate {
    func didFinishCreatingPet(success: Bool) {
        if success {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
             disableUI = false
        }
    }
}
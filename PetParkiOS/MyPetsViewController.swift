//
//  PhotoViewController.swift
//  SidebarMenu
//
//  Created by Gavril Tonev on 12/11/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

class MyPetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    private let operationQueue = OperationQueue()
    
    private var pets = [Pet]() { didSet { dispatch_async(dispatch_get_main_queue()) { self.tableView.reloadData() } } }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! MyPetsTableViewCell
        
        cell.pet = pets[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showUserPetDetailsViewController", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUserPetDetailsViewController" {
            let petDetailsViewController = segue.destinationViewController as! PetDetailsViewController
            petDetailsViewController.pet = pets[tableView.indexPathForSelectedRow!.row]
            petDetailsViewController.isForeignUser = false
        } else if segue.identifier == "popoverAddPetViewController" {
            let popoverViewController = segue.destinationViewController as! AddPetViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        tableView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let listUserPetsOperation = ListUserPetsOperation()
        listUserPetsOperation.delegate = self
        operationQueue.addOperation(listUserPetsOperation)
    }
}

extension MyPetsViewController: ListUserPetsDelegate {
    func didListUserPets(pets: [Pet]) {
        self.pets = pets
    }
}

extension MyPetsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
//
//  NewsTableViewController.swift
//  SidebarMenu
//
//  Created by Gavril Tonev on 12/11/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    @IBOutlet var menuButton:UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
//            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"

            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        return cell
    }

}

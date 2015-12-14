//
//  MenuController.swift
//  SidebarMenu
//
//  Created by Gavrl Tonev on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 5 {
            Preferences.reset()
            exit(0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

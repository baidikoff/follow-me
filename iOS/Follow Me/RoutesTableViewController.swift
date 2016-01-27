//
//  RoutesTableViewController.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 07.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import UIKit

class RoutesTableViewController: UITableViewController {
    
  var routes = [Route]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController!.hidesNavigationBarHairline = true
  }
  
  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return routes.count
  }
}

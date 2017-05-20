//
//  CategoryViewController.swift
//  Books
//
//  Created by 김인로 on 2017. 5. 19..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit


class CategoryViewController: UITableViewController {

    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    @IBAction func doneClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

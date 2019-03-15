//
//  AddCatsTableViewController.swift
//  ShoppingCart
//
//  Created by Austin English on 3/13/19.
//  Copyright © 2019 Austin English. All rights reserved.
//

import UIKit



class AddCatsTableViewController: UITableViewController {
    
    var category: String?
    @IBOutlet weak var nameTextField: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        
        if((nameTextField.text?.count)! > 0){
            
            if segue.identifier == "SaveCatDetail",
                let categoryName = nameTextField.text {
                category = categoryName
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.separatorColor = #colorLiteral(red: 0.5893463663, green: 0.9764705896, blue: 0.9743636855, alpha: 1)
        self.tableView.backgroundColor = #colorLiteral(red: 0.4399745297, green: 0.7880541348, blue: 0.9188682736, alpha: 1);
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.5893463663, green: 0.9764705896, blue: 0.9743636855, alpha: 1)
    }
    
}

extension AddCatsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            nameTextField.becomeFirstResponder()
        }
    }
}

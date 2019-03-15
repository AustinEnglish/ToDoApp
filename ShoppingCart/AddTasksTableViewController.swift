//
//  AddTasksTableViewController.swift
//  ShoppingCart
//
//  Created by Austin English on 3/14/19.
//  Copyright © 2019 Austin English. All rights reserved.
//

import UIKit

struct taskUserData{
    
    var name: String
    var description: String
    var dateComplete: Date
}

class AddTasksTableViewController: UITableViewController {
    
    var task: taskUserData?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    let datePicker = UIDatePicker()
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        
        if((nameTextField.text?.count)! > 0 && (descriptionTextField.text?.count)! > 0 && (dateTextField.text?.count)! > 0){
            
            if segue.identifier == "SaveTaskDetail",
                let name = nameTextField.text, let description = descriptionTextField.text, let dateComplete = dateTextField.text  {
                task = taskUserData(name:name,description:description, dateComplete:dateComplete.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss"))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = #colorLiteral(red: 0.5893463663, green: 0.9764705896, blue: 0.9743636855, alpha: 1)
        self.tableView.backgroundColor = #colorLiteral(red: 0.4399745297, green: 0.7880541348, blue: 0.9188682736, alpha: 1);
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.5893463663, green: 0.9764705896, blue: 0.9743636855, alpha: 1)
        showDatePicker()
        
        
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
}


extension String
{
    func toDate( dateFormat format  : String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
        return dateFormatter.date(from: self)!
    }
    
}



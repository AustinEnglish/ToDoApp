//
//  ItemsTableViewController.swift
//  ShoppingCart
//
//  Created by Austin English on 3/13/19.
//  Copyright © 2019 Austin English. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TaskTableViewCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var completedLabel: UILabel!
    
}

class ItemsTableViewController: UITableViewController {
    
    var catId: String? = nil
    var arrItemsMatch = [[String:AnyObject]]()
    
    
    
    override func viewDidLoad() {
        self.tableView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1);
        super.viewDidLoad()
        
        //first time using app only
        if(UserDefaults.standard.bool(forKey: "userGuide2")==false){
            displayUserGuide();
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        //made closure didnt end up using it
        getItems() { () in}
        
    }
    
    func displayUserGuide(){
        
        let alert = UIAlertController(title: "Swipe left to delete or complete/incomplete a task and tap to update", message: nil, preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: { () in
            UserDefaults.standard.set(true, forKey: "userGuide2")
        })
        
    }
    
    
    func getItemsInCategory(){
        
        for item in Globals.arrItems{
            
            if(item["category_id"] as? String == self.catId){
                
                if(item["completed"] as? String == "0"){
                    self.arrItemsMatch.insert(item, at: 0)
                }else{
                    self.arrItemsMatch.append(item);
                }
                
                
            }
            
        }
    }
    
    func getItems(completion: @escaping () -> ()){
        
        Alamofire.request("https://api.fusionofideas.com/todo/getItems.php").responseJSON { (responseData) -> () in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["content"].arrayObject {
                    Globals.arrItems = resData as! [[String:AnyObject]]
                }
            }
            
            self.getItemsInCategory()
            self.tableView.reloadData()
            // wait till http request is done to run completion above ^
            completion()
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        tableView.separatorColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItemsMatch.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
            as! TaskTableViewCell
        
        let dict = arrItemsMatch[indexPath.row]
        cell.nameLabel?.text =  "Name: " + ((dict["name"] as? String)!)
        cell.descriptionLabel?.text = "Description: " + ((dict["description"] as? String)!)
        cell.dueDateLabel?.text =  "Due: " + ((dict["due"] as? String)!)
        cell.completedLabel?.text =  "Complete: " + (dict["completed"] as? String == "1" ? "Yes":"No")
        
        cell.backgroundColor = UIColor.clear
        
        
        if(dict["completed"] as? String == "1"){
            cell.completedLabel?.textColor = #colorLiteral(red: 0.3370522514, green: 0.5, blue: 0.327416096, alpha: 1)
        }
        else{
            cell.completedLabel?.textColor = UIColor.red;
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = arrItemsMatch[indexPath.row]
        let id = dict["id"] as? String
        
        //UPDATE
        
        let alert = UIAlertController(title: "Update Task", message: nil, preferredStyle: .alert)
        
        //get text field the name of current item
        alert.addTextField { (nameTextField) in
            nameTextField.text = dict["name"] as? String
        }
        alert.addTextField { (desTextField) in
            desTextField.text = dict["description"] as? String
        }
        alert.addTextField { (dateTextField) in
            dateTextField.text = dict["due"] as? String
        }
        
        
        
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
            //grab text field
            let nameTextField = alert.textFields![0].text
            let desTextField = alert.textFields![1].text
            let dateTextField = alert.textFields![2].text
            
            
            //update from DB
            let url = "https://api.fusionofideas.com/todo/updateItem.php"
            let parameters: Parameters = ["id": id!, "name":nameTextField!, "description": desTextField!, "due":dateTextField!]
            
            Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
                print(response)
                self.arrItemsMatch.removeAll()
                self.getItems() { () in}
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let dict = arrItemsMatch[indexPath.row]
        let id = dict["id"] as? String
        let date = dict["due"] as? String
        let isComplete = dict["completed"] as? String
        
        
        
        // DELETE
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let alert = UIAlertController(title: "Delete Task", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //delete from DB
                let url = "https://api.fusionofideas.com/todo/deleteItem.php"
                let parameters: Parameters = ["id": id!]
                
                Alamofire.request(url, method: .delete, parameters: parameters).responseJSON { response in
                    print(response)
                    self.arrItemsMatch.removeAll()
                    self.getItems() { () in}
                    
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.red
        
        
        // Mark Complete
        let complete = UITableViewRowAction(style: .destructive, title: "Complete") { (action, indexPath) in
            
            let alert = UIAlertController(title: " Mark Complete?", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //update from DB
                let url = "https://api.fusionofideas.com/todo/updateItem.php"
                let parameters: Parameters = ["id": id!, "due":date!,"completed":1]
                
                Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
                    print(response)
                    self.arrItemsMatch.removeAll()
                    self.getItems() { () in}
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        complete.backgroundColor = #colorLiteral(red: 0.08885005861, green: 0.6687420685, blue: 0.3356298871, alpha: 1)
        
        
        // Mark incomplete
        let notComplete = UITableViewRowAction(style: .destructive, title: "Incomplete") { (action, indexPath) in
            
            let alert = UIAlertController(title: "Mark incomplete?", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //update from DB
                let url = "https://api.fusionofideas.com/todo/updateItem.php"
                let parameters: Parameters = ["id": id!, "due":date!,"completed":0]
                
                Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
                    print(response)
                    self.arrItemsMatch.removeAll()
                    self.getItems() { () in}
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        notComplete.backgroundColor = #colorLiteral(red: 0.7819241751, green: 0.7271346964, blue: 0.08862614257, alpha: 1)
        
        
        if(isComplete == "0"){
            return [delete,complete]
        }
        else{
            return [delete,notComplete]
        }
        
    }
    
}


extension ItemsTableViewController {
    
    @IBAction func cancelToTasksViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveTaskDetail(_ segue: UIStoryboardSegue) {
        
        guard let AddTasksTableViewController = segue.source as? AddTasksTableViewController,
            let task = AddTasksTableViewController.task else {
                return
        }
        
        let url = "https://api.fusionofideas.com/todo/addItem.php"
        let parameters: Parameters = ["name": task.name,"description":task.description, "category_id":self.catId as! String,"due":task.dateComplete]
        
        
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            print(response)
            self.arrItemsMatch.removeAll()
            //self.getItems() { () in} //dont need this because will call viewWillAppear()
            
        }
        
    }
    
    
    
}


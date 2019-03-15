//
//  CategoriesTableViewController.swift
//  ShoppingCart
//
//  Created by Austin English on 3/13/19.
//  Copyright © 2019 Austin English. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON 


class CategoriesTableViewController: UITableViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.5893463663, green: 0.9764705896, blue: 0.9743636855, alpha: 1)
        self.tableView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1);
        getCategories()
        
        //first time using app only
        if(UserDefaults.standard.bool(forKey: "userGuide")==false){
            displayUserGuide();
        }
    }
    
    func displayUserGuide(){
        
        let alert = UIAlertController(title: "Swipe left to update/delete a category and tap to view Tasks", message: nil, preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: { () in
            UserDefaults.standard.set(true, forKey: "userGuide")
        })
        
    }
    
    
    
    func getCategories(){
        
        Alamofire.request("https://api.fusionofideas.com/todo/getCategories.php").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["content"].arrayObject {
                    Globals.arrCats = resData as! [[String:AnyObject]]
                }
                if Globals.arrCats.count > 0 {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        tableView.separatorColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Globals.arrCats.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "catCell")!
        
        //place data from dic array at this row spot
        let dict = Globals.arrCats[indexPath.row]
        cell.textLabel?.text = dict["name"] as? String
        
        cell.textLabel?.font = UIFont(name:"Georgia-Bold", size:18)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dict = Globals.arrCats[indexPath.row]
        let id = dict["id"] as? String
        
        // show results
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsTableViewController") as! ItemsTableViewController
        controller.catId = id;
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let dict = Globals.arrCats[indexPath.row]
        let id = dict["id"] as? String
        
        
        
        // DELETE
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let alert = UIAlertController(title: "Delete Category", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //delete from DB
                let url = "https://api.fusionofideas.com/todo/deleteCategory.php"
                let parameters: Parameters = ["id": id!]
                
                Alamofire.request(url, method: .delete, parameters: parameters).responseJSON { response in
                    print(response)
                    self.getCategories()
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.red
        
        
        //UPDATE
        let update = UITableViewRowAction(style: .destructive, title: "Update") { (action, indexPath) in
            
            let alert = UIAlertController(title: "Update Category", message: nil, preferredStyle: .alert)
            
            //get text field the name of current Cat
            alert.addTextField { (textField) in
                textField.text = dict["name"] as? String
            }
            
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
                //grab text field
                let textField = alert.textFields![0].text
                
                
                //update from DB
                let url = "https://api.fusionofideas.com/todo/updateCategory.php"
                let parameters: Parameters = ["id": id!, "name":textField!]
                
                Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
                    print(response)
                    self.getCategories()
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        update.backgroundColor = UIColor.blue
        
        
        return [delete,update]
        
    }
    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
}


extension CategoriesTableViewController {
    
    @IBAction func cancelToCategoriesViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveCatDetail(_ segue: UIStoryboardSegue) {
        
        guard let AddCatsTableViewController = segue.source as? AddCatsTableViewController,
            let catName = AddCatsTableViewController.category else {
                return
        }
        
        let url = "https://api.fusionofideas.com/todo/addCategory.php"
        let parameters: Parameters = ["name": catName]
        
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            print(response)
            self.getCategories()
        }
        
    }
    
    
    
}


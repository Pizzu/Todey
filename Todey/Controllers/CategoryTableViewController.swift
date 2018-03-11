//
//  CategoryTableViewController.swift
//  Todey
//
//  Created by Luca Lo Forte on 01/03/18.
//  Copyright © 2018 Luca Lo Forte. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryArray : Results<Category>?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        cell.accessoryType = .disclosureIndicator
        
        if let category = categoryArray?[indexPath.row] {
            
            cell.textLabel?.text = category.name //?? "No Categories Added Yet"
            
                if let color = UIColor(hexString: category.colorCategory){
                
                cell.backgroundColor = color
                
                cell.textLabel?.textColor = ContrastColorOf(color , returnFlat: true)
            }
            
        }
        return cell
    }

    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
        
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colorCategory = UIColor.randomFlat.hexValue()
            
            self.saveCategories(category : newCategory)
        
        }
    
        alert.addAction(action)

        alert.addTextField { (alertTextField) in
            textField.placeholder = "New Category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manupulation Methods
    func saveCategories(category : Category){
        do{
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving Category, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        categoryArray = realm.objects(Category.self)
        
        
        tableView.reloadData()
        
    }
    
}

//MARK: - Swipe Cell Delegate Methods

extension CategoryTableViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if let category = self.categoryArray?[indexPath.row]{
                do {
                    try self.realm.write {
                        self.realm.delete(category)
                    }
                } catch {
                    print("Error deleting category, \(error)")
                }
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    
}


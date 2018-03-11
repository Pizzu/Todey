//
//  ViewController.swift
//  Todey
//
//  Created by Luca Lo Forte on 21/02/18.
//  Copyright © 2018 Luca Lo Forte. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class ToDoListViewController: UITableViewController {

    var itemArray : Results<Item>?
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //chiamiamo loadItems quando siamo sicuri di avere la nostra categoria
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
         navigationController?.navigationBar.tintColor = UIColor(hexString: selectedCategory!.colorCategory)
    }
    //Dopo che il navigation controller è stato stabilito
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.colorCategory {
            
            //Titolo del navigation controller
            title = selectedCategory!.name
            searchBar.barTintColor = UIColor(hexString: colorHex)
            updateNavBar(withHexCode: colorHex)
            
        }
    }
    //Chiamata quando la view sta per essere rimossa della gerarchia della navigazione
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - NavBar Setup
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
        
        if let navBarColor = UIColor(hexString : colorHexCode) {
            
            navBar.barTintColor = navBarColor
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true) ]
            
        }
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        if let item = itemArray?[indexPath.row] {
        
            cell.textLabel?.text = item.title
            
            if let category = selectedCategory {
                if let color = UIColor(hexString : category.colorCategory)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) {
                    cell.backgroundColor = color
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                    
                }
            }
            
            //Possiamo usare il ternary operator
            //value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done == true ? .checkmark : .none // potremmo togliere anche il == true
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
   
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error updating Item, \(error)")
            }
        }
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
        
    }
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write{
                        
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date() //ora ogni item avrà la data e il tempo corrente(della sua creazione)
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving Item, \(error)")
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)

    }
    
    //MARK: - Model Manupulation Methods
    
    func loadItems(){
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()

    }
}

//MARK: - Search bar methods

extension ToDoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //tornare allo stato originario prima dell'attivazione della searchBar
            }
           
        }
    }
}

//MARK: - Swipe Cell Delegate Methods

extension ToDoListViewController : SwipeTableViewCellDelegate {
    
        func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
            guard orientation == .right else { return nil }
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                if let item = self.itemArray?[indexPath.row]{
                    do {
                        try self.realm.write {
                            self.realm.delete(item)
                        }
                    } catch {
                        print("Error deleting item, \(error)")
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







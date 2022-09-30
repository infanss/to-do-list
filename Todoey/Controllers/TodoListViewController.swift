//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //for categories in CategoryVC:
    var selectedCategory : Category? {
        didSet{ // it will happen as soon as I use this var
           loadItems()
  }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       loadItems()
        
       tableView.separatorStyle = .none
                                                               
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let hexColor = selectedCategory?.color{
            
            title = selectedCategory!.name
   
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesn't exsist.") }
            
            if let navBarColor = UIColor(hexString: hexColor){
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                searchBar.backgroundColor =  UIColor(hexString: hexColor)
                searchBar.searchTextField.backgroundColor = FlatWhite()
                
                let bar = UINavigationBarAppearance()
                
                bar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]

                bar.backgroundColor = navBarColor

                navigationController?.navigationBar.standardAppearance = bar

                navigationController?.navigationBar.scrollEdgeAppearance = bar
                
            }
        }
        
    }
    
    //MARK: - Tableview Datasource Methods
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let colorOfCategory = selectedCategory!.color
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            if let color =  UIColor(hexString: colorOfCategory)?.darken(byPercentage:(CGFloat(indexPath.row) / CGFloat(todoItems!.count))){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            //Ternary Operator to check wherether the item is chosen or not (value = condition ? IfTrue : IfFalse):
            cell.accessoryType = item.done ? .checkmark : .none
          
        
        }else{
            cell.textLabel?.text = "There are no items yet"
        }
        
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write({
                    item.done = !item.done
                })
            }catch{
                print("Error \(error)")
            }
        }

        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Cell (item)
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Task", style: .default) { action in
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.date = Date()
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error \(error) !")
                }
            }

            self.tableView.reloadData()
        }

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Write something"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    

    //MARK: - Read the data from the container
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Section
    
    override func updateModel(at indexPath: IndexPath) {
        if let delitingItem = todoItems?[indexPath.row] {
            do {
                try realm.write({
                    realm.delete(delitingItem)
                })
            }catch{
                print(error)
            }
        }
    }
    
}

    
    //MARK: - Delegate method for a UISearchBar

extension TodoListViewController: UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

 }
 }

}





//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Яна Колобовникова   on 10.09.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    var categories : Results<Category>? // "Results" is an auto save data type for Realm queries

    override func viewDidLoad() {
        super.viewDidLoad()
        
       tableView.separatorStyle = .none
       loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let navBar = navigationController?.navigationBar
        navBar?.tintColor = UIColor.black
        
        let bar = UINavigationBarAppearance()
        bar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        bar.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = bar
        navigationController?.navigationBar.scrollEdgeAppearance = bar
     

    }
    
    //MARK: - TableView Datasource Methods
    
    // To see how much rows we need
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return categories?.count ?? 1
    }
    
    // To create a reusable cell:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: category.color) ?? .white, returnFlat: true)
            
            cell.backgroundColor = UIColor(hexString: category.color)
        }

        return cell
    }
    
    
    //MARK: - TableView Manipulations Methods
    
    //Save new data
    
    func save(category : Category) {
        do{
            try realm.write({
                realm.add(category)
            })
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    //Read the data from the container
        
        func loadCategories() {
            
            categories = realm.objects(Category.self)
            
            tableView.reloadData()
        }
    
    //MARK: - Delete Section
    
    override func updateModel(at indexPath: IndexPath) {
        if let delitingCategory = categories?[indexPath.row]{
            do{
                try realm.write({
                    realm.delete(delitingCategory)
                })
            }catch{
                print(error)
            }
        }
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        //What exactly should happen when the user clicks "Add" button:
        let action = UIAlertAction(title: "Add", style: .default) { action in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Write something..."
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        }
    
    //MARK: - TableView Delegate Methods
    
    //Go to Items after clicking on a category
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToList", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //To prepare Items and show only those that are connected with this category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        //Grab the category that corresponds to the selected cell
        
        if  let indexPath = tableView.indexPathForSelectedRow{ // this will identify the selected cell
            destinationVC.selectedCategory = categories?[indexPath.row] //selectedCategory is created in TodoListVC
        }
        
    }
}

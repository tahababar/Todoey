//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//


//core data functionality with an automatically generated sqlite file that is being stored locally and data is being added there
import UIKit
import CoreData

class ToDoListViewController: UITableViewController, UISearchBarDelegate {

    var itemArray = [Item]() //item objects
    
    var selectedCategory: Category? {
        didSet{
            loadItems() //didset checks for changes, as soon as selectedCategory becomes something in our catgorycontrollr method...it will loaditms depnding on the category selection here
        }
    }

    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchBar.delegate = self ...we dont need to do this as we used ctrl and drag dropped the searchbar to view icon to asign delegate that way in layour
//        let newItem = Item()
//        newItem.title = "Find Mike"
//        newItem.done = false
//        itemArray.append(newItem)
        //loadItems()
       
//       if let items = defaults.array(forKey: "TodoListArray") as? [Item]{
//           itemArray = items
//        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellItem", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        if itemArray[indexPath.row].done == true{
            cell.accessoryType = .checkmark
        }
        else{
            cell.accessoryType = .none
        }
        
        //this if-else can be rewritten using swift ternary operator
        //cell.accessoryType = item.done == true ? .checkmark : .none
            return cell
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if itemArray[indexPath.row].done == false{
            itemArray[indexPath.row].done = true
        }
        else{
            itemArray[indexPath.row].done = false
        }
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert =  UIAlertController(title:"Add New Todoey Item", message:"",preferredStyle: .alert)
        let action = UIAlertAction(title:"Add Item",  style: .default){
            (action) in
            
            let context =  (UIApplication.shared.delegate  as! AppDelegate).persistentContainer.viewContext
            
            let newItem = Item(context: context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
        
            
            self.saveItems()
        }
        alert.addTextField {
            (alertTextField) in
            alertTextField.placeholder  = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        //let encoder = PropertyListEncoder()
        do{
            
            let context =  (UIApplication.shared.delegate  as! AppDelegate).persistentContainer.viewContext
           try context.save()
        }catch{
            print(error)
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(){
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let context =  (UIApplication.shared.delegate  as! AppDelegate).persistentContainer.viewContext
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        request.predicate = categoryPredicate
        do{
            itemArray = try context.fetch(request)
        } catch {
            print(error)
        }
        tableView.reloadData()
       
        }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let context =  (UIApplication.shared.delegate  as! AppDelegate).persistentContainer.viewContext
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate: NSPredicate? = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key:"title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        do{
            itemArray = try context.fetch(request)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems() //checks if search content changed or removed..if nothing now..so just all items in our array
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }//to remove cursor from search bar and to show the normal list view agaib
            tableView.reloadData()
    }
    
    }
        
    }

//context.delete takes an object and can delete a specific NSobject if needed from db



//USERDEFAULTS CAN BE USED TO STORE SMALL DATA/NOT FOR BIG DB DATA
/*
 let defaults = USerDefaults.standard
 let dictionaryKey = "myDictionary"
 defaults.set(0.24, forKey: "Volume")
 defaults.set(true, forKey: "MusicOn")
 defaults.set("Angela", forKey: "PlayerName")
 defaults.set(Date(), forKey: "AppLastOpenedByUser")
 let array = [1,2,3]
 defaults.set(array, forKey: "myArray")
 let volume = defaults.float(forKey: "Volume")
 let appLastOpen = defaults.object(forKey: "AppLastOpenedByUser")
 let myArray = defaults.array(forKey:"myArray") as! [Int]
//Swift keeps track of this using singleton objects in a class
 //UserDEFAULTS has singelton standard object similar to this code
 class Car{
 var color = "red"
 static let singletonCar = Car()
 }
 let myCar =Car.singletonCar
 myCar.color = "Blue"
 
 //now even if we create multiple other classes or code chunks even out of scope of this
 " let myCar =Car.singletonCar
 myCar.color = "Blue""
 we will still get color blue and not red everytime we print the color...using static let singleton functionality we can permanantly change or persist data
 */

//the code down worked with UserDefault but crashed when we made Item Object data as objects shouldnot be dealt with userdeafult as its large chunk of data
//old code below using userDefualt
/*
 import UIKit

 class ToDoListViewController: UITableViewController {

     var itemArray = [Item]() //item objects
     
     let defaults = UserDefaults.standard
     
     override func viewDidLoad() {
         super.viewDidLoad()
         let newItem = Item()
         newItem.title = "Find Mike"
         newItem.done = true
         itemArray.append(newItem)
        if let items = defaults.array(forKey: "TodoListArray") as? [Item]{
            itemArray = items
         }
     }
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return itemArray.count
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellItem", for: indexPath)
         cell.textLabel?.text = itemArray[indexPath.row].title
         if itemArray[indexPath.row].done == true{
             cell.accessoryType = .checkmark
         }
         else{
             cell.accessoryType = .none
         }
         
         //this if-else can be rewritten using swift ternary operator
         //cell.accessoryType = item.done == true ? .checkmark : .none
             return cell
         }
     
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
         if itemArray[indexPath.row].done == false{
             itemArray[indexPath.row].done = true
         }
         else{
             itemArray[indexPath.row].done = false
         }
         
         tableView.reloadData()
         
         tableView.deselectRow(at: indexPath, animated: true)
         
     }
     
     @IBAction func addButtonPressed(_ sender: Any) {
         var textField = UITextField()
         let alert =  UIAlertController(title:"Add New Todoey Item", message:"",preferredStyle: .alert)
         let action = UIAlertAction(title:"Add Item",  style: .default){
             (action) in
             
             let newItem = Item()
             newItem.title = textField.text!
             self.itemArray.append(newItem)
             self.defaults.set(self.itemArray, forKey: "TodoListArray")
             self.tableView.reloadData()
         }
         alert.addTextField {
             (alertTextField) in
             alertTextField.placeholder  = "Create new item"
             textField = alertTextField
         }
         alert.addAction(action)
         present(alert, animated: true, completion: nil)
     }
     

 }
 
 //Code below is for small persistent data using plists and codable delegates
 import UIKit

 class ToDoListViewController: UITableViewController {

     var itemArray = [Item]() //item objects
     
     
     let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
     
     override func viewDidLoad() {
         super.viewDidLoad()
 //        let newItem = Item()
 //        newItem.title = "Find Mike"
 //        newItem.done = false
 //        itemArray.append(newItem)
         loadItems()
        
 //       if let items = defaults.array(forKey: "TodoListArray") as? [Item]{
 //           itemArray = items
 //        }
     }
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return itemArray.count
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellItem", for: indexPath)
         cell.textLabel?.text = itemArray[indexPath.row].title
         if itemArray[indexPath.row].done == true{
             cell.accessoryType = .checkmark
         }
         else{
             cell.accessoryType = .none
         }
         
         //this if-else can be rewritten using swift ternary operator
         //cell.accessoryType = item.done == true ? .checkmark : .none
             return cell
         }
     
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
         if itemArray[indexPath.row].done == false{
             itemArray[indexPath.row].done = true
         }
         else{
             itemArray[indexPath.row].done = false
         }
         
         saveItems()
         
         tableView.deselectRow(at: indexPath, animated: true)
         
     }
     
     @IBAction func addButtonPressed(_ sender: Any) {
         var textField = UITextField()
         let alert =  UIAlertController(title:"Add New Todoey Item", message:"",preferredStyle: .alert)
         let action = UIAlertAction(title:"Add Item",  style: .default){
             (action) in
             
             let newItem = Item()
             newItem.title = textField.text!
             self.itemArray.append(newItem)
         
             
             self.saveItems()
         }
         alert.addTextField {
             (alertTextField) in
             alertTextField.placeholder  = "Create new item"
             textField = alertTextField
         }
         alert.addAction(action)
         present(alert, animated: true, completion: nil)
     }
     
     func saveItems(){
         let encoder = PropertyListEncoder()
         do{
             let data = try encoder.encode(self.itemArray)
             try data.write(to:self.dataFilePath!)
         }catch{
             print(error)
         }
         
         self.tableView.reloadData()
     }
     
     func loadItems(){
         if let data = try? Data(contentsOf: dataFilePath!){
             let decoder = PropertyListDecoder()
             do{
                 itemArray = try decoder.decode([Item].self, from:data)
             } catch {
                 print(error)
             }
         }
         
     }

 }
 
 //we also had an items swift file that we deleted cuz core data does not need it
 //itemfile content
 
 import Foundation

 class Item: Encodable, Decodable {
     var title: String = ""
     var done: Bool = false
 }

 //we have to use encodable protocol because PropertyListEncoder  needs it


 */



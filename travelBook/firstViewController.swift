//
//  firstViewController.swift
//  travelBook
//
//  Created by Doğukan Ahi on 13.07.2023.
//

import UIKit
import CoreData
class firstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var idArray = [UUID]()
    var titleArray = [String]()
    var choosenTitle = ""
    var choosenId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        tableView.delegate = self
                tableView.dataSource = self
        GetData()
    }
    override func viewWillAppear(_ animated: Bool) {
        GetData()
    }
    func GetData(){
        
        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = AppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                for result in results as! [NSManagedObject] {
        
                    if let title =  result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                        
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                        
                    }
                    tableView.reloadData()
                }
            
            }
        }catch{
            print("ERRORR!!!")
        }
    
    }
    @objc func addButtonClicked(){
        performSegue(withIdentifier: "2ndVC", sender: nil)
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenTitle = titleArray[indexPath.row]
        choosenId =  idArray[indexPath.row]
        performSegue(withIdentifier: "2ndVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "2ndVC" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = choosenTitle
            destinationVC.selectedTitleID = choosenId
    }
        
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@",idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                titleArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                tableView.reloadData()
                                do {
                                    try context.save()
                                }catch {
                                    print("cannot save after delete proccess")
                                }
                                
                                break
                            }
                        }
                    }
                }
            } catch{
                print("delete errorr!")
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }

}

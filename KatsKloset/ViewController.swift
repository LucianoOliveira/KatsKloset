//
//  ViewController.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 03/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items : [Clothes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Configure tableview
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        //get the data from core data
        getData()
        
        //refresh the tableview
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TableViewCell1", owner: self, options: nil)?.first as! TableViewCell1
        
        let item = items[indexPath.row]
        
        cell.descriptionCell.text = item.desc
        cell.colorCell.text = item.color
        cell.ownerCell.text = item.owner
        //cell.imageCell.image = something
        if item.photoFullURL == nil {
            cell.imageCell.image = #imageLiteral(resourceName: "no_image_available_10")
        }
        else{
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDir: NSString = paths.object(at: 0) as! NSString
            
            let path: NSString = documentsDir.appending(item.photoFullURL!) as NSString
            cell.imageCell.image = UIImage(contentsOfFile: path as String)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func getData(){
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fill array items with all the items in core data
        do {
            try items = context.fetch(Clothes.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let item = items[indexPath.row]
            
            //delete image
            if item.photoFullURL != nil {
                let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
                let documentsDir: NSString = paths.object(at: 0) as! NSString
                
                //Delete the photo
                let fileManager: FileManager = FileManager.default
                do {
                    try fileManager.removeItem(atPath: documentsDir.appending(item.photoFullURL!))
                } catch  {
                    print("Error while deleting image")
                }
                
            }
            
            //delete from core data
            context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            
            
            //reload the data
            do {
                try items = context.fetch(Clothes.fetchRequest())
            } catch  {
                print("Error while catching from CoreData")
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showEditScreen", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showEditScreen"){
            let controller : EditViewController = segue.destination as! EditViewController
            let indexPath : NSIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            var results: [Clothes] = []
            do {
                try results = context.fetch(Clothes.fetchRequest())
            } catch  {
                print("Error while catching from CoreData")
            }
            
            //get Data from cell
            let userData: Clothes = results[indexPath.row] as Clothes
            
            //Pass the data
            controller.items = [userData]
        }
    }


}


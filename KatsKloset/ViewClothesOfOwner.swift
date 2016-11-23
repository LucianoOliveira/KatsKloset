//
//  ViewClothesOfOwner.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 22/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class ViewClothesOfOwner: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    //Values to be passed from segue
    var owner: String = ""
    var season: String = ""
    var typeOfCloth: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleNavItem: UINavigationItem!
    
    var items : [Clothes] = []
    var itemsToDisplay : [Clothes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Configure tableview
        tableView.dataSource = self
        tableView.delegate = self
        
        //get the data from core data
        getData()
        
        //refresh the tableview
        tableView.reloadData()
        
        //Title NavItem
        if season != "" {
            titleNavItem.title = season
        }
        else{
            if typeOfCloth != ""
            {
                titleNavItem.title = typeOfCloth
            }
        }
        
    }


    override func viewWillAppear(_ animated: Bool) {
        //get the data from core data
        getData()
        
        //refresh the tableview
        tableView.reloadData()
        
        //Title NavItem
        if season != "" {
            titleNavItem.title = season
        }
        else{
            if typeOfCloth != ""
            {
                titleNavItem.title = typeOfCloth
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("StandardTableViewCell", owner: self, options: nil)?.first as! StandardTableViewCell
        
        let item = itemsToDisplay[indexPath.row]
        
        //cell.titleCell.text = item.desc
        cell.titleCell.text = item.desc
        cell.subtitle1Cell.text = item.color
        cell.subtitle2Cell.text = ""
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
        return 50
    }
    
    func getData(){
        itemsToDisplay.removeAll()
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fill array items with all the items in core data
        do {
            try items = context.fetch(Clothes.fetchRequest())
            for item in items {
                if owner == ""
                {
                    //Accepts every owner
                    if season == ""
                    {
                        //Accepts every season
                        if typeOfCloth == ""
                        {
                            //Accepts every type
                            itemsToDisplay.append(item)
                        }
                        else
                        {
                            //Only accepts this type
                            if typeOfCloth == item.tipo
                            {
                                itemsToDisplay.append(item)
                            }
                        }
                        
                    }
                    else
                    {
                        //Only accepts this season
                        if season == item.season
                        {
                            if typeOfCloth == ""
                            {
                                //Accepts every type
                                itemsToDisplay.append(item)
                            }
                            else
                            {
                                //Only accepts this type
                                if typeOfCloth == item.tipo
                                {
                                    itemsToDisplay.append(item)
                                }
                            }
                        }
                        
                    }
                }
                else
                {
                    //Only accepts this owner
                    if owner == item.owner
                    {
                        if season == ""
                        {
                            //Accepts every season
                            if typeOfCloth == ""
                            {
                                //Accepts every type
                                itemsToDisplay.append(item)
                            }
                            else
                            {
                                //Only accepts this type
                                if typeOfCloth == item.tipo
                                {
                                    itemsToDisplay.append(item)
                                }
                            }

                        }
                        else{
                            //Only accepts this season
                            if season == item.season
                            {
                                if typeOfCloth == ""
                                {
                                    //Accepts every type
                                    itemsToDisplay.append(item)
                                }
                                else
                                {
                                    //Only accepts this type
                                    if typeOfCloth == item.tipo
                                    {
                                        itemsToDisplay.append(item)
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        } catch  {
            print("Error while catching from CoreData")
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let item = itemsToDisplay[indexPath.row]
            
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
            getData()
            tableView.reloadData()
        }
    }
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showCreateItem"){
            let controller : AddItemViewController = segue.destination as! AddItemViewController

            controller.transOwner=owner
            controller.transSeason=season
            controller.transType=typeOfCloth
            
            
        }
        if (segue.identifier == "showEditItem"){
            let controller : EditViewController = segue.destination as! EditViewController
            let indexPath : NSIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            
            //get Data from cell
            let userData: Clothes = itemsToDisplay[indexPath.row] as Clothes
            
            //Pass the data
            controller.items = [userData]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showEditItem", sender: tableView.cellForRow(at: indexPath))
    }
    
    


    
}

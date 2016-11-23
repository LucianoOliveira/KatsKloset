//
//  ViewWardrobeOwners.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 21/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class ViewWardrobeOwners: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var items: [Owners] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let cell = Bundle.main.loadNibNamed("StandardTableViewCell", owner: self, options: nil)?.first as! StandardTableViewCell
        
        let item = items[indexPath.row]
        
        //Having the owner name I want to know how many pieces they have
        var clothes: [Clothes]=[]
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //fill array items with all the items in core data
        do {
            try clothes = context.fetch(Clothes.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        
        var pieces = 0
        for cl1 in clothes {
            if cl1.owner == item.ownerName {
                pieces = pieces + 1
            }
        }

        cell.titleCell.text = item.ownerName
        if pieces > 1 {
            cell.subtitle1Cell.text = String(pieces)+" Peças"
        }
        else{
            if pieces == 1 {
                cell.subtitle1Cell.text = String(pieces)+" Peça"
            }
            else{
               cell.subtitle1Cell.text = "Não tem peças"
            }
            
        }
        
        cell.subtitle2Cell.text = ""
        if item.ownerPhotoFullURL == nil {
            cell.imageCell.image = #imageLiteral(resourceName: "no_image_available_10")
        }
        else{
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDir: NSString = paths.object(at: 0) as! NSString
            
            let path: NSString = documentsDir.appending(item.ownerPhotoFullURL!) as NSString
            cell.imageCell.image = UIImage(contentsOfFile: path as String)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func getData(){
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fill array items with all the items in core data
        do {
            try items = context.fetch(Owners.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showWardrobeByOwner", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showWardrobeByOwner"){
            let controller : ViewWardrobeByOwner = segue.destination as! ViewWardrobeByOwner
            let indexPath : NSIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            var results: [Owners] = []
            do {
                try results = context.fetch(Owners.fetchRequest())
            } catch  {
                print("Error while catching from CoreData")
            }
            
            //get Data from cell
            let userData: Owners = results[indexPath.row] as Owners
            
            //Pass the data
            controller.items = [userData]
        }
    }
 
    

}

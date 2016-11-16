//
//  ViewControllerSeasons.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 16/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class ViewControllerSeasons: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var items : [Seasons] = []
    
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
        
        //cell.titleCell.text = item.desc
        cell.titleCell.text = item.nameOfSeason
        cell.subtitle1Cell.text = nil
        cell.subtitle2Cell.text = nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let item = items[indexPath.row]
            
            //delete from core data
            context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //reload the data
            do {
                try items = context.fetch(Seasons.fetchRequest())
            } catch  {
                print("Error while catching from CoreData")
            }
            tableView.reloadData()
        }
    }
    
    func getData(){
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fill array items with all the items in core data
        do {
            try items = context.fetch(Seasons.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        
    }

}

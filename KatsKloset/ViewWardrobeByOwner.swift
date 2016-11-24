//
//  ViewWardrobeByOwner.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 21/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class ViewWardrobeByOwner: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleNavItem: UINavigationItem!
    
    struct ObjectsInSection {
        var description: String!
        var numberOfElements: Int!
    }
    
    struct Objects {
        var sectionName: String!
        var sectionObject: [ObjectsInSection]!
    }
    var objectsArray = [Objects]()

    
    var items : [Owners] = []
    
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
        
        //Title navitem
        titleNavItem.title = items[0].ownerName!
    }
    
    func getData() {
        //get Owner
        let currentOwner = items[0].ownerName
        
        //Get Number of Clothes by Season
        var objInSec = [ObjectsInSection]()
        objectsArray.removeAll()
        
        
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fill array seasons with all the Seasons in core data
        //Get seasons
        var seasons: [Seasons]=[]
        do {
            try seasons = context.fetch(Seasons.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        //fill array clothes with all the Clothes in core data
        var clothes: [Clothes]=[]
        do {
            try clothes = context.fetch(Clothes.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }

        
        //Fill Array with Seasons
        for season in seasons {
            var numOfElem=0
            for cloth in clothes {
                if (cloth.owner == currentOwner && season.nameOfSeason == cloth.season) {
                    numOfElem = numOfElem + 1
                }
            }
            objInSec.append(ObjectsInSection(description: season.nameOfSeason, numberOfElements: numOfElem))
        }
        objectsArray.append(Objects(sectionName: "Estações", sectionObject: objInSec))
        objInSec.removeAll()
        

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("StandardTableViewCell", owner: self, options: nil)?.first as! StandardTableViewCell
        
        cell.titleCell.text = objectsArray[indexPath.section].sectionObject[indexPath.row].description
        cell.subtitle1Cell.text = String(objectsArray[indexPath.section].sectionObject[indexPath.row].numberOfElements)
        cell.subtitle2Cell.text="Peças"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray[section].sectionObject.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return objectsArray.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return objectsArray[section].sectionName
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showClothesOfOwner", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showClothesOfOwner"){
            let controller : ViewClothesOfSeason = segue.destination as! ViewClothesOfSeason
            let indexPath : NSIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            
            controller.owner=""
            controller.season=""
            controller.typeOfCloth=""
            controller.sectionName=""
            
            controller.owner=items[0].ownerName!
            if objectsArray[indexPath.section].sectionName == "Estações" {
                controller.season=objectsArray[indexPath.section].sectionObject[indexPath.row].description
            }
            else{
                if objectsArray[indexPath.section].sectionName == "Tipos de Peça" {
                    controller.typeOfCloth=objectsArray[indexPath.section].sectionObject[indexPath.row].description
                }
            }
            controller.sectionName=objectsArray[indexPath.section].sectionName
            
        }
    }


}

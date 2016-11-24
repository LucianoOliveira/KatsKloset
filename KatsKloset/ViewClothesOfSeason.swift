//
//  ViewClothesOfSeason.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 24/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class ViewClothesOfSeason: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Values to be passed from segue
    var owner: String = ""
    var season: String = ""
    var typeOfCloth: String = ""
    var sectionName: String = ""
    
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
        titleNavItem.title = owner + " - " + season
        
    }
    
    func getData() {
        //get Owner
        let currentOwner = owner
        
        //Get Number of Clothes by Season
        var objInSec = [ObjectsInSection]()
        objectsArray.removeAll()
        
        
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fill array clothes with all the Clothes in core data
        var clothes: [Clothes]=[]
        do {
            try clothes = context.fetch(Clothes.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        //fill array clothes with all the Clothes in core data
        var typesOfClothes: [TypesOfClothes]=[]
        do {
            try typesOfClothes = context.fetch(TypesOfClothes.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        
        
   
         //Fill Array with Types of Clothes
         for typeOfCloth in typesOfClothes {
            var numOfElem=0
            for cloth in clothes {
                if (cloth.owner == currentOwner && typeOfCloth.nameOfType == cloth.tipo) {
                    numOfElem = numOfElem + 1
                }
            }
            objInSec.append(ObjectsInSection(description: typeOfCloth.nameOfType, numberOfElements: numOfElem))
         }
         objectsArray.append(Objects(sectionName: "Tipos de Peça", sectionObject: objInSec))
        
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
        self.performSegue(withIdentifier: "showClothesOfOwnerBySeason", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showClothesOfOwnerBySeason"){
            let controller : ViewClothesOfOwner = segue.destination as! ViewClothesOfOwner
            let indexPath : NSIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            
            controller.owner=""
            controller.season=""
            controller.typeOfCloth=""
            controller.sectionName=""
            
            controller.owner=owner
            controller.season = season
  
            controller.typeOfCloth=objectsArray[indexPath.section].sectionObject[indexPath.row].description   
            controller.sectionName=objectsArray[indexPath.section].sectionName
            
        }
        if (segue.identifier == "showCreateItemInSeason"){
            let controller : AddItemViewController = segue.destination as! AddItemViewController
            
            controller.transOwner = owner
            controller.transSeason = season
            controller.transType = ""
            
            
        }
    }

    
}

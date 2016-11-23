//
//  ViewAllController.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 19/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class ViewAllController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var filterSectionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    struct Objects {
        
        var sectionName: String!
        var sectionObject: [Clothes]!
    }
    
    var objectsArray = [Objects]()
    var items : [Clothes] = []
    var sectionOrgarinzer : String = "Seasons"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Configure tableview
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get the data from core data
        getData(typeOfSection: sectionOrgarinzer)
        
        //refresh the tableview
        tableView.reloadData()
    }
    
    @IBAction func filterButton(_ sender: Any) {
        
        switch sectionOrgarinzer {

        case "Seasons":
            sectionOrgarinzer = "Owners"
            filterSectionLabel.text = "Donos"
        case "Owners":
            sectionOrgarinzer = "TypesOfClothes"
            filterSectionLabel.text = "Tipo de Peça"
        case "TypesOfClothes":
            sectionOrgarinzer = "Seasons"
            filterSectionLabel.text = "Estação"
        default:
            sectionOrgarinzer = "Seasons"
            filterSectionLabel.text = "Estação"
        }
        //get the data from core data
        getData(typeOfSection: sectionOrgarinzer)
        
        //refresh the tableview
        tableView.reloadData()
    }
    
    func getData(typeOfSection: String) {
        
        //delete objectsArray
        objectsArray.removeAll()
        
        
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fill array items with all the items in core data
        do {
            try items = context.fetch(Clothes.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        
        
        
        if typeOfSection == "Seasons" {
            var seasons : [Seasons]=[]
            do {
                try seasons = context.fetch(Seasons.fetchRequest())
            } catch  {
                print("Error while catching from CoreData")
            }
            
            var selectedItems: [Clothes]=[]
            for season in seasons
            {
                for item in items
                {
                    if item.season == season.nameOfSeason
                    {
                        selectedItems.append(item)
                    }
                }
                if selectedItems.count>0
                {
                    objectsArray.append(Objects(sectionName: season.nameOfSeason, sectionObject: selectedItems))
                    selectedItems.removeAll()
                }
            }
        }
        
        if typeOfSection == "Owners" {
            var owners : [Owners]=[]
            do {
                try owners = context.fetch(Owners.fetchRequest())
            } catch  {
                print("Error while catching from CoreData")
            }
            
            var selectedItems: [Clothes]=[]
            for owner in owners
            {
                for item in items
                {
                    if item.owner == owner.ownerName
                    {
                        selectedItems.append(item)
                    }
                }
                if selectedItems.count>0
                {
                    objectsArray.append(Objects(sectionName: owner.ownerName, sectionObject: selectedItems))
                    selectedItems.removeAll()
                }
            }
        }
        
        if typeOfSection == "TypesOfClothes" {
            var typesOfClothes : [TypesOfClothes]=[]
            do {
                try typesOfClothes = context.fetch(TypesOfClothes.fetchRequest())
            } catch  {
                print("Error while catching from CoreData")
            }
            
            var selectedItems: [Clothes]=[]
            for typesOfClothe in typesOfClothes
            {
                for item in items
                {
                    if item.tipo == typesOfClothe.nameOfType
                    {
                        selectedItems.append(item)
                    }
                }
                if selectedItems.count>0
                {
                    objectsArray.append(Objects(sectionName: typesOfClothe.nameOfType, sectionObject: selectedItems))
                    selectedItems.removeAll()
                }
            }
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as UITableViewCell!
        
        cell?.textLabel?.text = objectsArray[indexPath.section].sectionObject[indexPath.row].desc
        return cell!
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

}

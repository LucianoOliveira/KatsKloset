//
//  AddSeasonViewController.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 16/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class AddSeasonViewController: UIViewController {

    @IBOutlet weak var seasonText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Dismiss keyboard when tapped outsinde the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveItem(_ sender: Any) {
        
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //Create new object of type entity in the core data
        let item = Seasons(context: context)
        //fill every atribute of the new object
        item.nameOfSeason = seasonText.text!
        
        //save new data object in core data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        //After saving data return to previous screen
        navigationController!.popViewController(animated: true)

        
    }

    

}

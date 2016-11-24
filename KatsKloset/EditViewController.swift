//
//  EditViewController.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 07/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var descText: UITextField!
    @IBOutlet weak var ownerText: UITextField!
    @IBOutlet weak var colorText: UITextField!
    @IBOutlet weak var sizeText: UITextField!
    @IBOutlet weak var seasonText: UITextField!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var typeText: UITextField!
    
    var photoFullURL: String!
    var pickerOwner = UIPickerView()
    var pickerSeason = UIPickerView()
    var pickerType = UIPickerView()
    var items : [Clothes] = []
    
    //PickerView Owners
    var owners : [Owners] = []
    //PickerView Seasons
    var seasons: [Seasons] = []
    //PickerView Type
    var typeOfClothes : [TypesOfClothes] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Pickers
        pickerOwner.delegate=self
        pickerOwner.dataSource=self
        pickerOwner.tag=0
        pickerSeason.delegate=self
        pickerSeason.dataSource=self
        pickerSeason.tag=1
        pickerType.delegate=self
        pickerType.dataSource=self
        pickerType.tag=2
        
        //Connect PickerView to TextField
        ownerText.inputView = pickerOwner
        seasonText.inputView = pickerSeason
        typeText.inputView = pickerType
        
        //get the data from core data
        getData()
        
        
        // Dismiss keyboard when tapped outsinde the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.photoFullURL=nil
        
        
        // Do any additional setup after loading the view.
        descText.text = items[0].desc
        ownerText.text = items[0].owner
        colorText.text = items[0].color
        sizeText.text = items[0].size
        seasonText.text = items[0].season
        typeText.text = items[0].tipo
        if items[0].photoFullURL == nil {
            showImage.image = #imageLiteral(resourceName: "no_image_available_10")
            let URL = NSURL(fileURLWithPath: "no_image_available_10").absoluteString!
            self.photoFullURL = URL
        }
        else{
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDir: NSString = paths.object(at: 0) as! NSString
            
            let path: NSString = documentsDir.appending(items[0].photoFullURL!) as NSString
            showImage.image = UIImage(contentsOfFile: path as String)
            self.photoFullURL=items[0].photoFullURL
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showImage.layer.cornerRadius = showImage.frame.size.width/2
        showImage.clipsToBounds = true
    }

   
    @IBAction func saveItem(_ sender: Any) {
        
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //First delete previous record
        let itemToDelete = items[0]
        //delete from core data
        context.delete(itemToDelete)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        
        //Create new object of type entity in the core data
        let item = Clothes(context: context)
        //fill every atribute of the new object
        item.desc = descText.text!
        item.owner = ownerText.text!
        item.color = colorText.text!
        item.size = sizeText.text!
        item.season = seasonText.text!
        item.tipo = typeText.text!
        if (self.photoFullURL==nil) {
            let URL = NSURL(fileURLWithPath: "no_image_available_10").absoluteString!
            item.photoFullURL = URL
        }
        else{
            item.photoFullURL = self.photoFullURL
        }
        
        //save new data object in core data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        self.photoFullURL=nil

        
        //After saving data return to previous screen
        navigationController!.popViewController(animated: true)
    }

    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func addPhotoBtn(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    
    //UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let newImage: UIImage = scaleImageWithImage(image: image, size: CGSize(width: 250, height: 250))
        
        self.showImage.image = newImage
        
        
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDir: NSString = paths.object(at: 0) as! NSString
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let now: Date = Date(timeIntervalSinceNow: 0)
        let theDate: NSString = dateFormat.string(from: now) as NSString
        
        //Set URL for the photo
        self.photoFullURL = NSString(format: "/%@.png", theDate) as String!
        items[0].photoFullURL=self.photoFullURL
        
        //Save the image
        let pathFull: NSString = documentsDir.appending(self.photoFullURL) as NSString
        let pngFullData: NSData = UIImagePNGRepresentation(newImage) as NSData!
        pngFullData.write(toFile: pathFull as String, atomically: true)
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //Scale Photos
    func scaleImageWithImage(image: UIImage, size: CGSize)->UIImage{
        let scale: CGFloat = max(size.width/image.size.width, size.height/image.size.height)
        let width: CGFloat = image.size.width * scale
        let heigth: CGFloat = image.size.height * scale
        let imageRect: CGRect = CGRect(x: (size.width-width)/2.0, y: (size.height-heigth)/2.0, width: width, height: heigth)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: imageRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
    
    //PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag==0{
            return owners.count
        }
        if pickerView.tag==1{
            return seasons.count
        }
        if pickerView.tag==2{
            return typeOfClothes.count
        }
        
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag==0{
            ownerText.text = owners[row].ownerName
        }
        if pickerView.tag==1{
            seasonText.text = seasons[row].nameOfSeason
        }
        if pickerView.tag==2{
            typeText.text = typeOfClothes[row].nameOfType
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag==0{
            return owners[row].ownerName
        }
        if pickerView.tag==1{
            return seasons[row].nameOfSeason
        }
        if pickerView.tag==2{
            return typeOfClothes[row].nameOfType
        }
        return ""
    }
    
    
    
    
    //Load data for picker views
    func getData(){
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fill array owners
        do {
            try owners = context.fetch(Owners.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        //fill array seasons
        do {
            try seasons = context.fetch(Seasons.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        //fill array seasons
        do {
            try typeOfClothes = context.fetch(TypesOfClothes.fetchRequest())
        } catch  {
            print("Error while catching from CoreData")
        }
        
    }

    @IBAction func btnCameraPressed(_ sender: Any) {
    }

    
}

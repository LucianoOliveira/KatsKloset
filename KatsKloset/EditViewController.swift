//
//  EditViewController.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 07/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var descText: UITextField!
    @IBOutlet weak var ownerText: UITextField!
    @IBOutlet weak var colorText: UITextField!
    @IBOutlet weak var sizeText: UITextField!
    @IBOutlet weak var seasonText: UITextField!
    @IBOutlet weak var showImage: UIImageView!
    
    var photoFullURL: String!

    var items : [Clothes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

    
}

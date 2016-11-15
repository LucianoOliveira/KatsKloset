//
//  AddOwnerViewController.swift
//  KatsKloset
//
//  Created by Luciano Oliveira on 14/11/2016.
//  Copyright © 2016 Luciano Oliveira. All rights reserved.
//

import UIKit

class AddOwnerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var sexSwitch: UISegmentedControl!
    @IBOutlet weak var ownerImage: UIImageView!
    
    var ownerPhotoFullURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.ownerPhotoFullURL=nil
        
        // Dismiss keyboard when tapped outsinde the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.ownerPhotoFullURL==nil) {
            ownerImage.image = #imageLiteral(resourceName: "no_image_available_10")
        }
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

    @IBAction func addPhoto(_ sender: Any) {
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
        
        self.ownerImage.image = newImage
        
        
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDir: NSString = paths.object(at: 0) as! NSString
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let now: Date = Date(timeIntervalSinceNow: 0)
        let theDate: NSString = dateFormat.string(from: now) as NSString
        
        //Set URL for the photo
        self.ownerPhotoFullURL = NSString(format: "/%@.png", theDate) as String!
        
        //Save the image
        let pathFull: NSString = documentsDir.appending(self.ownerPhotoFullURL) as NSString
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

    @IBAction func saveOwner(_ sender: Any) {
        
        //Get context of core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //Create new object of type entity in the core data
        let item = Owners(context: context)
        //fill every atribute of the new object
        item.ownerName = nameText.text!
        item.ownerAge = Int16(ageText.text!)!
        
        switch sexSwitch.selectedSegmentIndex {
        case 0:
            item.ownerSex="Masculino"
        case 1:
            item.ownerSex="Feminino"
        default:
            item.ownerSex=""
        }
        if (self.ownerPhotoFullURL==nil) {
            let URL = NSURL(fileURLWithPath: "no_image_available_10").absoluteString!
            item.ownerPhotoFullURL = URL
        }
        else{
            item.ownerPhotoFullURL = self.ownerPhotoFullURL
        }
        
        //save new data object in core data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        self.ownerPhotoFullURL=nil
        
        //After saving data return to previous screen
        navigationController!.popViewController(animated: true)
    }

}

//
//  ViewController.swift
//  FirebaseTask
//
//  Created by Infiquity on 29/12/22.
//

import UIKit
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var uploadImg: UIImageView!
    
    private let storageref = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String, let url = URL(string: urlString) else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data,error == nil else{ return}
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.uploadImg.image = image
            }
        })
        task.resume()
    }
    
    @IBAction func uploadImgBtnAct(_ sender: Any) {
        let imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        imagepicker.sourceType = .photoLibrary
        imagepicker.allowsEditing = true
        
        present(imagepicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        guard let imageData = image.pngData() else { return }
        storageref.child("images/file.png").putData(imageData, metadata: nil, completion:{
            _ , error in
            
            guard error == nil else {
                print("Failed to upload")
                return}
            self.storageref.child("images/file.png").downloadURL(completion: {url, error in
                guard let url = url,error == nil else{ return}
                let urlString = url.absoluteString
                DispatchQueue.main.async {
                    self.uploadImg.image = image
                }
                print("Download Url",urlString )
                UserDefaults.standard.set(urlString, forKey: "url")
            })
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}



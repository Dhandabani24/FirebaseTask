//
//  DbImagesViewController.swift
//  FirebaseTask
//
//  Created by Infiquity on 02/01/23.
//

import UIKit
import FirebaseStorage

class DbImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    
    var folderList: [StorageReference]?
    private let storage = Storage.storage().reference()
    var storageRef : StorageReference?
    var urlString = String()
    var foldName = String()  // get folder name from previous VC
    
    @IBOutlet weak var imageCollectView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = foldName.capitalized
        imageCollectView.delegate = self
        imageCollectView.dataSource = self
        self.initialSetUp()
    }
    
    func initialSetUp(){
        // step 1:- list out all image from Firebase Db
        self.storage.child(foldName + "/").listAll(completion: {
            (result,error) in
            guard let result = result,error == nil else{ return}
            print("result is \(result)")
            self.folderList = result.items
            print (self.folderList as Any)
            DispatchQueue.main.async {
                self.imageCollectView.reloadData()
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CollectCell", for: indexPath) as! ImageCollectionViewCell
        
        //step 2:- Download all imageUrl from Firebase DB
        self.storageRef = self.folderList?[indexPath.row]
        storageRef?.downloadURL(completion: { [self](downloadURL,error) in
            guard let downloadURL = downloadURL,error == nil else{ return}
            print("url is \(downloadURL)")
            self.urlString = downloadURL.absoluteString
            
        //step 3:- get only image name from Firebase DB
            let gsReference = Storage.storage().reference(forURL: self.urlString)
            print("image name ------>",gsReference.name)  // image name.jpeg format
            let str = gsReference.name
            let textString = str.components(separatedBy: ".")[0]  // get image name only.
            let url = URL(string: urlString)       // change image url to data
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { data, _, error in
                guard let data = data,error == nil else{ return}
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    cell.dbImages.image = image
                    cell.vehicleNameLbl.text = textString
                
                }
            })
            task.resume()
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 140)
    }
    
    deinit{
        print("called deinitialization")
    }
    
}



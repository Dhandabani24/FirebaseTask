//
//  ImgFolderViewController.swift
//  FirebaseTask
//
//  Created by Infiquity on 02/01/23.
//

import UIKit
import FirebaseStorage

class ImgFolderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var imgFolderTblView: UITableView!
    var folderList = [String]()
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Image Folders Name"
        imgFolderTblView.delegate = self
        imgFolderTblView.dataSource = self
        self.initialSetupCall()
    }
    
    func initialSetupCall(){
        // step 1:- list out all imagefolder from Firebase Db
        self.storage.listAll { (result, error) in
            guard let result = result,error == nil else{ return}
            print("foldername is \(result)")
            for prefix in result.prefixes {
                print("---->",prefix.name)  // get image folder list
                self.folderList.append(prefix.name)
                print("foldername--->",self.folderList)
                DispatchQueue.main.async {
                    self.imgFolderTblView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.folderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.textLabel?.text = self.folderList[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DbImagesViewController") as! DbImagesViewController
        vc.foldName = self.folderList[indexPath.row] // folder name pass to nxt VC
        self.navigationController?.pushViewController(vc, animated: true)
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//            if editingStyle == .delete {
//                self.folderList.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//        }
}


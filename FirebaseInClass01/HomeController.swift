//
//  HomeController.swift
//  FirebaseInClass01
//
//  Created by Kabra, Sunidhi on 11/12/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var ref: DatabaseReference!,
    posts = [eventStruct]()
    var a = Auth.auth().currentUser!.uid
    
    struct eventStruct {
        let notebookName: String!
        let createdAt: String!
    }
    
    @IBOutlet weak var tableForData: UITableView!
    var selectedRowCreatedAt: String = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let notebookName = cell.viewWithTag(1) as! UILabel
        notebookName.text = posts[indexPath.row].notebookName
        
        let createdAt = cell.viewWithTag(2) as! UILabel
        createdAt.text = String(convertDateFormatter(date: (posts[indexPath.row].createdAt)!))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowCreatedAt = posts[indexPath.row].createdAt!
        print("selected row = \(selectedRowCreatedAt)")
        
        self.performSegue(withIdentifier: "goToNotesSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNotesSegue"{
            let vc1 = segue.destination as! NotesController
            vc1.createdAt = self.selectedRowCreatedAt
        }
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        ref = Database.database().reference()
        ref.child(Auth.auth().currentUser!.uid).queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            var value = snapshot.value as? NSDictionary
//                print("value = \(value!)")
            
                let notebookName = value!["notebookName"]
                print("notebookName = \(notebookName!)")
            
                let createdAt = value!["createdAt"]
                print("createdAt = \(createdAt!)")
            
                self.posts.insert(eventStruct(notebookName: notebookName as! String, createdAt: createdAt as! String), at: 0)
            
                self.tableForData.reloadData()

        })
               
    }
    
    func convertDateFormatter(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        dateFormatter.locale = Locale(identifier: "your_loc_id")
        let convertedDate = dateFormatter.date(from: date)
        
        guard dateFormatter.date(from: date) != nil else {
            assert(false, "no date from string")
            return ""
        }
        
        dateFormatter.dateFormat = "yyyy MMM HH:mm EEEE"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let timeStamp = dateFormatter.string(from: convertedDate!)
        
        return timeStamp
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func onClickLogoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    @IBAction func onClickAddButton(_ sender: Any) {
        let alert = UIAlertController(title: "New Notebook", message: "Enter Notebook Name", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Notebook name"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text {
                self.ref = Database.database().reference()
                
                let z1 = self.generateCurrentTimeStamp()
            self.ref.child(Auth.auth().currentUser!.uid).child(z1).setValue(["notebookName": name, "createdAt": z1])
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func generateCurrentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
}

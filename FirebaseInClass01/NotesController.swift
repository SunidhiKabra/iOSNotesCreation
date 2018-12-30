//
//  NotesController.swift
//  FirebaseInClass01
//
//  Created by Kabra, Sunidhi on 11/13/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit
import Firebase

class NotesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var createdAt: String?
    var ref: DatabaseReference!,
    posts = [eventStruct]()
    
    @IBOutlet weak var tableForNotes: UITableView!
    @IBOutlet weak var backToNotebooksButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    struct eventStruct {
        let noteText: String!
        let createdAt: String!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let noteText = cell.viewWithTag(1) as! UILabel
        noteText.text = posts[indexPath.row].noteText
        
        let createdAt = cell.viewWithTag(2) as! UILabel
        createdAt.text = String(convertDateFormatter(date: (posts[indexPath.row].createdAt)!))
        
        return cell
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
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        loadData()
        
    }
    
    func loadData() {
        ref = Database.database().reference()
        ref.child(Auth.auth().currentUser!.uid).child(self.createdAt!).queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            if let valueDictionary = snapshot.value as? [AnyHashable:String]
            {
                let noteText = valueDictionary["noteText"]
                let createdAt = valueDictionary["createdAt"]
                self.posts.insert(eventStruct(noteText: noteText, createdAt: createdAt), at: 0)
                self.tableForNotes.reloadData()
            }
        })
        
    }
    
    @IBAction func onClickBackToNotebooksButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickAddButton(_ sender: Any) {
        let alert = UIAlertController(title: "New Note", message: "Enter New Post test", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Note text"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let text = alert.textFields?.first?.text {
                
                let z1 = self.generateCurrentTimeStamp()
                self.ref.child(Auth.auth().currentUser!.uid).child(self.createdAt!).child(z1).setValue(["noteText": text, "createdAt": z1])
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func generateCurrentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        return (formatter.string(from: Date()) as NSString) as String
    }

}

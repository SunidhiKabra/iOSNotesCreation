//
//  ViewController.swift
//  FirebaseInClass01
//
//  Created by Shehab, Mohamed on 11/9/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var createNewAccount: UIButton!
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "loginToHomeSegue", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onClickCreateNewAccount(_ sender: Any) {
                self.performSegue(withIdentifier: "goToSignUpSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSignUpSegue" {
            let vc = segue.destination as! SignUpController
        }
    }
    
    @IBAction func onClickLoginButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailLabel.text!, password: passwordLabel.text!) { (user, error) in
            if error == nil{
                self.performSegue(withIdentifier: "loginToHomeSegue", sender: self)
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}


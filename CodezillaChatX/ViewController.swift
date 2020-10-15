//
//  ViewController.swift
//  CodezillaChatX
//
//  Created by Osama on 12/12/18.
//  Copyright © 2018 Osama Gamal. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var formCollection: UICollectionView!
    var isRegisterScreen:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.formCollection.delegate = self
        self.formCollection.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "signCell", for: indexPath) as! SignFormCell
        if (indexPath.row == 0){
            cell.usernameContainer.isHidden = true
            cell.submitButton.setTitle("Login", for: .normal)
            cell.backButton.setTitle("Sign Up 👉🏼", for: .normal)
            cell.backButton.addTarget(self, action: #selector(switchToSignUp(_:)), for: .touchUpInside)
            
            cell.submitButton.addTarget(self, action: #selector(didPressSubmitSignIn(_:)), for: .touchUpInside)

            
        } else {
            cell.usernameContainer.isHidden = false
            cell.submitButton.setTitle("Sign up", for: .normal)
            cell.backButton.setTitle("👈🏼 Sign in", for: .normal)
            cell.backButton.addTarget(self, action: #selector(switchToSignIn(_:)), for: .touchUpInside)

            cell.submitButton.addTarget(self, action: #selector(didPressSubmitSignUp(_:)), for: .touchUpInside)

        }
        
       // cell.submitButton.addTarget(self, action: #selector(didPressSubmit(_:)), for: .touchUpInside)
        

        
        return cell

    }
    
    func displayError(text: String){
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didPressSubmitSignIn(_ sender: UIButton){
        let cell = self.formCollection.cellForItem(at: IndexPath(item: 0, section: 0)) as! SignFormCell
        guard let email = cell.emailTextField.text ,let password = cell.passwordTextfield.text else {
           // self.displayError(text: "One of the fields is empty")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if(error == nil){
                print("result \(result?.user)")
                self.dismiss(animated: true, completion: nil)
            } else {
                self.displayError(text: "Incorrect username or password")
            }
        }
        
    }
    
    @objc func didPressSubmitSignUp(_ sender: UIButton){
        //  let email =
        let cell = self.formCollection.cellForItem(at: IndexPath(item: 1, section: 0)) as! SignFormCell
        guard let username = cell.usernameTextField.text, let email = cell.emailTextField.text, let password = cell.passwordTextfield.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if(error == nil){
                guard let userId = result?.user.uid else {
                    return
                }
                let databaseRef = Database.database().reference()
                let users = databaseRef.child("users").child(userId)
                let data: [String: Any] = ["username": username, "email": email]
                users.setValue(data)
                self.dismiss(animated: true, completion: nil)
            } else {
                self.displayError(text: "Error signing up")
            }
        }
        
        
        
    }
    
    func validateFields() -> Bool{
        
        func isValidEmail(testStr:String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: testStr)
        }
        
        let indexPathx = self.isRegisterScreen ? IndexPath(row: 1, section: 0) : IndexPath(row: 0, section: 0)
        let cell = self.formCollection.cellForItem(at: indexPathx) as! SignFormCell
        
        
        if((cell.usernameTextField.text?.isEmpty)! && isRegisterScreen){
            
            return false
        } else if((cell.passwordTextfield.text?.isEmpty)!){
            
            return false
        } else if((cell.passwordTextfield.text?.count)! < 6){
            
            
            return false
        } else if((cell.emailTextField.text?.isEmpty)!){
            
            return false
        } else if(isValidEmail(testStr: cell.emailTextField.text!) == false){
            
            return false
        }
        
        return true
    }
    
    @objc func switchToSignUp(_ sender: UIButton){
        let indexPath = IndexPath(item: 1, section: 0)
        self.formCollection.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
        self.isRegisterScreen = true
        
    }
    
    @objc func switchToSignIn(_ sender: UIButton){
        let indexPath = IndexPath(item: 0, section: 0)
        self.formCollection.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
        self.isRegisterScreen = false
        
    }
    


    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  ViewController.swift
//  CodeZillaRealTime
//
//  Created by Walaa on 1/23/19.
//  Copyright © 2019 Osama Gamal. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
  
    
        // Do any additional setup after loading the view, typically from a nib.
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "formCell", for: indexPath) as! FormCell

        if(indexPath.row == 0) { // Sign In Cell
            cell.usernameContainer.isHidden = true
            cell.actionButton.setTitle("Login", for: .normal)
            cell.slideButton.setTitle("Sign Up 👉🏼", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToSignInCell(_:)), for: .touchUpInside)
            
            cell.actionButton.addTarget(self, action: #selector(didPressSignIn(_:)), for: .touchUpInside)

            
        } else if(indexPath.row == 1) { // Sign up cell
            cell.usernameContainer.isHidden = false
            cell.actionButton.setTitle("Sign Up", for: .normal)
            cell.slideButton.setTitle("👈🏼 Sign In", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToSignUpCell(_:)), for: .touchUpInside)
            
            cell.actionButton.addTarget(self, action: #selector(didPressSignUp(_:)), for: .touchUpInside)

        }
        return cell
    }
    
    @objc func didPressSignIn(_ sender: UIButton){
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.collectionView.cellForItem(at: indexPath) as! FormCell
        guard let emailAddress = cell.emailAddressField.text, let password = cell.passwordTextField.text else {
            return
        }
        
        if(emailAddress.isEmpty == true || password.isEmpty == true){
            self.displayError(errorText: "Please fill empty fields")
        } else {
            Auth.auth().signIn(withEmail: emailAddress, password: password) { (result, error) in
                if(error == nil){
                    print(result?.user)
                } else {
                    self.displayError(errorText: "Wrong username or password")
                }
            }
        }
    }
    

    
    func displayError(errorText: String){
        let alert = UIAlertController.init(title: "Error", message: errorText, preferredStyle: .alert)
        
        let dismissButton = UIAlertAction.init(title: "Dismiss", style: .default, handler: nil)
        
        alert.addAction(dismissButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didPressSignUp(_ sender: UIButton){
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = self.collectionView.cellForItem(at: indexPath) as! FormCell
        guard let emailAddress = cell.emailAddressField.text, let password = cell.passwordTextField.text else {
            return
        }
        
        
        Auth.auth().createUser(withEmail: emailAddress, password: password) { (result, error) in
            if(error == nil){
                guard let userId = result?.user.uid, let userName = cell.userNameTextField.text else {
                    return
                }
                
                let reference = Database.database().reference()
                let user = reference.child("users").child(userId)
                let dataArray:[String: Any] = ["username": userName]
                user.setValue(dataArray)
            }
        }
        
    }
    
    @objc func slideToSignInCell(_ sender: UIButton){
        let indexPath = IndexPath(row: 1, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    
    @objc func slideToSignUpCell(_ sender: UIButton){
        let indexPath = IndexPath(row: 0, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }


}


//
//  RoomViewController.swift
//  CodezillaChatX
//
//  Created by Osama on 12/13/18.
//  Copyright © 2018 Osama Gamal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var messagesTable: UITableView!
    var room:Room?
    var messages = [Message]()
    
    @IBOutlet weak var newMessageTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.roomNameLabel.text = self.room?.name
        self.navigationItem.title = self.room?.name

        

        self.messagesTable.delegate = self
        self.messagesTable.dataSource = self
        self.messagesTable.separatorStyle = .none
        self.messagesTable.allowsSelection = false
        observerMessages()
        // Do any additional setup after loading the view.
    }
    
    func observerMessages(){
        let messagesRef = Database.database().reference().child("rooms").child((self.room?.roomId)!).child("messages")
        
        messagesRef.observe(.childAdded) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                if let senderId = data["senderId"] as? String, let senderName = data["senderName"] as? String{
                    var message:Message?
                    
                    if let text = data["text"] as? String {
                        message = Message(senderId: senderId, messageText: text, senderUsername: senderName, imageLink: nil)
                    } else if let imageLink = data["imageLink"] as? String{
                        message = Message(senderId: senderId, messageText: nil, senderUsername: senderName, imageLink: imageLink)
                    }
                    
                    if message != nil {
                        
                        self.messages.append(message!)
                        self.messagesTable.reloadData()
                    }
                }
            }
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
     //   print("message \(indexPath.row) sender: \(message.senderUsername)")

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell2") as! ChatCell
        if(Auth.auth().currentUser?.uid == message.senderId){
            cell.setBubbleType(type: .outgoing)
        } else {
            cell.setBubbleType(type: .incoming)
        }
        cell.setBubbleDataForMessage(message: message)


       // cell.trailingConstraint.isActive = false
        // to avoid constraint error because we have width <= 150 .. i set pirority of width to 750
        
        /*
         1 - create text view with trailing - top - bottom only
         2 - create bubble view that will follow textview
         3 - add max width to uitextview step
         4 - explain that we will have more elements (like name)
            and we need to have a container for bubble view and textview
         5 - use vertical stackview, with constraints for full cell <>^v
         6 - spacing inside bubble text - try first with auto layout
             then explain why we will use uitextview's uiedgeinsets func
        */
        

        
        return cell
    }
    
    
    @IBAction func didPressSendMessage(_ sender: UIButton) {
        if let messageText = self.newMessageTextField.text{
            self.sendMessage(text: messageText, imageLink: nil)
        }
    }
    
    func sendMessage(text: String?, imageLink: String?){
        if let userId = Auth.auth().currentUser?.uid, let roomId = self.room?.roomId{
            
            let roomRef = Database.database().reference().child("rooms").child(roomId)
            let newMessageRef = roomRef.child("messages").childByAutoId()
            //   ServerValue.timestamp()
            let ref = Database.database().reference().child("users").child(userId).child("username")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                let userName = snapshot.value as! String
                if(text != nil){
                    let messageData:[String: Any] = ["senderId": userId, "senderName" : userName, "text": text!, "date":ServerValue.timestamp()]
                    newMessageRef.updateChildValues(messageData)
                } else if(imageLink != nil){
                    let messageData:[String: Any] = ["senderId": userId, "senderName" : userName, "imageLink": imageLink!, "date":ServerValue.timestamp()]
                    newMessageRef.updateChildValues(messageData)
                }
                
                self.newMessageTextField.text = ""
                self.newMessageTextField.resignFirstResponder()
            }
        }
    }
    
    
    @IBAction func didPressImagePickerButton(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
     //   print(info)
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = originalImage
        }
        
        if let myImage = selectedImage {
            self.uploadImageToFireBase(image: myImage)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func uploadImageToFireBase(image: UIImage){
        let storageRef = Storage.storage().reference().child("fileName.png")
        
        
        if let imageData = UIImageJPEGRepresentation(image, 1) {
            storageRef.putData(imageData, metadata: nil) { (metaData, error) in
                if(error == nil){
                    
                    storageRef.downloadURL(completion: { (url, nil) in
                        self.sendMessage(text: nil, imageLink: url?.absoluteString)
                    })

                } else {
                    print(error)
                }
            }

        }
        
        
        
    }
    
    @IBAction func didPressBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

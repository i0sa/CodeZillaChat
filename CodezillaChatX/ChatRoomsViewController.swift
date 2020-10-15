//
//  ChatRoomsViewController.swift
//  CodezillaChatX
//
//  Created by Osama on 12/13/18.
//  Copyright © 2018 Osama Gamal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var newRoomTextField: UITextField!
    @IBOutlet weak var chatRoomsTable: UITableView!
    
    var rooms = [Room]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.chatRoomsTable.delegate = self
        self.chatRoomsTable.dataSource = self
        
        self.observeRooms()
        // Do any additional setup after loading the view.
    }
    
    
    func observeRooms(){
        let roomsRef = Database.database().reference().child("rooms")
        roomsRef.observe(.childAdded) { (data) in
            let myData = data.value as! [String: Any]
            var modelData = Room(array: myData)
            modelData.roomId = data.key
            self.rooms.append(modelData)
            self.chatRoomsTable.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser == nil){
            let viewx = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") as! ViewController
            self.present(viewx, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = self.rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell")!
        cell.textLabel?.text = room.name
        return cell
    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if(indexPath.row == 9){
//            DispatchQueue.main.async {
//
//            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            }
//        }
//    }
//
    @IBAction func didPressCreateChatRoom(_ sender: UIButton) {
        guard let userId = Auth.auth().currentUser?.uid, let roomName = self.newRoomTextField.text, roomName.isEmpty == false else {
            return
        }
        self.newRoomTextField.resignFirstResponder()
        
        let databaseRef = Database.database().reference()
        let roomRef = databaseRef.child("rooms").childByAutoId()
        let roomData:[String: Any] = ["creatorId" : userId, "name": roomName]
        
        roomRef.setValue(roomData) { (err, ref) in
            if(err == nil){
                self.newRoomTextField.text = ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = self.rooms[indexPath.row]
        let chatView = self.storyboard?.instantiateViewController(withIdentifier: "RoomViewController") as! RoomViewController
        chatView.room = room
        self.navigationController?.pushViewController(chatView, animated: true)
    }
    
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        let viewx = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") as! ViewController
        
        self.present(viewx, animated: true, completion: nil)

    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
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

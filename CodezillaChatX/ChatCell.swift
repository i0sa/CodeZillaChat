//
//  ChatCell.swift
//  CodezillaChatX
//
//  Created by Osama on 12/13/18.
//  Copyright © 2018 Osama Gamal. All rights reserved.
//

import UIKit



class ChatCell: UITableViewCell {
    enum bubbleType {
        case incoming
        case outgoing
    }

    @IBOutlet weak var chatStack: UIStackView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textViewBubbleView: UIView!
    
    @IBOutlet weak var senderNameLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        self.textViewBubbleView.layer.cornerRadius = 7
        self.textView.textContainerInset = UIEdgeInsetsMake(10, 5, 10, 5)
        
      //  self.messageContainerView.layer.cornerRadius = 10
        // Initialization code
    }
    
    func setBubbleDataForMessage(message: Message){
        if(message.messageText != nil) {
            self.textView.text = message.messageText
        } else if(message.imageLink != nil){
        //    self.imageView.image =
        }
        
        self.senderNameLabel.text = message.senderUsername
    }

    func setBubbleType(type: bubbleType){
        if(type == .outgoing){
            print("incoming !")
            self.chatStack.alignment = .trailing
            self.textViewBubbleView.backgroundColor = #colorLiteral(red: 0.059805127, green: 0.2340934603, blue: 0.245598033, alpha: 1)
            self.textView.textColor = UIColor.white
            
        } else if(type == .incoming){
            self.chatStack.alignment = .leading
            self.textViewBubbleView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            self.textView.textColor = UIColor.black

        }
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

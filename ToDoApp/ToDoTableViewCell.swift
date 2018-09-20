//
//  ToDoTableViewCell.swift
//  ToDoApp
//
//  Created by Sneh on 18/09/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import UIKit

//Inorder to implement Completion feature of TodoItem, we will use Delegate technique...
//protocol TodoCellDelegate {
//    func didRequestDelete(_ cell:ToDoTableViewCell)
//    func didRequestComplete(_ cell:ToDoTableViewCell)
//    func didRequestShare(_ cell: ToDoTableViewCell)
//}

class ToDoTableViewCell: UITableViewCell {
    
//   var delegate: TodoCellDelegate?

    @IBOutlet weak var todoLabel: UILabel!
    
//    @IBAction func completeTodo(_ sender: Any) {
//        if let delegateObject = self.delegate{
//            delegateObject.didRequestComplete(self)
//        }
//    }
//
//
//    @IBAction func deleteTodo(_ sender: Any) {
//        if let delegateObject = self.delegate{
//            delegateObject.didRequestDelete(self)
//        }
//    }
//
//    @IBAction func shareTodo(_ sender: Any) {
//        if let delegateObject = self.delegate{
//            delegateObject.didRequestShare(self)
//        }
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.contentView.backgroundColor = UIColor.white
    }

}

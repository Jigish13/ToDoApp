//
//  ContainerViewController.swift
//  ToDoApp
//
//  Created by Sneh on 20/09/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    var todoViewController: ToDoTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TodoVC"{
            todoViewController = (segue.destination as! UINavigationController).childViewControllers.first as! ToDoTableViewController
        //Nowhere, u have establish connection between ContainerVC nd TodoTableVC, so we add actions to our 2 buttons in ContainerVC
        //nd it will fire actions in TodoTableVC...
            
            todoViewController.connectionButtonReference = connectionButton
        }
    }
    
    @IBAction func triggerConnection(_ sender: Any) {
        todoViewController.showConnectivityAction()
    }
    
    @IBAction func addNewTodoItem(_ sender: Any) {
        todoViewController.addNewTodo()
    }
    
}

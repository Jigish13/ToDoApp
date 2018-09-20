//
//  ToDoTableViewController.swift
//  ToDoApp
//
//  Created by Sneh on 18/09/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import UIKit
import MultipeerConnectivity

//class ToDoTableViewController: UITableViewController, TodoCellDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
class ToDoTableViewController: UITableViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var todoItems: [ToDoItem]!{
        didSet{
            progressBar.setProgress(progress, animated: true)
        }
    }
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!

    var connectionButtonReference: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var progress: Float{
        if todoItems.count > 0 {
            return Float(todoItems.filter{$0.completed}.count) / Float(todoItems.count)
        }
        else {
            return 0.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConnectivity()
        loadData()
    }
    
    func setupConnectivity(){
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    func loadData(){
        todoItems = [ToDoItem]()
        todoItems = DataManager.loadAll(ToDoItem.self).sorted(by: {
            $0.createdAt < $1.createdAt
        })
        tableView.reloadData()
        progressBar.setProgress(progress, animated: true)
    }
    
    func addNewTodo() {
        let addAlert = UIAlertController(title: "New Todo", message: "Enter a title", preferredStyle: .alert)
        addAlert.addTextField{ (textfield: UITextField) in
            textfield.placeholder = "ToDo Item Title"
        }
        addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler:
            { (action: UIAlertAction) in
                
                guard let title = addAlert.textFields?.first?.text else { return }
                
                let newTodo = ToDoItem(title: title, completed: false, createdAt: Date(), itemIdentifier: UUID())
                newTodo.saveItem()
                
                self.todoItems.append(newTodo)
                
                let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
                
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                //Control will go at cellForRowAt method...
        }))
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        self.present(addAlert,animated: true,completion: nil)
    }
    
    
    func showConnectivityAction() {
        //Here we can join a multipeer conectivity session or we can host a session
        let actionSheet = UIAlertController(title: "ToDo Exchange", message: "Do you want to host or join a session?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: {(action: UIAlertAction) in
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ba-td", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start() //ba-td means brian advent - ToDo
        }))
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: {(action: UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "ba-td", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser,animated: true,completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet,animated: true,completion: nil)
    }
    
//    func didRequestDelete(_ cell: ToDoTableViewCell) {
//        if let indexPath = tableView.indexPath(for: cell){
//            todoItems[indexPath.row].deleteItem()
//            todoItems.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
//    func didRequestComplete(_ cell: ToDoTableViewCell) {
//        if let indexPath = tableView.indexPath(for: cell){
//            var todoItem = todoItems[indexPath.row]
//            todoItem.markAsCompleted()
//            cell.todoLabel.attributedText = strikeThroughText(todoItem.title)
//        }
//    }
    
//    func didRequestShare(_ cell: ToDoTableViewCell) {
//        if let indexPath = tableView.indexPath(for: cell){
//            let todoItem = todoItems[indexPath.row]
//            sendTodo(todoItem)
//        }
//    }
    
    func completeTodoItem(_ indexPath: IndexPath){
            var todoItem = todoItems[indexPath.row]
            todoItem.markAsCompleted()
            //Now, todoItem which is completed is struct so inorder to avoid to reload data without touching table view we can make changes in array
            //of todoItems
            todoItems[indexPath.row] = todoItem
        
        if let cell = tableView.cellForRow(at: indexPath) as? ToDoTableViewCell{
             cell.todoLabel.attributedText = strikeThroughText(todoItem.title)
            
            UIView.animate(
                withDuration: 0.1,
                animations: {
                cell.transform = cell.transform.scaledBy(x: 1.5, y: 1.5)
                },
                completion: { (success) in
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.5,
                    options: .curveEaseOut,
                    animations: {
                    cell.transform = CGAffineTransform.identity
                    },
                    completion: nil)
            })
        }
    }
    
    func sendTodo(_ todoItem: ToDoItem){
        //Send todo if nd only if there is one connected peer or more
        if mcSession.connectedPeers.count > 0 {
            if let todoData = DataManager.loadData(todoItem.itemIdentifier.uuidString){
                do{
                    try mcSession.send(todoData, toPeers: mcSession.connectedPeers, with: .reliable)
                }catch{
                    fatalError("Could not send todo item")
                }
            }
        } else {
            //print("You are not connected to another devices")
            showConnectivityAction()
        }
    }
    
    func strikeThroughText(_ text: String) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ToDoTableViewCell
        //cell.delegate = self
        
        let todoItem = todoItems[indexPath.row]
        
        cell.todoLabel.text = todoItem.title
        //        cell.todoLabel.text = "Hello today is good day ! OK !! So wat is your task taday?"
        
        if todoItem.completed{
            cell.todoLabel.attributedText = strikeThroughText(todoItem.title)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .normal, title: "Share") {
            (action: UITableViewRowAction,indexPath: IndexPath) in
            let todoItem = self.todoItems[indexPath.row]
            self.sendTodo(todoItem)
        }
        shareAction.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete"){
            (action: UITableViewRowAction,indexPath: IndexPath) in
            self.todoItems[indexPath.row].deleteItem()
            self.todoItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        
        return [deleteAction,shareAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completeTodoItem(indexPath)
    }
    
    //MARK: - MC Delegate Functions
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
//            print("Connected: \(peerID.displayName)")
            
            DispatchQueue.main.async {
                self.connectionButtonReference.setTitle("Connected", for: .normal)
            }
            
        case MCSessionState.connecting:
//            print("Connected: \(peerID.displayName)")
            
            DispatchQueue.main.async {
                self.connectionButtonReference.setTitle("Connecting", for: .normal)
            }
            
        case MCSessionState.notConnected:
//            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.connectionButtonReference.setTitle("Offline", for: .normal)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do{
            let todoItem = try JSONDecoder().decode(ToDoItem.self, from: data)
            DataManager.save(todoItem, with: todoItem.itemIdentifier.uuidString)
            
            //Inorder to reload the tableView
            DispatchQueue.main.async {
                self.loadData()
            }
            
        } catch{
            fatalError("Unable to process the recieved data")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
}


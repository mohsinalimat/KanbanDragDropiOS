//
//  MainViewController.swift
//  DragAndDrop
//
//  Created by Alfian Losari on 1/5/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var data = [
        DataSource(title: "Todo", items: ["Database Migration", "Schema Design", "Storage Management", "Model Abstraction"]),
        DataSource(title: "In Progress", items: ["Push Notification", "Analytics", "Machine Learning"]),
        DataSource(title: "Done", items: ["System Architecture", "Alert & Debugging"])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        setupAddButtonItem()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func setupAddButtonItem() {
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListTapped(_:)))
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    func setupRemoveBarButtonItem() {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addInteraction(UIDropInteraction(delegate: self))
        let removeBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = removeBarButtonItem
    }

    @objc func addListTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Add List", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else {
                return
            }
            
            self.data.append(DataSource(title: text, items: []))
            
            let addedIndexPath = IndexPath(item: self.data.count - 1, section: 0)
            
            self.collectionView.insertItems(at: [addedIndexPath])
            self.collectionView.scrollToItem(at: addedIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ItemCollectionViewCell
        
        cell.setup(with: data[indexPath.item])
        cell.parentVC = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 225, height: view.bounds.height * 0.8)
    }
    
}

extension MainViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]) {
            session.loadObjects(ofClass: NSString.self) { (items) in
                guard let _ = items.first as? String else {
                    return
                }
                
                if let (dataSource, sourceIndexPath, tableView) = session.localDragSession?.localContext as? (DataSource, IndexPath, UITableView) {
                    dataSource.items.remove(at: sourceIndexPath.row)
                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                }
            }
        }
    }
}

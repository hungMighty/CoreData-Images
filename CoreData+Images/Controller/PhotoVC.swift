//
//  ViewController.swift
//  CoreDataTutorial
//
//  Created by James Rochabrun on 3/1/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import CoreData


class PhotoVC: UITableViewController {
    
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Photo.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "author", ascending: true)]
        
        var context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = CoreDataStack.sharedInstance.managedObjectContext
        }
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context,
                                             sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Photos Feed"
        view.backgroundColor = .white
        tableView.register(UINib.init(nibName: PhotoCell.nibName, bundle: nil), forCellReuseIdentifier: PhotoCell.id)
        updateTableContent()
    }
    
    fileprivate func updateTableContent() {
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(self.fetchedhResultController.sections?[0].numberOfObjects)")
            print("COUNT FETCHED TOTAL \(self.fetchedhResultController.fetchedObjects?.count)")
            
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        let service = APIService()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
                
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension PhotoVC {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.id, for: indexPath) as! PhotoCell
        if let photo = fetchedhResultController.object(at: indexPath) as? Photo {
            cell.setPhotoCellWith(photo: photo)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width + 100 //100 = sum of labels height + height of divider line
    }
    
}

extension PhotoVC {
    
    private func createPhotoEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        var context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = CoreDataStack.sharedInstance.managedObjectContext
        }
        
        if let photoEntity = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as? Photo {
            photoEntity.author = dictionary["author"] as? String
            photoEntity.tags = dictionary["tags"] as? String
            let mediaDictionary = dictionary["media"] as? [String: AnyObject]
            photoEntity.mediaURL = mediaDictionary?["m"] as? String
            return photoEntity
        }
        return nil
    }
    
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map { self.createPhotoEntityFrom(dictionary: $0) }
        do {
            var context: NSManagedObjectContext
            if #available(iOS 10.0, *) {
                context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                context = CoreDataStack.sharedInstance.managedObjectContext
            }
            try context.save()
            
        } catch let error {
            print(error)
        }
    }
    
    private func clearData() {
        do {
            var context: NSManagedObjectContext
            if #available(iOS 10.0, *) {
                context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                context = CoreDataStack.sharedInstance.managedObjectContext
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Photo.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map { $0.map{ context.delete($0) } }
                CoreDataStack.sharedInstance.saveContext()
                
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
}

extension PhotoVC: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}








//
//  SettingsViewController.swift
//  DaniloAlvesVieira
//
//  Created by Danilo Alves Vieira on 22/04/18.
//  Copyright © 2018 Danilo Alves Vieira. All rights reserved.
//

import UIKit
import CoreData

enum CategoryType {
    case add
    case edit
}

class SettingsViewController: UIViewController {

    var fetchedResultController: NSFetchedResultsController<State>!
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))

    
    @IBOutlet weak var statesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        statesTableView.estimatedRowHeight = 106
        statesTableView.rowHeight = UITableViewAutomaticDimension
        
        label.text = "Lista de estados vazia"
        label.textAlignment = .center
        label.textColor = .black
        
        loadState()
        
        
    }

    func loadState() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
    }
    
    func showAlert(type: CategoryType, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            if let name = state?.name {
                textField.text = name
            }
        }
        
        alert.addTextField { (textField2: UITextField) in
            textField2.placeholder = "Imposto"
            if let tax = state?.tax {
                textField2.text = "\(tax)"
            }
        }
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = state ?? State(context: self.context)
            state.name = alert.textFields?.first?.text
            state.tax = Double(alert.textFields![1].text!)!
            do {
                try self.context.save()
//                self.loadState()
            } catch {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    
}

extension SettingsViewController: UITableViewDelegate {
    
    
}

extension SettingsViewController: UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = fetchedResultController.fetchedObjects?.count {
            statesTableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            statesTableView.backgroundView = label
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath)
        let state = fetchedResultController.object(at: indexPath)
        
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(state.tax)"
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension SettingsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        statesTableView.reloadData()
    }
}

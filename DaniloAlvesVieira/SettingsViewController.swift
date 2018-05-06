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
    var formatter = NumberFormatter()
    
    @IBOutlet weak var statesTableView: UITableView!
    @IBOutlet weak var tfCotacao: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        statesTableView.estimatedRowHeight = 106
        statesTableView.rowHeight = UITableViewAutomaticDimension
        
        label.text = "Lista de estados vazia"
        label.textAlignment = .center
        label.textColor = .black
        
        loadState()
        
        formatter.locale = NSLocale.current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tfCotacao.text = formatter.string(from: UserDefaults.standard.double(forKey: "cotacao") as NSNumber)
        tfIOF.text = formatter.string(from: UserDefaults.standard.double(forKey: "iof") as NSNumber)
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
            textField2.keyboardType = .decimalPad
            if let tax = state?.tax {
                textField2.text = self.formatter.string(from: tax as NSNumber)
            }
        }
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = state ?? State(context: self.context)
            
            if alert.textFields!.first!.text!.isEmpty {
                
                if type == .add {
                    self.context.delete(state)
                    self.showAlert(type: type, state: nil)
                } else {
                    self.showAlert(type: type, state: state)
                }
                return
            }
            
            state.name = alert.textFields?.first?.text
            
            if alert.textFields![1].text!.isEmpty {
                
                if type == .add {
                    self.context.delete(state)
                    self.showAlert(type: type, state: nil)
                } else {
                    self.showAlert(type: type, state: state)
                }
                return
            }
            
            state.tax = self.formatter.number(from: alert.textFields![1].text!)!.doubleValue
            
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
    
    @IBAction func updateCotacao(_ sender: UITextField) {
        
        if tfCotacao.text!.isEmpty {
            tfCotacao.becomeFirstResponder()
            tfCotacao.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.01164490638, alpha: 0.6546269806)
        } else {
            tfCotacao.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            UserDefaults.standard.set(formatter.number(from: tfCotacao.text!)?.doubleValue, forKey: "cotacao")
        }

    }
    
    @IBAction func updateIOF(_ sender: Any) {

        if tfIOF.text!.isEmpty {
            tfIOF.becomeFirstResponder()
            tfIOF.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.01164490638, alpha: 0.6546269806)
        } else {
            tfIOF.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            UserDefaults.standard.set(formatter.number(from: tfIOF.text!)?.doubleValue, forKey: "iof")
        }
        
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    
    
}

extension SettingsViewController: UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
        cell.detailTextLabel?.text = formatter.string(from: state.tax as NSNumber)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let state = fetchedResultController.object(at: indexPath)
            context.delete(state)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(type: .edit, state: fetchedResultController.object(at: indexPath))
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension SettingsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        statesTableView.reloadData()
    }
}

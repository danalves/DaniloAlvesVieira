//
//  ComprasRegisterViewController.swift
//  DaniloAlvesVieira
//
//  Created by Usuário Convidado on 23/04/18.
//  Copyright © 2018 Danilo Alves Vieira. All rights reserved.
//

import UIKit
import CoreData

class ComprasRegisterViewController: UIViewController {
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var swCreditCard: UISwitch!
    @IBOutlet weak var btAddUpdate: UIButton!
    
    var pickerView: UIPickerView!
    var fetchedResultController: NSFetchedResultsController<State>!
    var dataSource: [State]!
    
    var smallImage: UIImage!
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadState()
        createPickerView()
        
        if product != nil {
            tfName.text = product.name
            
            let formatter = NumberFormatter()
            formatter.locale = NSLocale.current
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = true
            
            
            tfPrice.text = formatter.string(from: NSNumber(value: product.price))
            tfState.text = product.state?.name
            swCreditCard.isOn = product.creditcard
            if let image = product.photo as? UIImage {
                ivImage.image = image
            }           
            
            btAddUpdate.setTitle("ALTERAR", for: .normal) 
        }
        
    }
    
    func loadState() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
            dataSource = fetchedResultController.fetchedObjects
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func createPickerView() {
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfState.inputView = pickerView
        tfState.inputAccessoryView = toolbar
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tfPrice.resignFirstResponder()
        tfName.resignFirstResponder()
        tfState.resignFirstResponder()
    }
    
    @objc func done() {
        
        tfState.text = dataSource[pickerView.selectedRow(inComponent: 0)].name
        cancel()
        
    }
    
    @objc func cancel() {
        
        tfState.resignFirstResponder()
        
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        //Criando o alerta que será apresentado ao usuário
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        //Verificamos se o device possui câmera. Se sim, adicionamos a devida UIAlertAction
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        //Criando o objeto UIImagePickerController
        let imagePicker = UIImagePickerController()
        
        //Definimos seu sourceType através do parâmetro passado
        imagePicker.sourceType = sourceType
        
        //Definimos a MovieRegisterViewController como sendo a delegate do imagePicker
        imagePicker.delegate = self
        
        //Apresentamos a imagePicker ao usuário
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func checkIfIsEmpty(_ sender: UITextField) {
        if dataSource.count == 0 {
            tfState.resignFirstResponder()
            performSegue(withIdentifier: "manualSegue", sender: self)
        }
    }
    
    
    @IBAction func addProduct(_ sender: UIButton) {
        
        if validation() {
            
            if product == nil {
                product = Product(context: self.context)
            }
            
            product.name = tfName.text
            product.state = dataSource[pickerView.selectedRow(inComponent: 0)]
            product.creditcard = swCreditCard.isOn
            
            let formatter = NumberFormatter()
            formatter.locale = NSLocale.current
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = true
            
            if let price = formatter.number(from: tfPrice!.text!) {
                if price.doubleValue > 0 {
                    product.price = price.doubleValue
                } else {
                    showAlert(fields: ["Preço"])
                    context.delete(product)
                    return
                }
            } else {
                showAlert(fields: ["Preço"])
                context.delete(product)
                return
            }
            
            if smallImage != nil {
                product.photo = smallImage
            }
            
            do {
                try self.context.save()
            } catch {
                print(error.localizedDescription)
            }
            
            navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    func validation() -> Bool {
        
        var emptyFields: [String] = []
        
        if tfName.text!.isEmpty {
            emptyFields.append("Nome do produto")
            tfName.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.01164490638, alpha: 0.6546269806)
        } else {
            tfName.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if tfPrice.text!.isEmpty {
            emptyFields.append("Preço")
            tfPrice.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.01164490638, alpha: 0.6546269806)
        } else {
            tfPrice.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if tfState.text!.isEmpty {
            emptyFields.append("Estado")
            tfState.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.01164490638, alpha: 0.6546269806)
        } else {
            tfState.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if !emptyFields.isEmpty {
            showAlert(fields: emptyFields)
            return false
        } else {
            return true
        }
        
    }
    
    func showAlert(fields: [String]) {
        
        let message = fields.joined(separator: ", ")
        
        let alert = UIAlertController(title: "\(message) \(fields.count > 1 ? "inconsistentes!" : "inconsistente!")", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Extensions
//extension ComprasRegisterViewController: UIImagePickerControllerDelegate{
extension ComprasRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
        let smallSize = CGSize(width: 340, height: 200)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        //Atribuímos a versão reduzida da imagem à variável smallImage
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivImage.image = smallImage //Atribuindo a imagem à ivPoster
        
        //Aqui efetuamos o dismiss na UIImagePickerController, para retornar à tela anterior
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension ComprasRegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row].name
    }
    
}

extension ComprasRegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}

extension ComprasRegisterViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataSource = fetchedResultController.fetchedObjects
        pickerView.reloadComponent(0)
    }
}

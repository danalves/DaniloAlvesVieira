//
//  ResultViewController.swift
//  DaniloAlvesVieira
//
//  Created by Danilo Alves Vieira on 05/05/18.
//  Copyright © 2018 Danilo Alves Vieira. All rights reserved.
//

import UIKit
import CoreData

class ResultViewController: UIViewController {

    @IBOutlet weak var tfUSTotal: UILabel!
    @IBOutlet weak var tfBRTotal: UILabel!
    
    var fetchRequest: NSFetchRequest<Product>!
    var products: [Product] = []
    
    var totalBruto: Double = 0
    var totalLiquido: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRequest = Product.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]

    }

    override func viewWillAppear(_ animated: Bool) {
        
        totalBruto = 0
        totalLiquido = 0
        
        let cotacao = UserDefaults.standard.double(forKey: "cotacao")
        let iof = UserDefaults.standard.double(forKey: "iof")
        
        do {
            products = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        for product in products {
            
            totalBruto += product.price
            
            var price = product.price * (1 + product.state!.tax / 100)
            
            if product.creditcard {
                price = price * (1 + iof / 100)
            }
            
            totalLiquido += price
            
        }
        
        tfUSTotal.text = "\(totalBruto)"
        tfBRTotal.text = "\(totalLiquido * cotacao)"
        
    }


}

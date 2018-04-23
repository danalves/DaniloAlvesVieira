//
//  UIViewController+CoreData.swift
//  DaniloAlvesVieira
//
//  Created by Danilo Alves Vieira on 22/04/18.
//  Copyright © 2018 Danilo Alves Vieira. All rights reserved.
//

import CoreData
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}

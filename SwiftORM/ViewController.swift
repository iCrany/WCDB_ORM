//
//  ViewController.swift
//  SwiftORM
//
//  Created by iCrany on 2019/1/6.
//  Copyright © 2019 iCrany. All rights reserved.
//

import UIKit

class WCDBSampleModel: TableCodable {
    //Your own properties
    var variable1: Int = 0
    var variable2: String? // Optional if it would be nil in some WCDB selection
    var variable3: Double? // Optional if it would be nil in some WCDB selection
    var variable4: Data?
    var unbound: Date? = nil
    
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = WCDBSampleModel
        
        //List the properties which should be bound to table
        case variable1 = "custom_name"
        case variable2
        case variable3
        case variable4
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
//        Column constraints for primary key, unique, not null, default value and so on. It is optional.
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                .variable1: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                .variable2: ColumnConstraintBinding(isUnique: true)
            ]
        }
        
        //Index bindings. It is optional.
        //static var indexBindings: [IndexBinding.Subfix: IndexBinding]? {
        //    return [
        //        "_index": IndexBinding(indexesBy: CodingKeys.variable2)
        //    ]
        //}
        
        //Table constraints for multi-primary, multi-unique and so on. It is optional.
        //static var tableConstraintBindings: [TableConstraintBinding.Name: TableConstraintBinding]? {
        //    return [
        //        "MultiPrimaryConstraint": MultiPrimaryBinding(indexesBy: variable2.asIndex(orderBy: .descending), variable3.primaryKeyPart2)
        //    ]
        //}
        
        //Virtual table binding for FTS and so on. It is optional.
        //static var virtualTableBinding: VirtualTableBinding? {
        //    return VirtualTableBinding(with: .fts3, and: ModuleArgument(with: .WCDB))
        //}
    }
    
    //Properties below are needed only the primary key is auto-incremental
    //var isAutoIncrement: Bool = false
    //var lastInsertedRowID: Int64 = 0
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        
        for (index, property) in WCDBSampleModel.CodingKeys.all.enumerated() {
//            print("\(index): \(property.name) \(String(describing: WCDBSampleModel.Properties.objectRelationalMapping.columnTypes[property.name]))")
        }
    }
}


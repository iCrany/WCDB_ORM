/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

public final class TableBinding<CodingTableKeyType: CodingTableKey> {
    private let properties: [CodingTableKeyType: Property]
    let allProperties: [Property]
    let allKeys: [CodingTableKeyType]

    private lazy var columnTypes: [String: ColumnType] = {
        // CodingTableKeyType.Root must conform to TableEncodable protocol.
        let tableDecodableType = CodingTableKeyType.Root.self as! TableDecodableBase.Type
        return ColumnTypeDecoder.types(of: tableDecodableType)
    }()
    
    private lazy var allColumnDef: [ColumnDef] = allKeys.map { (key) -> ColumnDef in
        return generateColumnDef(with: key)
    }

    private typealias ColumnConstraintBindingMap = [CodingTableKeyType: ColumnConstraintBinding]
    private lazy var columnConstraintBindings: ColumnConstraintBindingMap? = CodingTableKeyType.columnConstraintBindings

    public init(_ type: CodingTableKeyType.Type) {
        var allProperties: [Property] = []
        var properties: [CodingTableKeyType: Property] = [:]
        var allKeys: [CodingTableKeyType] = []

        var i = 0
        while true {
            guard let key = (withUnsafePointer(to: &i) {
                return $0.withMemoryRebound(to: CodingTableKeyType?.self, capacity: 1, { return $0.pointee })
            }) else {
                break
            }
            allKeys.append(key)
            i += 1
        }

        for key in allKeys {
            print("key: \(key.stringValue)")
            let property = Property(with: key)
            properties[key] = property
            allProperties.append(property)
        }

        self.allKeys = allKeys
        self.properties = properties
        self.allProperties = allProperties

        #if DEBUG
        if let tableDecodableType = CodingTableKeyType.Root.self as? TableDecodableBase.Type {
            let types = ColumnTypeDecoder.types(of: tableDecodableType)
            let keys = allKeys.filter({ (key) -> Bool in
                return types.index(forKey: key.stringValue) == nil
            })
            assert(keys.count == 0,
                   """
                   The following keys: \(keys) can't be decoded. \
                   1. Try to change their definition from `let` to `var` or report an issue to us. \
                   2. Try to rename the `static` variable with same name.
                   """)
        }
        #endif
    }

    typealias TypedCodingTableKeyType = CodingTableKeyType
    func property<CodingTableKeyType: CodingTableKey>(from codingTableKey: CodingTableKeyType) -> Property {
        let typedCodingTableKey = codingTableKey as? TypedCodingTableKeyType
        assert(typedCodingTableKey != nil, "[\(codingTableKey)] must conform to CodingTableKey protocol.")
        let typedProperty = properties[typedCodingTableKey!]
        assert(typedProperty != nil, "It should not be failed. If you think it's a bug, please report an issue to us.")
        return typedProperty!
    }
    
    public func generateCreateTableStatement(named table: String, ifNotExists: Bool = true) -> String {
        var description: String = ""
        description.append("CREATE TABLE ")
        if ifNotExists {
            description.append("IF NOT EXISTS ")
        }
        
        description.append("\(table)(\(allColumnDef.joined())")
        
        description.append(")")
        return description
    }
    
    func generateColumnDef(with key: CodingTableKeyBase) -> ColumnDef {
        let codingTableKey = key as? CodingTableKeyType
        assert(codingTableKey != nil, "[\(key)] must conform to CodingTableKey protocol.")
        let columnType = columnTypes[codingTableKey!.stringValue]
        assert(columnType != nil, "It should not be failed. If you think it's a bug, please report an issue to us.")
        var columnDef = ColumnDef(with: codingTableKey!, and: columnType!)
        if let index = columnConstraintBindings?.index(forKey: codingTableKey!) {
            columnDef = columnConstraintBindings![index].value.generateColumnDef(with: columnDef)
        }
        return columnDef
    }
    
}

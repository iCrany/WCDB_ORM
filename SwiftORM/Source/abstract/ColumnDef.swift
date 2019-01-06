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

public protocol ColumnConvertible {
    func asColumn() -> Column
}

public final class ColumnDef: Describable {
    public private(set) var description: String

    public init(with columnConvertible: ColumnConvertible, and optionalType: ColumnType? = nil) {
        description = columnConvertible.asColumn().description
        if let type = optionalType {
            description.append(" \(type.description)")
        }
    }
    
    @discardableResult
    public func makePrimary(isAutoIncrement: Bool = false) -> ColumnDef {
        description.append(" PRIMARY KEY")
        if isAutoIncrement {
            description.append(" AUTOINCREMENT")
        }
        return self
    }

    public enum DefaultType: Describable {
        case null
        case int32(Int32)
        case int64(Int64)
        case bool(Bool)
        case text(String)
        case float(Double)
        case BLOB(Data)
        case currentTime
        case currentDate
        case currentTimestamp

        public var description: String {
            switch self {
            case .null:
                return "NULL"
            case .int32(let value):
                return LiteralValue(value).description
            case .int64(let value):
                return LiteralValue(value).description
            case .bool(let value):
                return LiteralValue(value).description
            case .text(let value):
                return LiteralValue(value).description
            case .float(let value):
                return LiteralValue(value).description
            case .BLOB(let value):
                return LiteralValue(value).description
            case .currentDate:
                return "CURRENT_DATE"
            case .currentTime:
                return "CURRENT_TIME"
            case .currentTimestamp:
                return "CURRENT_TIMESTAMP"
            }
        }
    }

    @discardableResult
    public func makeDefault(to defaultValue: DefaultType) -> ColumnDef {
        description.append(" DEFAULT \(defaultValue.description)")
        return self
    }

    @discardableResult
    public func makeNotNull() -> ColumnDef {
        description.append(" NOT NULL")
        return self
    }

    @discardableResult
    public func makeUnique() -> ColumnDef {
        description.append(" UNIQUE")
        return self
    }
}

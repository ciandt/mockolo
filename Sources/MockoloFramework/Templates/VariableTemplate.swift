//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation


extension VariableModel {

    func applyVariableTemplate(name: String,
                               type: Type,
                               encloser: String,
                               isStatic: Bool,
                               allowSetCallCount: Bool,
                               shouldOverride: Bool,
                               accessLevel: String) -> String {
        
        let underlyingSetCallCount = "\(name)\(String.setCallCountSuffix)"
        let underlyingVarDefaultVal = type.defaultVal()
        var underlyingType = type.typeName
        if underlyingVarDefaultVal == nil {
            underlyingType = type.underlyingType
        }
        
        let overrideStr = shouldOverride ? "\(String.override) " : ""
        var acl = accessLevel
        if !acl.isEmpty {
            acl = acl + " "
        }
        
        var assignVal = ""
        if !shouldOverride, let val = underlyingVarDefaultVal {
            assignVal = "= \(val)"
        }
        
        let privateSetSpace = allowSetCallCount ? "" :  "\(String.privateSet) "
        let setCallCountStmt = "\(underlyingSetCallCount) += 1"
        
        var template = ""
        if isStatic || underlyingVarDefaultVal == nil {
            let staticSpace = isStatic ? "\(String.static) " : ""
            template = """

            \(1.tab)\(acl)\(staticSpace)\(privateSetSpace)var \(underlyingSetCallCount) = 0
            \(1.tab)\(staticSpace)private var \(underlyingName): \(underlyingType) \(assignVal) { didSet { \(setCallCountStmt) } }
            \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(type.typeName) {
            \(2.tab)get { return \(underlyingName) }
            \(2.tab)set { \(underlyingName) = newValue }
            \(1.tab)}
            """
        } else {
            template = """

            \(1.tab)\(acl)\(privateSetSpace)var \(underlyingSetCallCount) = 0
            \(1.tab)\(acl)\(overrideStr)var \(name): \(type.typeName) \(assignVal) { didSet { \(setCallCountStmt) } }
            """
        }
        
        return template
    }
}



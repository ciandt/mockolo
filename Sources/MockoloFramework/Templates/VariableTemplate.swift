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
                               customModifiers: [String: Modifier]?,
                               allowSetCallCount: Bool,
                               shouldOverride: Bool,
                               accessLevel: String) -> String {
        
        let underlyingSetCallCount = "\(name)\(String.setCallCountSuffix)"
        let underlyingVarDefaultVal = type.defaultVal()
        var underlyingType = type.typeName
        if underlyingVarDefaultVal == nil {
            underlyingType = type.underlyingType
        }
        
        let propertyWrapper = propertyWrapper != nil ? "\(propertyWrapper!) " : ""

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
        
        let modifierTypeStr: String
        if let customModifiers = self.customModifiers,
           let customModifier: Modifier = customModifiers[name] {
            modifierTypeStr = customModifier.rawValue + " "
        } else {
            modifierTypeStr = ""
        }

        var template = ""
        if isStatic || underlyingVarDefaultVal == nil {
            let staticSpace = isStatic ? "\(String.static) " : ""
            template = """

            \(1.tab)\(acl)\(staticSpace)\(privateSetSpace)var \(underlyingSetCallCount) = 0
            \(1.tab)\(propertyWrapper)\(staticSpace)private var \(underlyingName): \(underlyingType) \(assignVal) { didSet { \(setCallCountStmt) } }
            \(1.tab)\(acl)\(staticSpace)\(overrideStr)\(modifierTypeStr)var \(name): \(type.typeName) {
            \(2.tab)get { return \(underlyingName) }
            \(2.tab)set { \(underlyingName) = newValue }
            \(1.tab)}
            """
        } else {
            template = """

            \(1.tab)\(acl)\(privateSetSpace)var \(underlyingSetCallCount) = 0
            \(1.tab)\(propertyWrapper)\(acl)\(overrideStr)\(modifierTypeStr)var \(name): \(type.typeName) \(assignVal) { didSet { \(setCallCountStmt) } }
            """
        }

        return template
    }

    func applyCombineVariableTemplate(name: String,
                                      type: Type,
                                      encloser: String,
                                      shouldOverride: Bool,
                                      isStatic: Bool,
                                      accessLevel: String) -> String? {
        let typeName = type.typeName

        guard
            typeName.starts(with: String.anyPublisherLeftAngleBracket),
            let range = typeName.range(of: String.anyPublisherLeftAngleBracket),
            let lastIdx = typeName.lastIndex(of: ">")
        else {
            return nil
        }

        let typeParamStr = typeName[range.upperBound..<lastIdx]
        var subjectTypeStr = ""
        var errorTypeStr = ""
        if let lastCommaIndex = typeParamStr.lastIndex(of: ",") {
            subjectTypeStr = String(typeParamStr[..<lastCommaIndex])
            let nextIndex = typeParamStr.index(after: lastCommaIndex)
            errorTypeStr = String(typeParamStr[nextIndex..<typeParamStr.endIndex]).trimmingCharacters(in: .whitespaces)
        }
        let subjectType = Type(subjectTypeStr)
        let subjectDefaultValue = subjectType.defaultVal()
        let staticSpace = isStatic ? "\(String.static) " : ""
        let acl = accessLevel.isEmpty ? "" : accessLevel + " "
        let thisStr = isStatic ? encloser : "self"
        let overrideStr = shouldOverride ? "\(String.override) " : ""

        switch combineType {
        case .property(_, var wrapperPropertyName):
            // Using a property wrapper to back this publisher, such as @Published

            var template = "\n"
            var isWrapperPropertyOptionalOrForceUnwrapped = false
            if let publishedAliasModel = wrapperAliasModel {
                // If the property required by the protocol/class cannot be optional, the wrapper property will be the underlyingProperty
                // i.e. @Published var _myType: MyType!
                let wrapperPropertyDefaultValue = publishedAliasModel.type.defaultVal()
                if wrapperPropertyDefaultValue == nil {
                    wrapperPropertyName = "_\(wrapperPropertyName)"
                }
                isWrapperPropertyOptionalOrForceUnwrapped = wrapperPropertyDefaultValue == nil || publishedAliasModel.type.isOptional
            }

            var mapping = ""
            if !subjectType.isOptional, isWrapperPropertyOptionalOrForceUnwrapped {
                // If the wrapper property is of type: MyType?/MyType!, but the publisher is of type MyType
                mapping = ".map { $0! }"
            } else if subjectType.isOptional, !isWrapperPropertyOptionalOrForceUnwrapped {
                // If the wrapper property is of type: MyType, but the publisher is of type MyType?
                mapping = ".map { $0 }"
            }

            let setErrorType = ".setFailureType(to: \(errorTypeStr).self)"
            template += """
            \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(typeName) { return \(thisStr).$\(wrapperPropertyName)\(mapping)\(setErrorType).\(String.eraseToAnyPublisher)() }
            """
            return template
        default:
            // Using a combine subject to back this publisher
            var combineSubjectType = combineType ?? .passthroughSubject

            var defaultValue: String? = ""
            if case .currentValueSubject = combineSubjectType {
                defaultValue = subjectDefaultValue
        }
        
            // Unable to generate default value for this CurrentValueSubject. Default back to PassthroughSubject.
            //
            if defaultValue == nil {
                combineSubjectType = .passthroughSubject
            }
            let underlyingSubjectName = "\(name)\(String.subjectSuffix)"

            let template = """

            \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(typeName) { return \(thisStr).\(underlyingSubjectName).\(String.eraseToAnyPublisher)() }
            \(1.tab)\(acl)\(staticSpace)\(String.privateSet) var \(underlyingSubjectName) = \(combineSubjectType.typeName)<\(typeParamStr)>(\(defaultValue ?? ""))
            """
        return template
    }
}
}



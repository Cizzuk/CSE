//
//  Enums.swift
//  CSE
//
//  Created by Cizzuk on 2025/11/08.
//

import Foundation

enum QuickSearchKeywordPos: String, CaseIterable {
    case prefix, suffix, prefORsuf, prefANDsuf
    
    static let `default`: QuickSearchKeywordPos = .prefix
    
    var displayName: String.LocalizationValue {
        switch self {
        case .prefix:
            return "Prefix"
        case .suffix:
            return "Suffix"
        case .prefORsuf:
            return "Prefix or Suffix"
        case .prefANDsuf:
            return "Prefix and Suffix"
        }
    }
}

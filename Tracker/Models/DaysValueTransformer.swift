//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Ilya Lotnik on 10.09.2024.
//

import Foundation


@objc(DaysValueTransformer)
final class DaysValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Day] else { return nil }
        
        let data = try? JSONEncoder().encode(days)
        return data
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        let days = try? JSONDecoder().decode([Day].self, from: data)
        return days
    }
    
    static func register() {
        let className = String(describing: DaysValueTransformer.self)
        let name = NSValueTransformerName(className)
        
        let transformer = DaysValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

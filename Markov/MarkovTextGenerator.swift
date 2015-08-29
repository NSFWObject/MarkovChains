//
//  MarkovTextGenerator.swift
//  Markov
//
//  Created by Sash Zats on 8/27/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Foundation
import GameplayKit

class MarkovGenerator {

    static func processText(text: String, lookbehind: Int = 2) -> [NSArray: [[Double: GKState]]] {
        let lookup = mapForString(text)
        let prefixToCounts = prefixToContedSetOfChars(string: text, lookbehind: lookbehind)
        let result = processPrefixes(prefixToCounts, lookup: lookup)
        // To avoid problem when end of the text doesn't lead to any other state
        let end = text.substringFromIndex(text.endIndex.advancedBy(-lookbehind))
        return result
    }
    
    private static func mapForString(string: String) -> [Character: StringState] {
        var result: [Character: StringState] = [:]
        for char in Set<Character>(string.characters) {
            result[char] = .instanceForString(String(char))
        }
        return result
    }
    
    private static func processPrefixes(prefixMap: [String: NSCountedSet], lookup: [Character: StringState]) -> [NSArray: [[Double: GKState]]] {
        var result: [NSArray: [[Double: GKState]]] = [:]
        for (prefix, outcomes) in prefixMap {
            let outcomesMap = outcomesToMap(outcomes)
            let key: NSArray = statesArrayFromString(prefix, lookup: lookup)
            let value: [[Double: GKState]] = outcomesMap.map{ [$0.keys.first!: lookup[$0.values.first!.characters.first!]!] }
            result[key] = value
        }
        return result
    }
    
    private static func statesArrayFromString(string: String, lookup: [Character: StringState]) -> NSArray {
        return string.characters.map{ lookup[$0]! }
    }
    
    private static func outcomesToMap(set: NSCountedSet) -> [[Double: String]] {
        var result: [[Double: String]] = []
        for string in set {
            let probability = round(set.uniformCountForObject(string) * 100) / 100
            result.append([probability: string as! String])
        }
        result = result.sort{ $0.0.keys.first! < $0.1.keys.first! }
        let remainder: Double = result.reduce(1){ $0 - $1.keys.first! }
        if remainder != 0 {
            let lastIndex = result.count - 1
            let lastObject = result[lastIndex]
            let lastProbability = lastObject.keys.first!
            result[lastIndex] = [round((lastProbability + remainder) * 100) / 100: lastObject.values.first!]
        }
        return result
    }
    
    private static func prefixToContedSetOfChars(string string: String, lookbehind: Int) -> [String: NSCountedSet] {
        var prefixToCounts: [String: NSCountedSet] = [:]
        for i in lookbehind..<string.characters.count {
            let start = string.startIndex.advancedBy(i - lookbehind)
            let end = string.startIndex.advancedBy(i)
            let prefix = string.substringWithRange(Range(start: start, end: end))
            
            let countedSet: NSCountedSet
            if prefixToCounts[prefix] != nil {
                countedSet = prefixToCounts[prefix]!
            } else {
                countedSet = NSCountedSet()
                prefixToCounts[prefix] = countedSet
            }
            let next = string.substringWithRange(Range(start: end, end: end.advancedBy(1)))
            countedSet.addObject(next)
        }
        return prefixToCounts
    }
}

extension NSCountedSet {
    func uniformCountForObject(a: AnyObject) -> Double {
        let total = reduce(0){ $0 + countForObject($1) }
        return Double(countForObject(a)) / Double(total)
    }
}

class StringState: GKState {
    private(set) var string: String = ""
    
    static func classNameForString(string: String) -> String {
        return "StringState_\(string)"
    }
    
    static func classForString(string: String) -> AnyClass {
        let name = classNameForString(string)
        if let cls = objc_lookUpClass(name) {
            return cls
        } else {
            let cls: AnyClass = objc_allocateClassPair(StringState.self, name, 0)
            objc_registerClassPair(cls)
            return cls
        }
    }
    
    static func instanceForString(string: String) -> StringState {
        let cls: AnyClass = classForString(string)
        let instance = InstantiateClass(cls) as! StringState
        instance.string = string
        return instance
    }
    
    override var description: String {
        return "StringState value=\"\(self.string)\""
    }
}

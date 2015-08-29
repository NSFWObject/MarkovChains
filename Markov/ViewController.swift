//
//  ViewController.swift
//  Markov
//
//  Created by Sash Zats on 8/25/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import UIKit
import GameplayKit
import ObjectiveC


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateSimpleState()
//        generateRecipes()
    }
    
    private func generateSimpleState() {
        let a = StateA()
        let b = StateB()
        
        let m = MarkovChainMachine(initialStates: [a, b], mapping: [
            [a, b]: [
                [0.3: a],
                [0.7: b]
            ],
            [b, a]: [
                [0.7: a],
                [0.3: b]
            ],
            [a, a]: [
                [0.1: a],
                [0.9: b]
            ],
            [b, b]: [
                [0.9: a],
                [0.1: b]
            ]
            ])
        for _ in 0...20 {
            if m.enterNextState() {
                print(m.currentState!, separator: "", terminator: " ")
            }
        }
    }
    
    private func generateRecipes() {
        let source = try! String(contentsOfURL: NSBundle.mainBundle().URLForResource("Source", withExtension: "txt")!)
        let outcomes = MarkovGenerator.processText(source, lookbehind: 2)
        let random = arc4random_uniform(UInt32(outcomes.keys.count))
        let index = outcomes.keys.startIndex.advancedBy(Int(random))
        let initialState = outcomes.keys[index] as! [GKState]
        let m = MarkovChainMachine(initialStates: initialState, mapping: outcomes)
        for idx in 1...10 {
            print("Recipe \(idx)")
            
            var chain = m.stateBuffer.reduce(""){ $0 + ($1 as! StringState).string }
            for _ in 0...arc4random_uniform(2000) + 300 {
                let x = m.enterNextState()
                assert(x)
                let y = m.currentState as! StringState
                chain += y.string
            }
            print("\(chain)\n\n")
        }
    }
}


class StateA: GKState {
    override var description: String {
        return "A"
    }
}

class StateB: GKState {
    override var description: String {
        return "B"
    }
}
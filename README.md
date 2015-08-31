Complimentary code for the blogpost http://blog.zats.io/2015/08/29/markov-chains-with-gameplaykit/

Basically

```swift
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

for _ in 0...15 {
    if m.enterNextState() {
        print(m.currentState!, separator: "", terminator: " ")
    }
}
```

Prints `A B B A B B A A B A A B A A B B A A `

🐶🐮

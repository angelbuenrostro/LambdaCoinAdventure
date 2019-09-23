import Foundation

func fibonacci(n: Int) -> [Int] {
    var fibs:[Int] = [0,1,1,2]
    print(fibs)
    while fibs.count < n {
        let newFib = fibs[fibs.count-2] + fibs[fibs.count-1]
        fibs.append(newFib)
    }
    print(fibs)
    var fibArray:[Int] = []
    for i in 0...n {
        fibArray[i] = fibs[i]
    }
    print(fibArray)
    return fibArray
}

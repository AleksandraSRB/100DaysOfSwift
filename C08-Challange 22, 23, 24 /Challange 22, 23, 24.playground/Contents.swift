import UIKit



// Challange 1. Create extension that has method for scaling down its size to 0.0001, over specified number of seconds
extension UIView {
    func bounceOf(duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

// Challange 2. Extend Int with a times() method that runs a closure as many times as the number is high. For example, 5.times { print("Hello!") } will print “Hello” five times.

extension Int {
    func times(_ closure: () -> Void) {
        // self cannot be negative number
        guard self > 0 else { return }
        
        for _ in 0..<self {
            closure()
        }
    }
}

5.times {
    print("hello")
}

// Challange 3. Extend Array so that it has a mutating remove(item:) method. If the item exists more than once, it should remove only the first instance it finds. Tip: you will need to add the Comparable constraint to make this work!

extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        for _ in self {
            guard let firstIndex = self.firstIndex(of: item) else { return }
            self.remove(at: firstIndex)
        }
    }
}

var array = [1, 2, 3, 3, 4, 5]

array.remove(item: 2)





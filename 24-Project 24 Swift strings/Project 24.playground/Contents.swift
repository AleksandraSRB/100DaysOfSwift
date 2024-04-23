import UIKit

// STRING EXCERCISE

// 1. Loop over a String to find a letter
let name = "Taylor"

for letter in name {
    print("Give me a \(letter)!")
}
//print(name[3])

// Error - cannot subscript String with an Int, use a String.Index instead.
// razlog je sto string nije samo niz abecednih karaktera, vec moze sadrzati razlicite karaktere, simbole, kao i emoji. Ukoliko zelimo da procitamo cetvrti karakter "name" konstante, moramo da krenemo od pocetka i da "prodjemo kroz" svaki karakter, dok ne dodjemo do zeljenog broja (indeksa)

let letter = name[name.index(name.startIndex, offsetBy: 3)]

// postoji i mogucnost kreiranja ekstenzija koje su malo komplikovanije

extension String {
    subscript (i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
// sa kreiranom ekstenzijom, mozemo da procitamo treci index, ili koji vec index zadamo.
print(name[3])

// Problem je sto neko u ovom slucaju moze da zada loop koji treba da prodje kroz svaki karakter u stringu posebno, i da ne shvati da na taj nacin kreira loop unutar loopa, i usporava program

// za provere je bolje napisati someString.isEmpty nego someString.count == 0 ukoliko trazimo prazan string

// RAD SA STRINGOM

// 1. hasPrefix(), hasSuffix(), dropFirst(), dropLast()

let password = "123456"
password.hasPrefix("123")
password.hasSuffix("456")

extension String {
    // deleting prefix
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self } // if string has no prefix return self as we are
        return String(self.dropFirst(prefix.count)) // if string has prefix, drop the prefix of a string and we will send that back
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

password.deletingPrefix("123")
password.deletingSuffix("456")

// 2. Capitalized property

let weather = "it's going to rain"
print(weather.capitalized) // first letter of each word will be capitalized

extension String {
    var capitalizedFirst: String { // Ekstenzije NE MOGU imati stored property
        guard let firstLetter = self.first else { return "" } // if there is no first letter, return empty string""
        return firstLetter.uppercased() + self.dropFirst()
    }
}

weather.capitalizedFirst

// 3. contains()

let input = "Swift is like Objective-C without C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")


extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        return false
    }
}

input.containsAny(of: languages)

languages.contains(where: input.contains)

// NSAttributedString

let string = "This is a test string"

let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]

//let attributedString = NSAttributedString(string: string, attributes: attributes)

let attributedString = NSMutableAttributedString(string: string)

attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 36), range: NSRange(location: 10, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

// Challange 1.

let someString = "pet"

extension String {
    func withPrefix(_ prefix: String) -> String {
        if self.contains(prefix) {
            return self
        }
        return prefix + self
    }
}

someString.withPrefix("car")

// Challange 2.

let testString = "2. in line"

extension String {
    var isNumeric: Bool {
        var numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        if numbers.contains(where: self.contains) {
            return true
        } else {
            return false
        }
    }
}

testString.isNumeric

// Challange 3. Returning an array of elements separated by \n

var anotherTestString = "this\nis\na\ntest"
var thirdString = "no line breaks"

//extension String {
//    var lines: [String] {
//    var lineBreak = "\n"
//        
//    return self.components(separatedBy: lineBreak)
//    }
//}
//
//anotherTestString.lines
//


extension String {
    var lines: [String] {
        var lineBreak = "\n"
        
        if self.contains(lineBreak) {
            return self.components(separatedBy: lineBreak)
        } else {
            return self.components(separatedBy: ", ")
        }
    }
}

anotherTestString.lines
thirdString.lines



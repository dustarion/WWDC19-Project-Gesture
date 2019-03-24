//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

/* -------- Data storage for coreml -------- */

// Prediction Labels for Sign Language
enum HandSign: String {
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
    case F = "F"
    case G = "G"
    case H = "H"
    case I = "I"
    case J = "J"
    case k = "K"
    case L = "L"
    case M = "M"
    case N = "N"
    case O = "O"
    case P = "P"
    case Q = "Q"
    case R = "R"
    case S = "S"
    case T = "T"
    case U = "U"
    case V = "V"
    case W = "W"
    case X = "X"
    case Y = "Y"
    case Z = "Z"
    case nothing = "Empty"
}

// Useful Helpers

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}




// Main View
class IntroViewController: UIViewController {
    override func viewDidLoad() {
        self.view.backgroundColor = .black
    }
    
    override func viewDidLayoutSubviews() {
            self.view.backgroundColor = .black
            let label = UILabel()
            label.text = "Welcome to Gesture!"
            label.textColor = .yellow
            label.textAlignment = .center
            label.center = self.view.center
            self.view.addSubview(label)
    }
    
}

let IntroVC = IntroViewController()
PlaygroundPage.current.liveView = IntroViewController()


import Logsmith
import Foundation

@Loggable
class Example {
    func greet(name: String) {
        logger.info("Hello, \(name)! This is a greeting from the Logsmith macro.")
    }
}

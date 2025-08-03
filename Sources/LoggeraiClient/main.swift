import Loggerai
import Foundation
import os

@Loggerai
class Example {
    func greet(name: String) {
        logger.info("Hello, \(name)! This is a greeting from the Loggerai macro.")
    }
}

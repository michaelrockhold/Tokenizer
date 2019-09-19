import XCTest

import tokenizerTests

var tests = [XCTestCaseEntry]()
tests += tokenizerTests.allTests()
XCTMain(tests)

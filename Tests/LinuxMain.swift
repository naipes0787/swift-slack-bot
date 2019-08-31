import XCTest

import slackbotTests

var tests = [XCTestCaseEntry]()
tests += slackbotTests.allTests()
XCTMain(tests)

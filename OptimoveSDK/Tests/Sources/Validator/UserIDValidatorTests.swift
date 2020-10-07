//  Copyright © 2019 Optimove. All rights reserved.

import XCTest
@testable import OptimoveSDK

class UserIDValidatorTests: XCTestCase {

    var storage = MockOptimoveStorage()

    func test_valid() {
        let user = User(userID: "userID")
        let validator = UserValidator(storage: storage)

        XCTAssertEqual(validator.validateNewUser(user), UserValidator.Result.valid)
    }

    func test_not_valid() {
        let userIDs = ["", "none", "undefined", "undefine", "null", "undefine_foo", "undefinebar"]
        let validator = UserValidator(storage: storage)

        userIDs.forEach { userID in
            let user = User(userID: userID)
            XCTAssertEqual(validator.validateNewUser(user), UserValidator.Result.notValid)
        }
    }

    func test_already_set() {
        let user = User(userID: "userID")
        storage.customerID = user.userID
        let validator = UserValidator(storage: storage)

        XCTAssertEqual(validator.validateNewUser(user), UserValidator.Result.alreadySetIn)
    }

}

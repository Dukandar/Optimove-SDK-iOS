//  Copyright © 2019 Optimove. All rights reserved.

import Foundation

struct LogBody {
    let tenantId: Int
    let appNs: String
    let sdkEnv: Environment
    let sdkPlatform: SdkPlatform
    let level: LogLevel
    let logModule: String?
    let logFileName: String?
    let logMethodName: String?
    let message: String
}

extension LogBody: Codable {}

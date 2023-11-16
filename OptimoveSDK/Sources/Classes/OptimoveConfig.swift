//  Copyright © 2022 Optimove. All rights reserved.

import Foundation

public struct OptimoveConfig {
    let tenantInfo: OptimoveTenantInfo?
    let optimobileConfig: OptimobileConfig?

    func isOptimoveConfigured() -> Bool {
        return tenantInfo != nil
    }

    func isOptimobileConfigured() -> Bool {
        return optimobileConfig != nil
    }
}

@objc public class OptimoveTenantInfo: NSObject {
    @objc public var tenantToken: String
    @objc public var configName: String

    @objc public init(tenantToken: String, configName: String) {
        self.tenantToken = tenantToken
        self.configName = configName
    }
}

public struct OptimobileConfig {
    public enum Region: String {
        case EU = "eu"
        case US = "us"
    }

    let apiKey: String
    let secretKey: String
    let region: Region

    let sessionIdleTimeout: UInt

    let inAppConsentStrategy: InAppConsentStrategy
    let inAppDefaultDisplayMode: InAppDisplayMode
    let inAppDeepLinkHandlerBlock: InAppDeepLinkHandlerBlock?

    let pushOpenedHandlerBlock: PushOpenedHandlerBlock?
    fileprivate let _pushReceivedInForegroundHandlerBlock: Any?
    @available(iOS 10.0, *)
    var pushReceivedInForegroundHandlerBlock: PushReceivedInForegroundHandlerBlock? {
        return _pushReceivedInForegroundHandlerBlock as? PushReceivedInForegroundHandlerBlock
    }

    let deepLinkCname: URL?
    let deepLinkHandler: DeepLinkHandler?

    let baseUrlMap: ServiceUrlMap

    let runtimeInfo: [String: AnyObject]?
    let sdkInfo: [String: AnyObject]?
    let isRelease: Bool?
}

open class OptimoveConfigBuilder: NSObject {
    private var _tenantToken: String?
    private var _configName: String?
    private var _region: OptimobileConfig.Region?
    private var _apiKey: String?
    private var _secretKey: String?
    private var _sessionIdleTimeout: UInt
    private var _inAppConsentStrategy = InAppConsentStrategy.notEnabled
    private var _inAppDisplayMode = InAppDisplayMode.automatic
    private var _inAppDeepLinkHandlerBlock: InAppDeepLinkHandlerBlock?
    private var _pushOpenedHandlerBlock: PushOpenedHandlerBlock?
    private var _pushReceivedInForegroundHandlerBlock: Any?
    private var _deepLinkCname: URL?
    private var _deepLinkHandler: DeepLinkHandler?
    private var _baseUrlMap: ServiceUrlMap?

    private var _runtimeInfo: [String: AnyObject]?
    private var _sdkInfo: [String: AnyObject]?
    private var _isRelease: Bool?

    public init(optimoveCredentials: String?, optimobileCredentials: String?) {
        let optimoveCredentialsTuple = OptimoveConfigBuilder.parseOptimoveCredentials(creds: optimoveCredentials)
        let optimobileCredentialsTuple = OptimoveConfigBuilder.parseOptimobileCredentials(creds: optimobileCredentials)

        if optimoveCredentialsTuple == nil && optimobileCredentialsTuple == nil {
            assertionFailure("Invalid credentials provided to OptimoveConfigBuilder. At least one of optimoveCredentials or optimobileCredentials are required.")
        }

        if let optimoveCredentialsTuple = optimoveCredentialsTuple {
            _tenantToken = optimoveCredentialsTuple.tenantToken
            _configName = optimoveCredentialsTuple.configName
        }

        if let optimobileCredentialsTuple = optimobileCredentialsTuple {
            _apiKey = optimobileCredentialsTuple.apiKey
            _secretKey = optimobileCredentialsTuple.secretKey
            _region = optimobileCredentialsTuple.region
            _baseUrlMap = UrlBuilder.defaultMapping(for: optimobileCredentialsTuple.region.rawValue)
        }

        _sessionIdleTimeout = 23
    }

    @discardableResult public func setSessionIdleTimeout(seconds: UInt) -> OptimoveConfigBuilder {
        _sessionIdleTimeout = seconds
        return self
    }

    @discardableResult public func enableInAppMessaging(inAppConsentStrategy: InAppConsentStrategy, defaultDisplayMode: InAppDisplayMode) -> OptimoveConfigBuilder {
        _inAppConsentStrategy = inAppConsentStrategy
        _inAppDisplayMode = defaultDisplayMode
        return self
    }

    @discardableResult public func enableInAppMessaging(inAppConsentStrategy: InAppConsentStrategy) -> OptimoveConfigBuilder {
        return enableInAppMessaging(inAppConsentStrategy: inAppConsentStrategy, defaultDisplayMode: .automatic)
    }

    @discardableResult public func setInAppDeepLinkHandler(inAppDeepLinkHandlerBlock: @escaping InAppDeepLinkHandlerBlock) -> OptimoveConfigBuilder {
        _inAppDeepLinkHandlerBlock = inAppDeepLinkHandlerBlock
        return self
    }

    @discardableResult public func setPushOpenedHandler(pushOpenedHandlerBlock: @escaping PushOpenedHandlerBlock) -> OptimoveConfigBuilder {
        _pushOpenedHandlerBlock = pushOpenedHandlerBlock
        return self
    }

    @available(iOS 10.0, *)
    @discardableResult public func setPushReceivedInForegroundHandler(pushReceivedInForegroundHandlerBlock: @escaping PushReceivedInForegroundHandlerBlock) -> OptimoveConfigBuilder {
        _pushReceivedInForegroundHandlerBlock = pushReceivedInForegroundHandlerBlock
        return self
    }

    @discardableResult public func enableDeepLinking(cname: String? = nil, _ handler: @escaping DeepLinkHandler) -> OptimoveConfigBuilder {
        _deepLinkCname = URL(string: cname ?? "")
        _deepLinkHandler = handler

        return self
    }

    /**
     Internal SDK embedding API to support override of stats data in x-plat SDKs. Do not call or depend on this method in your app
     */
    @discardableResult public func setRuntimeInfo(runtimeInfo: [String: AnyObject]) -> OptimoveConfigBuilder {
        _runtimeInfo = runtimeInfo

        return self
    }

    /**
     Internal SDK embedding API to support override of stats data in x-plat SDKs. Do not call or depend on this method in your app
     */
    @discardableResult public func setSdkInfo(sdkInfo: [String: AnyObject]) -> OptimoveConfigBuilder {
        _sdkInfo = sdkInfo

        return self
    }

    /**
     Internal SDK embedding API to support override of stats data in x-plat SDKs. Do not call or depend on this method in your app
     */
    @discardableResult public func setTargetType(isRelease: Bool) -> OptimoveConfigBuilder {
        _isRelease = isRelease

        return self
    }

    /**
     Internal SDK embedding API, do not call or depend on this method in your app
     */
    @discardableResult public func setBaseUrlMapping(baseUrlMap: ServiceUrlMap) -> OptimoveConfigBuilder {
        _baseUrlMap = baseUrlMap

        return self
    }

    @discardableResult public func build() -> OptimoveConfig {
        var tenantInfo: OptimoveTenantInfo?
        var optimobileConfig: OptimobileConfig?

        if let _tenantToken = _tenantToken, let _configName = _configName {
            tenantInfo = OptimoveTenantInfo(tenantToken: _tenantToken, configName: _configName)
        }

        if let _apiKey = _apiKey,
           let _secretKey = _secretKey,
           let _baseUrlMap = _baseUrlMap,
           let _region = _region
        {
            optimobileConfig = OptimobileConfig(
                apiKey: _apiKey,
                secretKey: _secretKey,
                region: _region,
                sessionIdleTimeout: _sessionIdleTimeout,
                inAppConsentStrategy: _inAppConsentStrategy,
                inAppDefaultDisplayMode: _inAppDisplayMode,
                inAppDeepLinkHandlerBlock: _inAppDeepLinkHandlerBlock,
                pushOpenedHandlerBlock: _pushOpenedHandlerBlock,
                _pushReceivedInForegroundHandlerBlock: _pushReceivedInForegroundHandlerBlock,
                deepLinkCname: _deepLinkCname,
                deepLinkHandler: _deepLinkHandler,
                baseUrlMap: _baseUrlMap,
                runtimeInfo: _runtimeInfo,
                sdkInfo: _sdkInfo,
                isRelease: _isRelease
            )
        }

        return OptimoveConfig(
            tenantInfo: tenantInfo,
            optimobileConfig: optimobileConfig
        )
    }

    private static func parseOptimoveCredentials(creds: String?) -> (tenantToken: String, configName: String)? {
        guard let creds = creds,
              let tuple = parseTuple(creds: creds),
              let ver = tuple[0] as? Int
        else {
            return nil
        }

        if ver != 1 {
            assertionFailure("Incompatible credentials version given, please update the SDK version or check credentials")
        }

        guard let tenantToken = tuple[1] as? String,
              let configName = tuple[2] as? String
        else {
            return nil
        }

        return (tenantToken, configName)
    }

    private static func parseOptimobileCredentials(creds: String?) -> (region: OptimobileConfig.Region, apiKey: String, secretKey: String)? {
        guard let creds = creds,
              let tuple = parseTuple(creds: creds),
              let ver = tuple[0] as? Int
        else {
            return nil
        }

        if ver != 1 {
            assertionFailure("Incompatible credentials version given, please update the SDK version or check credentials")
        }

        guard
            let regionRaw = tuple[1] as? String,
            let region = OptimobileConfig.Region(rawValue: regionRaw),
            let apiKey = tuple[2] as? String,
            let secretKey = tuple[3] as? String
        else {
            return nil
        }

        return (region, apiKey, secretKey)
    }

    private static func parseTuple(creds: String) -> [Any]? {
        let json = Data(base64Encoded: creds)!
        let tuple = try? JSONSerialization.jsonObject(with: json)

        return tuple as? [Any]
    }
}

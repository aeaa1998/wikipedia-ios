import Foundation

// It is extending int to be used with objc files
@objc public class AppetizeConfigurationManager : NSObject {
    @objc public static let shared = AppetizeConfigurationManager()
    
    private var userDefaults: UserDefaults? = nil
    
    @objc public func start(with userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    @objc public func getSkipOnboarding() -> Bool {
        guard let userDefaults = self.userDefaults else { return false }
        return userDefaults.bool(forKey: "skipOnboarding")
    }
    
    @objc public func getIsAppetize() -> Bool {
        guard let userDefaults = self.userDefaults else { return false }
        return userDefaults.bool(forKey: "isAppetize")
    }
    
    @objc public func getHasCredentials() -> Bool {
        guard let userDefaults = self.userDefaults else { return false }
        return userDefaults.bool(forKey: "hasCredentials")
    }
    
    @objc public func getUsername() -> String? {
        guard let userDefaults = self.userDefaults else { return nil }
        return userDefaults.string(forKey: "username")
    }
    
    @objc public func getPassword() -> String? {
        guard let userDefaults = self.userDefaults else { return nil }
        return userDefaults.string(forKey: "password")
    }
    
}

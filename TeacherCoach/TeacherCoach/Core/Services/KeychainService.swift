import Foundation
import Security

/// Service for secure storage of sensitive data in macOS Keychain
final class KeychainService {
    static let shared = KeychainService()

    private let serviceName = "com.peninsula.teachercoach"

    private init() {}

    // MARK: - Public Methods

    /// Stores data in the Keychain
    func store(key: String, data: Data) -> Bool {
        // Delete any existing item first
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieves data from the Keychain
    func retrieve(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    /// Deletes data from the Keychain
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Updates existing data in the Keychain
    func update(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            return store(key: key, data: data)
        }

        return status == errSecSuccess
    }

    // MARK: - Convenience Methods

    /// Stores a string in the Keychain
    func storeString(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return store(key: key, data: data)
    }

    /// Retrieves a string from the Keychain
    func retrieveString(key: String) -> String? {
        guard let data = retrieve(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Stores a Codable object in the Keychain
    func storeCodable<T: Codable>(key: String, value: T) -> Bool {
        guard let data = try? JSONEncoder().encode(value) else { return false }
        return store(key: key, data: data)
    }

    /// Retrieves a Codable object from the Keychain
    func retrieveCodable<T: Codable>(key: String, type: T.Type) -> T? {
        guard let data = retrieve(key: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

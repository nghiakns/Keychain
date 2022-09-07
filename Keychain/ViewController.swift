//
//  ViewController.swift
//  Keychain
//
//  Created by Kim Nghĩa on 05/09/2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPassword()
        }
    }
    
    func getPassword() {
        guard let data = Keychain.get(service: "acb.com", account: "abc") else {
            print("Failed to read password")
            return
        }
        
        let password = String(decoding: data, as: UTF8.self)
        print("Read password: \(password)")
    }

    func save() {
        do {
            try Keychain.save(service: "acb.com",
                              account: "abc",
                              password: "1234".data(using: .utf8) ?? Data()
            )
        }
        catch {
            print(error)
        }
    }

class Keychain {
    enum KeychainError: Error{
        case duplicateEntry
        case unknown(OSStatus)
    }
    
    static func save(
        service: String,
        account: String,
        password: Data
    ) throws {
        // service, account, password, class, data
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecDuplicateItem else {
            throw KeychainError.unknown(status)
        }
        
        print("saved")
    }
    
    static func get(
        service: String,
        account: String
    ) -> Data? {
        // service, account, password, class, data
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        print("Read status: \(status)")
        
        return result as? Data
    }
}

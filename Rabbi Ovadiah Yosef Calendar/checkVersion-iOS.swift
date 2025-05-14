//
//  CheckUpdate.swift
//  CheckApp
//
//  Created by Ana Carolina on 13/11/20.
//  Copyright © 2020 acarolsf. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Enum Errors
enum VersionError: Error {
    case invalidBundleInfo, invalidResponse, dataError
}

// MARK: - Models
struct LookupResult: Decodable {
    let data: [TestFlightInfo]?
    let results: [AppInfo]?
}

struct TestFlightInfo: Decodable {
    let type: String
    let attributes: Attributes
}

struct Attributes: Decodable {
    let version: String
    let expired: String
}

struct AppInfo: Decodable {
    let version: String
    let trackViewUrl: String
}


// MARK: - Check Update Class
class CheckUpdate: NSObject {

    // MARK: - Singleton
    static let shared = CheckUpdate()

    // MARK: - TestFlight variable
    var isTestFlight: Bool = false

    static let appStoreId = "6448838987" // Id Example
    
    // MARK: - Show Update Function
    func showUpdate(withConfirmation: Bool, isTestFlight: Bool = false, isForSwiftUI: Bool = false, completion: ((Bool, String?) -> Void)? = nil) {
        self.isTestFlight = isTestFlight
        DispatchQueue.global().async {
            self.checkVersion(force: !withConfirmation, isForSwiftUI: isForSwiftUI) { needsUpdate, appURL  in
                completion?(needsUpdate, appURL)
            }
        }
    }

    // MARK: - Function to check version
    private func checkVersion(force: Bool, isForSwiftUI: Bool = false, completion: ((Bool, String?) -> Void)? = nil) {
        if let currentVersion = self.getBundle(key: "CFBundleShortVersionString") {
            _ = getAppInfo { (data, info, error) in
                
                _ = self.isTestFlight ? "TestFlight" : "AppStore"
                
                if error != nil {
                    completion?(false, nil) // Return false if there's an error fetching app info
                    return
                }
                
                if let appStoreAppVersion = info?.version { // Check app on App Store
                    let needsUpdate = appStoreAppVersion > currentVersion
                    if isForSwiftUI {
                        completion?(needsUpdate, (info?.trackViewUrl)!)
                    } else if needsUpdate {
                        DispatchQueue.main.async {
                            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene, let topController = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                                topController.showAppUpdateAlert(
                                    version: appStoreAppVersion,
                                    force: force,
                                    appURL: (info?.trackViewUrl)!,
                                    isTestFlight: self.isTestFlight
                                )
                            }
                        }
                    }
                } else if let testFlightAppVersion = data?.attributes.version { // Check app on TestFlight
                    let needsUpdate = testFlightAppVersion > currentVersion
                    if isForSwiftUI {
                        completion?(needsUpdate, (info?.trackViewUrl)!)
                    } else if needsUpdate {
                        DispatchQueue.main.async {
                            if let scene = UIApplication.shared.connectedScenes
                                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                               let topController = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                                topController.showAppUpdateAlert(
                                    version: testFlightAppVersion,
                                    force: force,
                                    appURL: (info?.trackViewUrl)!,
                                    isTestFlight: self.isTestFlight
                                )
                            }
                        }
                    }
                } else {
                    completion?(false, nil) // App does not exist on the store
                }
            }
        } else {
            completion?(false, nil) // Error decoding app version
        }
    }
    
    private func getUrl(from identifier: String) -> String {
        // You should pay attention on the country that your app is located, in my case I put Brazil */br/*
        let testflightURL = "https://api.appstoreconnect.apple.com/v1/apps/\(CheckUpdate.appStoreId)/builds"
        let appStoreURL = "http://itunes.apple.com/us/lookup?bundleId=\(identifier)"

        return isTestFlight ? testflightURL : appStoreURL
    }

    private func getAppInfo(completion: @escaping (TestFlightInfo?, AppInfo?, Error?) -> Void) -> URLSessionDataTask? {

        guard let identifier = self.getBundle(key: "CFBundleIdentifier"),
              let url = URL(string: getUrl(from: identifier)) else {
                DispatchQueue.main.async {
                    completion(nil, nil, VersionError.invalidBundleInfo)
                }
                return nil
        }
        
        // You need to generate an authorization token to access the TestFlight versions and then you replace the ```***``` with the JWT token.
        // https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests
        
        let authorization = "Bearer ***"
        
        var request = URLRequest(url: url)
        
        // You just need to add an authorization header if you are checking TestFlight version
        if self.isTestFlight {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        // Make request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
                do {
                    if let error = error {
                        print(error)
                        throw error
                    }
                    guard let data = data else { throw VersionError.invalidResponse }
                    
                    let result = try JSONDecoder().decode(LookupResult.self, from: data)
                    //print(result)
                    
                    if self.isTestFlight {
                        let info = result.data?.first
                        completion(info, nil, nil)
                    } else {
                        let info = result.results?.first
                        completion(nil, info, nil)
                    }

                } catch {
                    completion(nil, nil, error)
                }
            }
        
        task.resume()
        return task

    }

    func getBundle(key: String) -> String? {

        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
          fatalError("Couldn't find file 'Info.plist'.")
        }
        // Add the file to a dictionary
        let plist = NSDictionary(contentsOfFile: filePath)
        // Check if the variable on plist exists
        guard let value = plist?.object(forKey: key) as? String else {
          fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
}

// MARK: - Show Alert
extension UIViewController {
    @objc fileprivate func showAppUpdateAlert(version : String, force: Bool, appURL: String, isTestFlight: Bool) {
        guard CheckUpdate.shared.getBundle(key: "CFBundleName") != nil else { return } //Bundle.appName()

        let alertTitle = "New version".localized()
        let alertMessage = "A new version of our app is available on the App Store. Update now!".localized()

        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        if !force {
            let notNowButton = UIAlertAction(title: "Not now".localized(), style: .default)
            alertController.addAction(notNowButton)
        }

        let updateButton = UIAlertAction(title: "Update".localized(), style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: appURL) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        alertController.addAction(updateButton)
        self.present(alertController, animated: true, completion: nil)
    }
}


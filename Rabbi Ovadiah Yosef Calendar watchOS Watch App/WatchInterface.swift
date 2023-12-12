//
//  WatchInterface.swift
//  Rabbi Ovadiah Yosef Calendar watchOS Watch App
//
//  Created by User on 12/10/23.
//

import Foundation
import WatchKit
import WatchConnectivity

class InterfaceController: WCSessionDelegate, ObservableObject {
    func isEqual(_ object: Any?) -> Bool {
        return true
    }
    
    var superclass: AnyClass?
    
    func `self`() -> Self {
        return self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    func isProxy() -> Bool {
        return true
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return true
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return true
    }
    
    @Published var hash: Int
    
    @Published var description: String
        
    init() {
        hash = 1
        description = "זמני יוסף"
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {}
    
    func sessionCompanionAppInstalledDidChange(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {}
    
    func sessionReachabilityDidChange(_ session: WCSession) {}
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            for (key, value) in message {
                if value as? Int == 0 {
                    UserDefaults.standard.set(false, forKey: key)
                    if key == "shabbatOffset" || key == "endOfShabbatOpinion" || key == "plagOpinion" || key == "tekufaOpinion" || key == "candleLightingOffset" {// ugly but it works
                        UserDefaults.standard.set(nil, forKey: key)
                    }
                } else if value as? Int == 1 {
                    UserDefaults.standard.set(true, forKey: key)
                } else {
                    UserDefaults.standard.set(value, forKey: key)
                }
            }
            UserDefaults.standard.setValue(true, forKey: "hasGottenDataFromApp")
            self.hash += 1
            self.objectWillChange.send()
        }
    }
}

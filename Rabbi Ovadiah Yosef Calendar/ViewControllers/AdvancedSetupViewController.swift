//
//  AdvancedSetupViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 8/15/23.
//

import UIKit
import KosherSwift
import WebKit

class AdvancedSetupViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    @IBAction func dowloadTFlink(_ sender: UIButton) {
        
        let presentingView = super.presentingViewController
        
        if linkTextField.text == nil || linkTextField.text == "" {
            return
        }
        
        let chaitables = ChaiTablesScraper(
            link: linkTextField.text!,
            locationName: GlobalStruct.geoLocation.locationName,
            jewishYear: JewishCalendar().getJewishYear(),
            defaults: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
)
        
        chaitables.scrape {
            chaitables.jewishYear = chaitables.jewishYear + 1
            chaitables.link = chaitables.link.replacingOccurrences(of: "&cgi_yrheb=".appending(String(JewishCalendar().getJewishYear())), with: "&cgi_yrheb=".appending(String(JewishCalendar().getJewishYear() + 1)))
            chaitables.scrape {}
            super.dismiss(animated: false) {
                presentingView?.dismiss(animated: false)
            }
        }
    }
    @IBOutlet weak var websiteButton: UIButton!
    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBAction func chaitablesLinkTF(_ sender: UITextField) {
        
    }
    @IBAction func websiteButton(_ sender: UIButton) {
        let webView = WKWebView()
        webView.load(URLRequest(url: URL(string: "https://bit.ly/3rhS55b")!))
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.navigationDelegate = self
        var message = "(I recommend you visit the website first.) \n\n Choose your area and on the next page all you need to do is to fill out steps 1 and 2, choose visible sunrise, and click the button on the bottom of the page to calculate the tables. \n\n Just make sure your search radius is big enough and the app will do the rest."
        if Locale.isHebrewLocale() {
            message = "(אני ממליץ לך לבקר קודם באתר.) בחר את האזור שלך ובעמוד הבא כל מה שאתה צריך לעשות הוא למלא את שלבים 1 ו-2, וללחוץ על הכפתור כדי לחשב את הטבלאות בתחתית העמוד .ודא שרדיוס החיפוש שלך גדול מספיק ועזוב את השנה היהודית בשקט. האפליקציה תעשה את השאר."
        }
        let alert = UIAlertController(title: "How to get info from chaitables.com".localized(), message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK".localized(), style: .default)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var back: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            websiteButton.configuration = .filled()
            websiteButton.tintColor = .init(named: "Gold")
            websiteButton.setTitleColor(.black, for: .normal)
            download.configuration = .filled()
            download.tintColor = .init(named: "Gold")
            download.setTitleColor(.black, for: .normal)

        }
        topLabel.text = "Provide a link below for ".localized().appending("\(GlobalStruct.geoLocation.locationName)")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if (webView.url?.absoluteString.starts(with: "http://chaitables.com/cgi-bin/") == true) {
            let presentingView = super.presentingViewController
            let url = assertCorrectURL(url: webView.url!.absoluteString)
            let chaitables = ChaiTablesScraper(link: url, locationName: GlobalStruct.geoLocation.locationName, jewishYear: JewishCalendar().getJewishYear(), defaults: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
)
            chaitables.scrape() {
                chaitables.jewishYear = chaitables.jewishYear + 1
                chaitables.link = chaitables.link.replacingOccurrences(of: "&cgi_yrheb=".appending(String(JewishCalendar().getJewishYear())), with: "&cgi_yrheb=".appending(String(JewishCalendar().getJewishYear() + 1)))
                chaitables.scrape {}
                super.dismiss(animated: false) {
                    presentingView?.dismiss(animated: false)
                }
            }
        }
    }
    
    func assertCorrectURL(url: String) -> String {
        var url = url
        if (url.contains("&cgi_types=0")) {
             url = url.replacingOccurrences(of: "&cgi_types=0", with: "&cgi_types=0");
         } else if (url.contains("&cgi_types=1")) {
             url = url.replacingOccurrences(of: "&cgi_types=1", with: "&cgi_types=0");
         } else if (url.contains("&cgi_types=2")) {
             url = url.replacingOccurrences(of: "&cgi_types=2", with: "&cgi_types=0");
         } else if (url.contains("&cgi_types=3")) {
             url = url.replacingOccurrences(of: "&cgi_types=3", with: "&cgi_types=0");
         } else if (url.contains("&cgi_types=4")) {
             url = url.replacingOccurrences(of: "&cgi_types=4", with: "&cgi_types=0");
         } else if (url.contains("&cgi_types=-1")) {
             url = url.replacingOccurrences(of: "&cgi_types=-1", with: "&cgi_types=0");
         }
        return url
    }
}

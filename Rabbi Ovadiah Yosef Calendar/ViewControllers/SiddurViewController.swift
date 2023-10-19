//
//  SiddurViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by User on 9/27/23.
//

import UIKit

class SiddurViewController: UIViewController {

    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var listOfTexts = Array<HighlightString>()
        
        if GlobalStruct.chosenPrayer == "Selichot" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getSelichotPrayers()
        }
        if GlobalStruct.chosenPrayer == "Shacharit" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getShacharitPrayers()
        }
        if GlobalStruct.chosenPrayer == "Mussaf" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMusafPrayers()
        }
        if GlobalStruct.chosenPrayer == "Mincha" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMinchaPrayers()
        }
        if GlobalStruct.chosenPrayer == "Neilah" {//will never show, but future proof it
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMusafPrayers()
        }
        if GlobalStruct.chosenPrayer == "Arvit" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getArvitPrayers()
        }
        
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.spacing = 12
                
        stackview.translatesAutoresizingMaskIntoConstraints = false
                
        scrollView.addSubview(stackview)
                
        for text in listOfTexts {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .right
            label.text = text.string
            label.font = .boldSystemFont(ofSize: 16)
            if text.shouldBeHighlighted {
                label.textColor = .black
                label.backgroundColor = .yellow
            }
            if text.string == "Mussaf is said here, press here to go to Mussaf" {
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(tap)
            }
            if text.string == "(Use this compass to help you find which direction South is in. Do not hold your phone straight up or place it on a table, hold it normally.) " +
                "עזר לך למצוא את הכיוון הדרומי באמצעות המצפן הזה. אל תחזיק את הטלפון שלך בצורה ישרה למעלה או תנה אותו על שולחן, תחזיק אותו בצורה רגילה.:" {
//                let compassImageView = UIImageView(image: UIImage(named: "compass"))
//                compassImageView.contentMode = .scaleAspectFit // Adjust the content mode as needed
//                stackview.addArrangedSubview(compassImageView)//TODO
                label.text = ""
            }
            stackview.addArrangedSubview(label)
        }
        
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackview.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackview.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackview.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            stackview.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }
    
    @IBAction func tapFunction(sender: UITapGestureRecognizer) {
        GlobalStruct.chosenPrayer = "Mussaf"
        super.dismiss(animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "Siddur") as! SiddurViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.presentingViewController?.present(newViewController, animated: false)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
    
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var textView: UITextView!
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
        
        var fullText = ""
        
        for text in listOfTexts {
            fullText += text.string
            fullText += "\n\n"
        }
        textView.text = fullText
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

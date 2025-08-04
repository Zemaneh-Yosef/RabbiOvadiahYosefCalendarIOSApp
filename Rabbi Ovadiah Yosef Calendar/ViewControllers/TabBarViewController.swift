//
//  TabBarViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 9/18/24.
//

import UIKit
import KosherSwift

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 1
        if (GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT ||
                            (GlobalStruct.jewishCalendar.getUpcomingParshah() == JewishCalendar.Parsha.BESHALACH &&
                             GlobalStruct.jewishCalendar.getDayOfWeek() == 3)) {// if disclaimers will be shown in siddur
            self.tabBar.items?.last?.badgeValue = ""
        }
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

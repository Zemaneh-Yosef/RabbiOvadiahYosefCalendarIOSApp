# Rabbi Ovadiah Yosef Calendar IOS App

<table>
  <tr>
    <td align="center" width="33%"><strong>App Store and source code:</strong></td>
    <td align="center" width="33%"><strong>Google Play Store and source code:</strong></td>
    <td align="center" width="33%"><strong>Website and source code:</strong></td>
  </tr>
  <tr>
      <td align="center" width="33%">
      <a href="https://apps.apple.com/app/rabbi-ovadiah-yosef-calendar/id6448838987">
        <img alt="Get it on the App Store" src="https://ci6.googleusercontent.com/proxy/HrtBTHlFE3VpRkzLfRwnYbJjCLtCpmKOIV__qk9k9mj7e7PSZF2X0L7mzR63nCIfqbnUujbn-dhiq-LwYUqdcpSLg_ItRhdEQJ0wP438309hcA=s0-d-e1-ft#https://static.licdn.com/aero-v1/sc/h/76yzkd0h5kiv27lrd4yaenylk" width="200px">
      </a>
      <br>
      <a href="https://github.com/Zemaneh-Yosef/RabbiOvadiahYosefCalendarIOSApp">
        <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="50px" alt="GitHub">
      </a>
    </td>
    <td align="center" width="33%">
      <a href="https://play.google.com/store/apps/details?id=com.EJ.ROvadiahYosefCalendar&amp;pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1">
        <img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png" width="200px">
      </a>
      <br>
      <a href="https://github.com/Zemaneh-Yosef/RabbiOvadiahYosefCalendarApp">
        <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="50px" alt="GitHub">
      </a>
    </td>
    <td align="center" width="33%">
      <a href="https://royzmanim.com/">
        <img src="https://cdn-icons-png.flaticon.com/512/5602/5602732.png" width="100px" alt="Website">
      </a>
      <br>
      <a href="https://github.com/Zemaneh-Yosef/royzmanimwebsite">
        <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="50px" alt="GitHub">
      </a>
    </td>
  </tr>
</table>

The goal of this app is to recreate the "Luach HaMaor Ohr HaChaim" calendar that is widespread in Israel. This calendar is special because Rabbi Ovadiah Yosef ZT"L oversaw it's creation and used the calendar himself until he passed:

<img src="https://i.imgur.com/QqGAtTB.jpg" height="750">

In order to recreate the calendar, I needed an API that would give me the times for sunrise and sunset everyday (since all the other zmanim are based on these times). I was recommended the well known [KosherJava](https://github.com/KosherJava/zmanim) package, and that is the basis for all of the app's zmanim (time) calculations.
KosherJava was made for Java applications which made it perfect for the android app. However, iOS runs on swift/objective-c. Moshe Berman created an objective-c port called [KosherCocoa](https://github.com/MosheBerman/KosherCocoa), however, with KosherCocoa many classes and methods were missing from the package. In the end, I recreated the entire KosherJava project into my own repository and called it, [KosherSwift](https://github.com/Elyahu41/KosherSwift)

The only zman/time that could not be computed by the KosherJava/KosherCocoa API is the sunrise time that the Ohr HaChayim calendar uses. They explain in the calendar introduction that they take the sunrise times from a calendar called, "Luach Bechoray Yosef". That calendar calculates the time for sunrise by taking into account the geography of the land around that area and finding when is the first time the sun is seen in that area (based on the introduction to Chaitables.com). While not impossible, this would take a massive toll on a mobile phone's processor and memory, therefore, the app does not support it. However, I discovered that the creator of this calendar made a website [ChaiTables.com](http://chaitables.com) to help people use his algorithm for sunrise/sunset all over the world and create a 12 month table based on your input. I added the ability to download these times in the app with your own specific parameters. (I highly recommend that you see the introduction on chaitables.com.)


Daily view of the app:

![alt text](https://i.imgur.com/F9M29Zt.png)

# Explanation of how the zmanim are calculated:
- For an in-depth explanation on each specific time, please look at the descriptions for each individual time, found in the app-itself.
- For an overall explanation, please visit our organization's ReadME on GitHub.


# Introduction to the calendar in Israel:

<img src="http://www.zmanim-diffusion.com/images/1.jpg" height="650">
<img src="https://i.imgur.com/udfwy3R.jpg" height="650">
<img src="https://i.imgur.com/ureV4p4.jpg" height="650">
<img src="https://i.imgur.com/HXEzXvr.jpg" height="650">

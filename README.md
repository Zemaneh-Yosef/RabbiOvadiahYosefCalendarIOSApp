# Rabbi Ovadiah Yosef Calendar (iOS) App

<p align="center">
	<img src="https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/cc/4f/de/cc4fded5-598f-1f3a-eaa6-26405d119a93/AppIcon-0-0-1x_U007epad-0-11-0-85-220.png/217x0w.webp" width="200px" alt="logo">
</p>

<table align="center">
  <tr>
    <td align="center" width="33%"><strong>App Store</strong></td>
    <td align="center" width="33%"><strong>Google Play Store</strong></td>
    <td align="center" width="33%"><strong>Website</strong></td>
  </tr>
  <tr>
   <td align="center" width="33%">
      <a href="https://apps.apple.com/app/rabbi-ovadiah-yosef-calendar/id6448838987">
        <img alt="Get it on the App Store" src="https://ci6.googleusercontent.com/proxy/HrtBTHlFE3VpRkzLfRwnYbJjCLtCpmKOIV__qk9k9mj7e7PSZF2X0L7mzR63nCIfqbnUujbn-dhiq-LwYUqdcpSLg_ItRhdEQJ0wP438309hcA=s0-d-e1-ft#https://static.licdn.com/aero-v1/sc/h/76yzkd0h5kiv27lrd4yaenylk" width="200px">
      </a>
    </td>
    <td align="center" width="33%">
      <a href="https://play.google.com/store/apps/details?id=com.EJ.ROvadiahYosefCalendar&amp;pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1">
        <img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png" width="200px">
      </a>
    </td>
    <td align="center" width="33%">
      <a href="https://royzmanim.com/">
        <img src="https://cdn-icons-png.flaticon.com/512/5602/5602732.png" width="100px" alt="Website">
      </a>
    </td>
  </tr>

  <tr>
    <td align="center" width="33%"><strong>Source Code</strong></td>
    <td align="center" width="33%"><strong>Source Code</strong></td>
    <td align="center" width="33%"><strong>Source Code</strong></td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <a href="https://github.com/Zemaneh-Yosef/RabbiOvadiahYosefCalendarIOSApp">
        <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="50px" alt="GitHub">
      </a>
    </td>
    <td align="center" width="33%">
      <a href="https://github.com/Zemaneh-Yosef/RabbiOvadiahYosefCalendarAndroidApp">
        <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="50px" alt="GitHub">
      </a>
    </td>
    <td align="center" width="33%">
      <a href="https://github.com/Zemaneh-Yosef/royzmanimwebsite">
        <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="50px" alt="GitHub">
      </a>
    </td>
  </tr>
</table>

# Goal of the project:
The goal original of this project was to recreate the "Luach HaMaor Ohr HaChaim" calendar that is widespread in Israel. This calendar is special because Rabbi Ovadiah Yosef ZT"L oversaw it's creation and used the calendar himself until he passed. It is considered to be the most accurate calendar for people who want to follow Rabbi Ovadia Yosef's practices:

<img src="https://i.imgur.com/QqGAtTB.jpg" height="750" alt="Picture of Ohr HaChaim calendar">

In order to recreate the calendar, we needed an API that would give the times for sunrise and sunset everyday (since all the other zemanim (times) are based on sunrise/sunset). I was recommended the well known [KosherJava](https://github.com/KosherJava/zmanim) package for it's accuracy and transparency, and that is the basis for all of the app's calculations. While originally, we used KosherCocoa as a basis for the calculations. It was not as fleshed out as KosherJava, therefore, I made [KosherSwift](https://github.com/Elyahu41/KosherSwift) as a Swift port.

The app was originally made for primarily english speakers, however, it has been localized for both english and hebrew speakers.

The only zeman that could not be computed by the KosherJava API is the sunrise time that the Ohr HaChaim calendar uses. They explain in the calendar introduction that they take the sunrise times from a calendar called, "Luach Bechoray Yosef". That calendar calculates the time for sunrise by taking into account the geography of the land around that area and finding when is the first time the sun is seen in that area (based on the introduction to Chaitables.com). While not impossible, this would take a massive toll on a mobile phone's processor and memory, therefore, the app does not support it. However, I discovered that the creator of this calendar made a website [ChaiTables.com](http://chaitables.com) to help people use his algorithm for sunrise/sunset all over the world and create a 12 month table based on your input. I added the ability to download these times in the app with your own specific parameters. (It is highly recommended that you see the introduction on chaitables.com.)

After the Ohr HaChaim calendar was implemented and fully functional, we implemented Rabbi Leeor Dahan's calendar for areas outside of Israel. The Ohr HaChaim calendar was made for Israel and it needed a few adjustments to be applicable for outside of Israel. We confirmed this with both of Rabbi Ovadia Yosef's sons (Rabbi Yitzhak Yosef and Rabbi David Yosef).

Rabbi Meir Gavriel Elbaz and Rabbi Leeor Dahan themselves have given [haskamot](https://royzmanim.com/) for this project, and with their help we were able to even receive a [haskama](https://royzmanim.com/assets/haskamah-rishon-letzion.pdf) from Rabbi Yitzhak Yosef.

# App Screenshots:
| <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/75/f7/24/75f72459-c2d9-b0e0-4ef4-202a3c2594d2/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-27_at_16.53.24.png/230x0w.webp"> | <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/dd/06/e3/dd06e3e5-06bd-4937-a157-83013e9e3483/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-25_at_03.26.28.png/230x0w.webp"> | <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/8f/c5/e6/8fc5e6e6-cc98-1896-adf0-0e18c7e44716/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-25_at_03.28.06.png/230x0w.webp"> | <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/5c/ce/7c/5cce7c64-3281-a635-6136-c84814c9e6bd/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-25_at_03.28.49.png/230x0w.webp"> |
| ---------------------------------------------- | -------------------------------------------- | ------------------------------------------ | ------------------------------------------- |

| <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/cc/1d/b7/cc1db7e1-d73a-f049-b13e-ea72e1cac2e3/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-25_at_03.29.48.png/230x0w.webp"> | <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/3f/92/84/3f9284fb-d69a-81cb-25fd-c9ef80c28225/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-25_at_03.30.54.png/230x0w.webp"> | <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/ab/74/39/ab7439db-2a35-e5dc-946c-2f69b3025331/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-25_at_03.31.55.png/230x0w.webp"> | <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/8d/aa/62/8daa62a8-15cf-0e85-b922-2f5f780386bf/Simulator_Screenshot_-_iPhone_16_Pro_-_2025-05-25_at_03.32.44.png/230x0w.webp"> |
| ---------------------------------------------- | -------------------------------------------- | ------------------------------------------ | ------------------------------------------- |

# Explanation of how the zemanim are calculated:
- For an in-depth explanation on each specific time, please look at the descriptions for each individual time, found in the app-itself.
- For an overall explanation, please visit our organization's ReadME on GitHub.
- For an explanation on the differences between outside of Israel and inside of Israel or whether or not to use elevation, please visit our [FAQ](https://royzmanim.com/FAQ)

# Introduction and haskama to the calendar in Israel:

| <img src="https://royzmanim.com/assets/images/sources/OHhaskama.png" height="250" alt="haskama"> | <img src="https://royzmanim.com/assets/images/sources/intro1.png" height="250" alt="intro 1"> | <img src="https://royzmanim.com/assets/images/sources/intro2.png" height="250" alt="intro 2"> | <img src="https://royzmanim.com/assets/images/sources/intro3.png" height="250" alt="intro 3"> |
| ---------------------------------------------- | -------------------------------------------- | ------------------------------------------- | ------------------------------------------- |

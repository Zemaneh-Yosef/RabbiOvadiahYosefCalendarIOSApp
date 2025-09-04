//
//  ChaiTablesOptionsList.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 7/24/23.
//

import Foundation

class ChaiTablesLinkGenerator {
    
    let countries: [String] = [
        "Argentina", "Australia", "Austria", "Belgium", "Brazil",
        "Bulgaria", "Canada", "Chile", "China", "Colombia", "Czech-Republic", "Denmark",
        "Eretz_Yisroel (Cities)", // becomes Eretz_Yisroel in the link
        "Eretz_Yisroel (Neighborhoods)", // becomes Israel in the link
        "France", "Germany", "Greece", "Hungary", "Italy", "Mexico", "Netherlands", "Panama", "Poland", "Romania",
        "Russia", "South-Africa", "Spain", "Switzerland", "Turkey",
        "UK and Ireland", // becomes England in the link
        "Ukraine", "Uruguay", "USA", "Venezuela"
    ]
    
    var selectedCountry = ""
    
    var metropolitanAreas = Array<String>()
    
    var selectedMetropolitanArea = ""
    
    func selectCountry(country: ChaiTablesCountries) -> Array<String> {
        switch (country) {
        case ChaiTablesCountries.ARGENTINA:
            initMetropolitanAreaArgentina()
            break
        case ChaiTablesCountries.AUSTRALIA:
            initMetropolitanAreaAustralia()
            break
        case ChaiTablesCountries.AUSTRIA:
            initMetropolitanAreaAustria()
            break
        case ChaiTablesCountries.BELGIUM:
            initMetropolitanAreaBelgium()
            break
        case ChaiTablesCountries.BRAZIL:
            initMetropolitanAreaBrazil()
            break
        case ChaiTablesCountries.BULGARIA:
            initMetropolitanAreaBulgaria()
            break
        case ChaiTablesCountries.CANADA:
            initMetropolitanAreaCanada()
            break
        case ChaiTablesCountries.CHILE:
            initMetropolitanAreaChile()
            break
        case ChaiTablesCountries.CHINA:
            initMetropolitanAreaChina()
            break
        case ChaiTablesCountries.COLOMBIA:
            initMetropolitanAreaColombia()
            break
        case ChaiTablesCountries.CZECH_REPUBLIC:
            initMetropolitanAreaCzechRepublic()
            break
        case ChaiTablesCountries.DENMARK:
            initMetropolitanAreaDenmark()
            break
        case ChaiTablesCountries.ERETZ_YISROEL_NEIGHBORHOODS:
            initMetropolitanAreaIsrael()
            break
        case ChaiTablesCountries.ERETZ_YISROEL_CITIES:
            initMetropolitanAreaEretzYisroel()
            break
        case ChaiTablesCountries.FRANCE:
            initMetropolitanAreaFrance()
            break
        case ChaiTablesCountries.GERMANY:
            initMetropolitanAreaGermany()
            break
        case ChaiTablesCountries.GREECE:
            initMetropolitanAreaGreece()
            break
        case ChaiTablesCountries.HUNGARY:
            initMetropolitanAreaHungary()
            break
        case ChaiTablesCountries.ITALY:
            initMetropolitanAreaItaly()
            break
        case ChaiTablesCountries.MEXICO:
            initMetropolitanAreaMexico()
            break
        case ChaiTablesCountries.NETHERLANDS:
            initMetropolitanAreaNetherlands()
            break
        case ChaiTablesCountries.PANAMA:
            initMetropolitanAreaPanama()
            break
        case ChaiTablesCountries.POLAND:
            initMetropolitanAreaPoland()
            break
        case ChaiTablesCountries.ROMANIA:
            initMetropolitanAreaRomania()
            break
        case ChaiTablesCountries.RUSSIA:
            initMetropolitanAreaRussia()
            break
        case ChaiTablesCountries.SOUTH_AFRICA:
            initMetropolitanAreaSouthAfrica()
            break
        case ChaiTablesCountries.SPAIN:
            initMetropolitanAreaSpain()
            break
        case ChaiTablesCountries.SWITZERLAND:
            initMetropolitanAreaSwitzerland()
            break
        case ChaiTablesCountries.TURKEY:
            initMetropolitanAreaTurkey()
            break
        case ChaiTablesCountries.UK_AND_IRELAND:
            initMetropolitanAreaUKandIreland()
            break
        case ChaiTablesCountries.UKRAINE:
            initMetropolitanAreaUkraine()
            break
        case ChaiTablesCountries.URUGUAY:
            initMetropolitanAreaUruguay()
            break
        case ChaiTablesCountries.USA:
            initMetropolitanAreaUSA()
            break
        case ChaiTablesCountries.VENEZUELA:
            initMetropolitanAreaVenezuela()
            break
        }
        selectedCountry = country.label
        return metropolitanAreas
    }
    
    func selectMetropolitanArea(metropolitanArea:String) {
        if metropolitanAreas.isEmpty {
            return
        }
        selectedMetropolitanArea = metropolitanArea
    }
    
    func getChaiTablesLink(lat:Double, long:Double, timezone:Int, searchRadius:Int, type:Int, year:Int, userId:Int) ->String {
        if (type < 0 || type > 5) {
            return ""
        }
        
        let longSwitched = -long
        
        if (selectedCountry == "Eretz_Yisroel") {
            return getChaiTablesEretzYisroelLink(type: type, year: year, userId: userId)
        }
        
        var searchRadiusIsrael = 0
        if (selectedCountry == "Israel") {
            searchRadiusIsrael = 2;//recommended radius for Israel only for some reason. Everywhere else the site defaults to 8(km).
        }
                
        return "http://www.chaitables.com/cgi-bin/ChaiTables.cgi/?cgi_TableType=Chai&cgi_country=\(selectedCountry)&cgi_USAcities1=\(metropolitanAreas.firstIndex(of: selectedMetropolitanArea)! + 1)&cgi_USAcities2=0&cgi_searchradius=\(searchRadiusIsrael == 2 ? 2 : searchRadius)&cgi_Placename=?&cgi_eroslatitude=\(lat)&cgi_eroslongitude=\(longSwitched)&cgi_eroshgt=0.0&cgi_geotz=\(timezone)&cgi_exactcoord=OFF&cgi_MetroArea=jerusalem&cgi_types=\(type)&cgi_RoundSecond=1&cgi_AddCushion=0&cgi_24hr=&cgi_typezman=-1&cgi_yrheb=\(year)&cgi_optionheb=1&cgi_UserNumber=\(userId)&cgi_Language=English&cgi_AllowShaving=OFF"
    }
    
    func getChaiTablesEretzYisroelLink(type:Int, year:Int, userId:Int) -> String {
        return "http://www.chaitables.com/cgi-bin/ChaiTables.cgi/?cgi_TableType=BY&cgi_country=\(selectedCountry)&cgi_USAcities1=1&cgi_USAcities2=0&cgi_searchradius=&cgi_Placename=?&cgi_eroslatitude=0.0&cgi_eroslongitude=0.0&cgi_eroshgt=0.0&cgi_geotz=2&cgi_exactcoord=OFF&cgi_MetroArea=\(selectedMetropolitanArea)&cgi_types=\(type)&cgi_RoundSecond=-1&cgi_AddCushion=0&cgi_24hr=&cgi_typezman=-1&cgi_yrheb=\(year)&cgi_optionheb=1&cgi_UserNumber=\(userId)&cgi_Language=English&cgi_AllowShaving=OFF"
    }
    
    private func initMetropolitanAreaArgentina() {
        metropolitanAreas = [
            "Buenos-Aires_area_Argentina",
            "Concordia_area_Argentina",
            "Salto_area_Argentina"]
    }
    
    private func initMetropolitanAreaAustralia() {
        metropolitanAreas = [
            "Melbourne_area_Australia",
            "Sydney_area_Australia"
        ]
    }
    
    private func initMetropolitanAreaAustria() {
        metropolitanAreas = [
            "Vienna_area_Austria"
        ]
    }

    private func initMetropolitanAreaBelgium() {
        metropolitanAreas = [
            "Antwerpen_area_Belgium",
            "Bruxelles_area_Belgium"
        ]
    }

    private func initMetropolitanAreaBrazil() {
        metropolitanAreas = [
            "Rio-de-Janeiro_area_Brazil",
            "Sao_Paulo_area_Brazil"
        ]
    }

    private func initMetropolitanAreaBulgaria() {
        metropolitanAreas = [
            "Sofia_area_Bulgaria"
        ]
    }

    private func initMetropolitanAreaCanada() {
        metropolitanAreas = [
            "Calgary_area_AB",
            "Edmonton_area_AB",
            "Fredericton_area_NB",
            "Halifax_area_NS",
            "Hamilton_area_ON",
            "Kitchener_area_ON",
            "London_area_ON",
            "Montreal_area_QC",
            "Ottawa_area_ON",
            "Regina_area_SK",
            "Toronto_area_ON",
            "Vancouver_area_BC",
            "Windsor_area_ON",
            "Winnipeg_area_MB"
        ]
    }

    private func initMetropolitanAreaChile() {
        metropolitanAreas = [
            "Santiago_area_Chile"
        ]
    }

    private func initMetropolitanAreaChina() {
        metropolitanAreas = [
            "Hong-Kong_area_China"
        ]
    }

    private func initMetropolitanAreaColombia() {
        metropolitanAreas = [
            "Bogota_area_Colombia",
            "Cali_area_Colombia"
        ]
    }

    private func initMetropolitanAreaCzechRepublic() {
        metropolitanAreas = [
            "Prague_area_Czech-Republic"
        ]
    }

    private func initMetropolitanAreaDenmark() {
        metropolitanAreas = [
            "Copenhagen_area_Denmark"
        ]
    }

    private func initMetropolitanAreaEretzYisroel() {
        metropolitanAreas = [
            "acco",
            "achiezer",
            "achisamach",
            "achituv",
            "achuzam",
            "aderet",
            "adiad",
            "afulah",
            "agur",
            "airport",
            "alefei_menasheh",
            "almah",
            "almon",
            "alonei_habashan",
            "alon_moreh",
            "alon_shvut",
            "aluma",
            "alumim",
            "amazia",
            "amichai",
            "amkah",
            "amukah",
            "amuna",
            "arad",
            "ariel",
            "ashdod",
            "ashkolon",
            "ateret",
            "atlit",
            "aviezer",
            "avnei_chafetz",
            "avnei_eiton",
            "azrikam",
            "barak",
            "bareket",
            "barkan-beit_abah",
            "bat_iyen B",
            "bat_shlomo",
            "beerot_yitzhak",
            "beersheva",
            "beer_tuviah",
            "beer_yaakov",
            "beetar_eilit",
            "beit_ariyeh",
            "beit_chagai",
            "beit_chelkiah",
            "beit_choron",
            "beit_dagan",
            "beit_el",
            "beit_gamliel",
            "beit_hagedi",
            "beit_hillel",
            "beit_meir",
            "beit_rimon",
            "beit_shemes_(old-part)",
            "beit_shean",
            "beit_shemes_combined",
            "beit_uziel",
            "beit_yehoshuah",
            "beit_yosef",
            "ben_zakai",
            "berechiah-hodayah",
            "binyaminah",
            "birea",
            "bnei_ayish",
            "bnei_atarot",
            "bnei_brak_Zuriel",
            "bnei_brak-ramat_gan-givatiyim",
            "bnei_darom",
            "bnei_dekalim",
            "bnei_netzarim",
            "bnei_reem",
            "brosh",
            "burgatah",
            "caesarea",
            "calanit",
            "carmel",
            "carmiel",
            "chaderah",
            "chadid",
            "chalamish",
            "chamat_geder",
            "chasmonaim",
            "chavat_hashomer",
            "chazon",
            "chazor_haglilit-rosh_pinah",
            "chemed",
            "cherev-laat_elyachin-kfar_haraah",
            "chermash",
            "chevel_shalom",
            "chofetz_chaim",
            "chofit",
            "chof_kinar",
            "chorasha",
            "dalton",
            "dimonah",
            "dolev",
            "dovev",
            "efrata",
            "eilat",
            "einav",
            "ein_ayalah",
            "ein_bokek",
            "ein_gedi_(kibbutz)",
            "ein_gev",
            "ein_hanaziv",
            "ein_yaakov",
            "ein_zurim",
            "eitan",
            "eitanim",
            "elad",
            "elazar",
            "eli",
            "eliav",
            "elipelet",
            "elkanah",
            "elyakim",
            "emanuel",
            "eshbol",
            "eshtaohl",
            "etz_efraim",
            "even_menachem",
            "even_shmuel",
            "even_yehuda",
            "gaderah",
            "gadid",
            "gamzu",
            "gan_ohr",
            "gan_yavneh",
            "gefen",
            "geulei_teman",
            "gevah_binyamin",
            "gibolim-melilot",
            "gilat",
            "ginton",
            "gitit",
            "givat_washington",
            "givat_yitzhar",
            "givat_yaarim",
            "givat_zeev",
            "givat_zeev_agan_haayalot",
            "givat_zeev_agan_haayalot_combined",
            "givat_adah",
            "givon_hachadasha",
            "gush_chizpin",
            "gush_dan",
            "haifa",
            "har_bracha",
            "har_gilo",
            "har_shmuel",
            "har_yona",
            "Harish",
            "hazorim",
            "hebron-kirat_arbah",
            "Herzliah_A-kfar_smaryahu",
            "Herzliah_B-ramat_hasharon",
            "hinanit-shaked-tal_menashe",
            "hosen",
            "hoshayahu",
            "itamar",
            "jerusalem",
            "kadima",
            "karmei_katif",
            "karmei_zur",
            "karnei_shomron",
            "kazrin",
            "kedumim",
            "kerem_ben_zimrah",
            "kesalon",
            "keshet",
            "kever_schmuel_hanavi_roof",
            "kever_rachel-beit_lechem",
            "kever_rebbi_meir_baal_hanes",
            "kever_yonatan_ben_uziel",
            "kfar_adumim",
            "kfar_chanannia",
            "kfar_chabad",
            "kfar_chasidim-rechesim",
            "kfar_etzion",
            "kfar_gidon",
            "kfar_menachem",
            "kfar_rosh_hanikra",
            "kfar_sabah-raananah",
            "kfar_sirkin",
            "kfar_shamai",
            "kfar_tapuach",
            "kfar_tavor",
            "kfar_veradim",
            "kfar_yonah",
            "kfar_yaabez-ezriel",
            "kfar_zeitim",
            "kibutz_yavneh",
            "kiriat_anavim",
            "kiriat_atah",
            "kiriat_ekron",
            "kiriat_gat",
            "kiriat_malachi",
            "kiriat_netafim",
            "kiriat_ohno-sabion-yehud",
            "kiriat_sefer",
            "kiriat_sefer_water_tower",
            "kiriat_shemonah",
            "kiriat_tivon",
            "kiriat_yaarim-camp",
            "kiriat-yam-mozkin-bialik",
            "kochav_hashachar",
            "kochav_yair",
            "komemiut",
            "lachish",
            "lavi",
            "lod",
            "lod_Ben_Gurion_airport",
            "maaleh_gilboah",
            "maaleh_michmash",
            "maaleh_amos",
            "maaleh_adumim-mizpeh_navoh",
            "maaleh_efraim",
            "maaleh_levonah",
            "maaleh_shomron",
            "maalot_tarsicha",
            "macabim",
            "macheneh_yatir",
            "machsiah",
            "malchishuah",
            "manof",
            "maon",
            "Marchavei_David",
            "margaliyyot",
            "masada",
            "maskiot",
            "masuot_yizhak",
            "matah",
            "matityahu",
            "mazkeret_batiah",
            "mazor",
            "mecholah",
            "megadim",
            "meiron",
            "meitar",
            "menachemiah",
            "menucha",
            "meoz_zion",
            "mercaz_shapirah",
            "metulah_top",
            "metulah_bottom",
            "metzad",
            "mevaseret_zion",
            "mevaseret_zion_area_(combined)",
            "mevoh_modyim",
            "mevoh_charon",
            "mevoh_dotan",
            "mevoot_yericho",
            "meyrav",
            "migdal",
            "migdalim",
            "migdal_oz",
            "migdal_haemek",
            "misgav",
            "mishmar_hayarden",
            "mizadot_yehudah",
            "mizpeh_netofa",
            "mizpeh_nevoh",
            "mizpeh_ramon",
            "mizpeh_yericho",
            "modiin",
            "modiin_illit",
            "morag",
            "moreshet",
            "mozah",
            "mozah_elit",
            "naaleh",
            "nachalim",
            "nacham",
            "nachliel",
            "nahariah",
            "nataf",
            "natanyah",
            "Naveh",
            "nazaret_eilit",
            "nechushah",
            "neriah",
            "nes_harim",
            "nes_zionah",
            "neta",
            "netivot",
            "Netua",
            "neveh_daniel",
            "neveh_ziv",
            "nili",
            "nirit",
            "nir_etzion",
            "nir_galim",
            "nizan",
            "noam",
            "noga",
            "nokdim",
            "ofakim",
            "ofra",
            "ohel_nachum_tiberias",
            "ohra",
            "ohr_akibah",
            "ohr_haganuz",
            "ohr_yehudah-ramat_pinkas-neveh_efraim",
            "omer",
            "otniel",
            "ozem",
            "paamei_tashas",
            "pakiin_chadashah",
            "pardes_channah",
            "patish",
            "peduel",
            "pesagot",
            "petach_tikvah",
            "pnei_chever",
            "porat",
            "poriah_naveh_oved",
            "poriah_eilit",
            "raananah-kfar_sabah",
            "rachov",
            "ramat_beit_shemes",
            "ramat_beit_shemes_gimmel",
            "ramat_raziel",
            "ramat_yishai",
            "ramat_magshimim",
            "ramlah",
            "ramon_airbase",
            "ramot_sesh",
            "rechovot",
            "reut",
            "revacha",
            "revava",
            "revayah",
            "rimonim",
            "rishon_lezion-nachalat_yehudah",
            "rosh_haeiin",
            "rosh_pinah-chazor_haglilit",
            "rosh_zurim",
            "saad",
            "sadeh_eliyahu",
            "sadeh_trumot",
            "sadeh_yaakov",
            "sadeh_elan",
            "safed",
            "sah_nor",
            "schem",
            "schlomi",
            "sedei_chemed",
            "sederot",
            "shaalvim",
            "shaarei_avraham",
            "shaarei_tikvah",
            "Shaar_Yeshuv",
            "shadmot_mechulah",
            "shagav",
            "shalvah",
            "sharsheret",
            "shavei_shomron",
            "shebolim",
            "shiloh",
            "shimah",
            "shlomit",
            "shluchot",
            "shoeva",
            "shoham",
            "shokdah",
            "Shomera",
            "shomriya",
            "shvut_rachel",
            "susiah",
            "talmon",
            "taoz",
            "tarom",
            "tefachot",
            "tekoa",
            "tekumah",
            "telz_stone_ravshulman",
            "telz_stone_all_mountains",
            "tel_aviv-bat_yam-cholon",
            "tel_zion_kochav_yaakov",
            "tenah",
            "tiberias_eilit",
            "tiberias_old",
            "tifrach",
            "tirat_yehudah",
            "tirat_zvi",
            "tirat_carmel",
            "tirosh",
            "toshiah-kfar_mimon",
            "vered_yericho",
            "yaara",
            "yad_binyamin",
            "yad_rambam",
            "yakir",
            "yavneel",
            "yavneh",
            "yeruchom",
            "yesodot",
            "yesod_hamaalah",
            "yishai",
            "yitzhar",
            "yokneam_illit",
            "yonatan",
            "yoshiveah",
            "yotvatah",
            "zafriah",
            "zanoach",
            "Zarit",
            "zavdiel",
            "zealim",
            "zecharya",
            "zerachia",
            "zeruah",
            "zichron_yaakov",
            "zimrat-shuvah",
            "zipori",
            "zohar",
            "zufim",
            "zuriel",
            "zur_hadassah"
        ]
    }
    
    private func initMetropolitanAreaIsrael() {
        metropolitanAreas = [
            "Beit-Shemes_area_Israel",
            "Haifa_area_Israel",
            "Jerusalem_area_Israel",
            "Safed_area_Israel",
            "Tiberias_area_Israel"
        ]
    }

    private func initMetropolitanAreaFrance() {
        metropolitanAreas = [
            "Aix-En-Provence_area_France",
            "Aix-Les-Bains_area_France",
            "Colmar_area_France",
            "Grenoble_area_France",
            "Lille_area_France",
            "Lyon_area_France",
            "Marseille_area_France",
            "Metz_area_France",
            "Mulhouse_area_France",
            "Nantes_area_France",
            "Nice_area_France",
            "Nimes_area_France",
            "Paris_area_France",
            "Strasbourg_area_France",
            "Toulon_area_France",
            "Toulouse_area_France",
            "Troyes_area_France",
            "Vichy_area_France"
        ]
    }

    private func initMetropolitanAreaGermany() {
        metropolitanAreas = [
            "Bad-Nauheim_area_Germany",
            "Berlin_area_Germany",
            "Frankfurt_area_Germany",
            "Hamburg_area_Germany",
            "Hannover_area_Germany",
            "Munich_area_Germany"
        ]
    }

    private func initMetropolitanAreaGreece() {
        metropolitanAreas = [
            "Athens_area_Greece"
        ]
    }

    private func initMetropolitanAreaHungary() {
        metropolitanAreas = [
            "Budapest_area_Hungary"
        ]
    }

    private func initMetropolitanAreaItaly() {
        metropolitanAreas = [
            "Bologna_area_Italy",
            "Florence_area_Italy",
            "Milan_area_Italy",
            "Rome_area_Italy"
        ]
    }

    private func initMetropolitanAreaMexico() {
        metropolitanAreas = [
            "Cuernevaca_Morelos_area",
            "Mexico-City_area_Mexico"
        ]
    }

    private func initMetropolitanAreaNetherlands() {
        metropolitanAreas = [
            "Amsterdam_area_Netherlands"
        ]
    }

    private func initMetropolitanAreaPanama() {
        metropolitanAreas = [
            "Panama-City_area_Panama"
        ]
    }

    private func initMetropolitanAreaPoland() {
        metropolitanAreas = [
            "Krakow_area_Poland"
        ]
    }

    private func initMetropolitanAreaRomania() {
        metropolitanAreas = [
            "Bucharest_area_Romania"
        ]
    }

    private func initMetropolitanAreaRussia() {
        metropolitanAreas = [
            "Moscow_area_Russia"
        ]
    }

    private func initMetropolitanAreaSouthAfrica() {
        metropolitanAreas = [
            "Cape_Town_area_South-Africa",
            "Johannesburg_area_South-Africa"
        ]
    }

    private func initMetropolitanAreaSpain() {
        metropolitanAreas = [
            "Barcelona_area_Spain",
            "Madrid_area_Spain",
            "Malaga_area_Spain",
            "Marbella_area_Spain",
            "Melilla_area_Spain"
        ]
    }

    private func initMetropolitanAreaSwitzerland() {
        metropolitanAreas = [
            "Basel_area_Switzerland",
            "Einsiedeln_area_Switzerland",
            "Geneve_area_Switzerland",
            "Lausanne_area_Switzerland",
            "Lugano_area_Switzerland",
            "Luzern_area_Switzerland",
            "Zurich_area_Switzerland"
        ]
    }

    private func initMetropolitanAreaTurkey() {
        metropolitanAreas = [
            "Antalya_area_Turkey",
            "Istanbul_area_Turkey"
        ]
    }

    private func initMetropolitanAreaUKandIreland() {
        metropolitanAreas = [
            "Belfast_area_Northern-Ireland",
            "Birmingham_area_UK",
            "Cardiff_area_UK",
            "Dublin_area_Ireland",
            "Edinburgh_area_UK",
            "Gateshead-Newcastle_area_UK",
            "Glasgow_area_UK",
            "Leeds_area_UK",
            "Leicester_area_UK",
            "Liverpool_area_UK",
            "London_area_UK",
            "Manchester_area_UK",
            "Southend-On-Sea_area_UK",
            "Southport_area_UK",
            "Sunderland_area_UK"
        ]
    }

    private func initMetropolitanAreaUkraine() {
        metropolitanAreas = [
            "Berdychiv_area_Ukraine",
            "Bogorodichin_area_Ukraine",
            "Kiev_area_Ukraine",
            "Kolomyya_area_Ukraine",
            "Odessa_area_Ukraine",
            "Stanislau_area_Ukraine",
            "Uman_area_Ukraine",
            "Zhytomyr_area_Ukraine"
        ]
    }

    private func initMetropolitanAreaUruguay() {
        metropolitanAreas = [
            "Montevideo_area_Uruguay",
            "San_Jose_area_Uruguay"
        ]
    }

    private func initMetropolitanAreaUSA() {
        metropolitanAreas = [
            "Albuquerque_area_NM",
            "Atlanta_area_GA",
            "Austin_area_TX",
            "Baltimore_area_MD",
            "Bethlehem_area_NH",
            "Binghamton_area_NY",
            "Boston_area_MA",
            "Buffalo_area_NY",
            "Catskill_village_area_NY",
            "Chicago_area_IL",
            "Cincinnati_area_OH",
            "Cleveland_area_OH",
            "Columbus_area_OH",
            "Dallas_area_TX",
            "Deal_area_NJ",
            "Denver_area_CO",
            "Detroit_area_MI",
            "El_Paso_area_TX",
            "Fort_Worth_area_TX",
            "Franconia_area_NH",
            "Harrisburg_area_PA",
            "Hartford_area_CT",
            "Houston_area_TX",
            "Howell_area_NJ",
            "Indianapolis_area_IN",
            "Ithaca_area_NY",
            "Jackson_area_NJ",
            "Kansas_City_area_MO",
            "Lakewood_area_NJ",
            "Liberty_area_NY",
            "Long_Island_area_NY",
            "Los_Angeles_area_CA",
            "Memphis_area_TN",
            "Miami_area_FL",
            "Milwaukee_area_WI",
            "Minneapolis_area_MN",
            "Monroe_area_NY",
            "Monsey_area_NY",
            "Monticello_area_NY",
            "New_Haven_area_CT",
            "New_York_City_area_NY",
            "North_East_New_Jersey_area_NJ",
            "Philadelphia_area_PA",
            "Phoenix_area_AZ",
            "Pittsburgh_area_PA",
            "Providence_area_RI",
            "Richmond_area_VA",
            "Rochester_area_NY",
            "San_Antonio_area_TX",
            "San_Diego_area_CA",
            "San_Francisco_area_CA",
            "Santa-Fe_area_NM",
            "Scranton_area_PA",
            "Seattle_area_WA",
            "Sierra-Nevada_area_CA",
            "South_Bend_area_IN",
            "South_Fallsburg_area_NY",
            "South_Haven_area_MI",
            "Spring_Valley_area_NY",
            "St_Louis_area_MO",
            "Stamford_area_CT",
            "Toms-River_area_NJ",
            "Tuscon_area_AZ",
            "WashingtonDC_area_MD",
            "Waterbury_area_CT",
            "Williams_area_AZ",
            "Woodridge_area_NY"
        ]
    }

    private func initMetropolitanAreaVenezuela() {
        metropolitanAreas = [
            "Caracas_area_Venezuela"
        ]
    }
}

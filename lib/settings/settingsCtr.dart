import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/onisan.dart';
import 'package:open_settings_plus/open_settings_plus.dart';



Map<String, String> languageNames = {
  'en': 'English',
  'fr': 'French',
  'es': 'Spanish',
  'de': 'German',
  'it': 'Italian',
  'pt': 'Portuguese',
  'ru': 'Russian',
  'zh': 'Chinese',
  'ja': 'Japanese',
  'ar': 'Arabic',
  'ko': 'Korean',
  'hi': 'Hindi',
  'tr': 'Turkish',
  'nl': 'Dutch',
  'pl': 'Polish',
};
class SettingsCtr extends GetxController {


  @override
  void onInit() {
    super.onInit();
    print("## ## onInit SettingsCtr");

  }

  void loadSettings(){
    //init in main
    loadTheme();
    loadFont();
    loadNotifSetting();
  }

  @override
  void onClose(){

    print('## ## onClose SettingsCtr');

    super.onClose();
  }

  /// ***************** LANGUAGE ****************************

  var selectedLanguage = (Get.locale?.languageCode ?? 'en').obs;

  String? get currLang => selectedLanguage.value; //'en' , 'fr' ...
  Locale get initLang => Locale(PreferencesService.prefs.getString('selected_lang') ?? CustomVars.defaultLang);

  void changeLanguage(String codeLang) {
    selectedLanguage.value = codeLang; // Update the selected language

    PreferencesService.prefs!.setString('selected_lang', codeLang);
    Locale locale = Locale(codeLang);
    Get.updateLocale(locale);
    print('## changed lang to => <${currLang}>');
  }
  String getCurrentLanguageName() {
    Map<String, String> languageMap = {
      'en': 'English',
      'fr': 'French',
      'es': 'Spanish',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ar': 'Arabic',
      'ko': 'Korean',
      'hi': 'Hindi',
      'tr': 'Turkish',
      'nl': 'Dutch',
      'pl': 'Polish',
    };

    return languageMap[currLang] ?? 'Unknown';
  }



  /// ***************** THEME ****************************


  var selectedTheme = 0.obs; // 0 for Light, 1 for Dark
  bool get isLight => selectedTheme.value==0;



  void loadTheme() async {
    selectedTheme.value = PreferencesService.prefs!.getInt('selected_theme') ?? 0; // Default to Light theme
    print("## theme <${selectedTheme.value}> Loaded");

    applyTheme(selectedTheme.value,entrance: true);
  }

  void saveTheme(int theme) async {
    await PreferencesService.prefs!.setInt('selected_theme', theme);
    selectedTheme.value = theme;
    applyTheme(theme);

  }

  void applyTheme(int theme, {bool entrance = false}) {
    String paletteKey;
    if (theme == 0) {
      paletteKey = 'light';
    } else if (theme == 1) {
      paletteKey = 'dark';
    } else {
      paletteKey = 'blue';
    }

    switchPalette(paletteKey);

    if (!entrance) Get.forceAppUpdate();
    print("## Apply theme <$paletteKey>");
  }

  void switchPalette(String paletteKey) {
    if (CustomVars.paletteMap.containsKey(paletteKey)) {
      Cm.switchPalette(CustomVars.paletteMap[paletteKey]!);
      Get.changeTheme(CustomVars.getAppTheme()); // Update the theme
      print('## Switched to palette <$paletteKey>');
    } else {
      print('## Error: Palette <$paletteKey> not found');
    }
  }
  /// ***************** FONT ****************************


  var selectedFont=0.obs;
  void loadFont() async {
    selectedFont.value = PreferencesService.prefs!.getInt('selected_font') ?? 0; // Default to JosefinSans

    applyFont(selectedFont.value,entrance: true );
  }
  void saveFont(int font) async {
    PreferencesService.prefs!.setInt('selected_font', font);
    selectedFont.value = font;
    applyFont(font);
  }
  void applyFont(int font,{bool entrance = false}) {
    if (font == 0) {
      Fm.switchFont(AppFont.JosefinSans);
    } else if (font == 1) {
      Fm.switchFont(AppFont.Roboto);
    } else if (font == 2) {
      Fm.switchFont(AppFont.Lato);
    }
    if(!entrance)  Get.forceAppUpdate();

  }


  /// ***************** NOTIF ****************************

  var isNotifEnabled = true.obs; // false for Disabled, true for Enabled

  void loadNotifSetting() async {
    isNotifEnabled.value = PreferencesService.prefs!.getBool('notif_enabled') ?? false; // Default to Disabled
    applyNotifSetting(isNotifEnabled.value);
    checkNotificationPermission();
  }

  void saveNotifSetting(bool isEnabled) async {
    await PreferencesService.prefs!.setBool('notif_enabled', isEnabled);
    isNotifEnabled.value = isEnabled;
    applyNotifSetting(isEnabled);
  }


  switchNotif(bool enable) async {
    if(enable){
      bool access = await requestNotificationsPermission();
      if(access){
        settingCtr.saveNotifSetting(true);

      }else{
        showBottomSheetDialog(
            title: "Notification Permission",
            description: "Notifications are disabled. Please enable them from app settings to receive updates.",
            positiveButtonText: "open settings",
            onPositivePressed: () {
              switch (OpenSettingsPlus.shared) {
                case OpenSettingsPlusAndroid settings:
                  settings.appNotification();
                  break;
                case OpenSettingsPlusIOS settings:

                  break;
                default:
                  throw Exception('Platform not supported');
              }
             // AppSettings.openAppSettings(type: AppSettingsType.notification); app_setting pckg

              //TODO when the user return to app not with timer

              // Future.delayed(Duration(seconds: 2), () {
              //   checkNotificationPermission();
              // });
            }
        );
      }
    }else{
      settingCtr.saveNotifSetting(false);

    }
  }
  void applyNotifSetting(bool isEnabled) {
    if (isEnabled) {
      // Enable notifications logic here
    } else {
      // Disable notifications logic here
    }
  }

}

markdown
Copy
# 🚀 Capacitor Kakao Login Plugin

> Official **Kakao Login Plugin** for Capacitor. Supports Android, iOS & Web environments.  
> Fully compatible with **Capacitor 8** ✅ | Optimized for latest SDK versions 🔥

## 📦 Install

```bash
npm i capacitor-kakao-login-plugin
npx cap sync
```

### iOS: Kakao SDK (SPM)

이 플러그인은 **Kakao iOS SDK 2.23.0+** 를 사용합니다.

- **앱이 iOS를 SPM으로 사용하는 경우**  
  (`npx cap add ios --packagemanager SPM` 으로 만든 프로젝트)  
  **별도 작업 없이** `npx cap sync` 만 하면 Kakao SDK가 플러그인 의존성으로 자동 추가됩니다.

- **앱이 iOS를 CocoaPods으로 사용하는 경우**  
  (기존 `ios` 폴더에 Podfile이 있는 프로젝트)  
  CocoaPods에는 Kakao 2.23+ 가 없으므로, **앱의 Xcode 프로젝트에서만** Kakao SDK를 SPM으로 수동 추가해야 합니다.  
  1. Xcode에서 `ios/App/App.xcodeproj` 열기  
  2. **Project** → **Package Dependencies** → **[+]**  
  3. URL 입력: `https://github.com/kakao/kakao-ios-sdk`  
  4. **Dependency Rule**: Branch → `master` 후 **Add Package**  
  5. **Add to Target**에서 앱 타겟 선택 후 아래 제품 선택:  
     `KakaoSDKCommon`, `KakaoSDKAuth`, `KakaoSDKUser`, `KakaoSDKTalk`, `KakaoSDKShare`, `KakaoSDKTemplate`

이후 아래 **IOS** 설정(Info.plist, AppDelegate)을 진행하세요.


| Version     |  Platform   |
|-------------|:-----------:|
| **`4.0.x`** | Capacitor 8 |
| **`3.0.x`** | Capacitor 7 |
| **`2.0.x`** | Capacitor 6 |
| **`1.3.x`** | Capacitor 5 |
| **`1.2.x`** | Capacitor 4 |

## API

<docgen-index>

* [`initForWeb()`](#initForWeb)
* [`goLogin()`](#gologin)
* [`goLogout()`](#gologout)
* [`getUserInfo()`](#getuserinfo)
* [`sendLinkFeed(...)`](#sendlinkfeed)
* [`talkInChannel(...)`](#talkInChannel)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initForWeb()

```typescript
initForWeb(appkey) => Promise<void>
```

| Param        |                                       Type                                       |
|--------------|:--------------------------------------------------------------------------------:|
| **`appkey`** | <code>string</code> <br/> Your JavaScript api key (from Kakao developer console) |

**Returns:** <code>Promise</code>

--------------------

### goLogin()

```typescript
goLogin() => any // (with openId if you set in console) 
```

**Returns:** <code>any</code>

--------------------


### goLogout()

```typescript
goLogout() => any
```

**Returns:** <code>any</code>

--------------------


### getUserInfo()

```typescript
getUserInfo() => any
```

**Returns:** <code>any</code>

--------------------


### sendLinkFeed(...)

```typescript
sendLinkFeed(options: { title: string; description: string; imageUrl: string; imageLinkUrl: string; buttonTitle: string; imageWidth?: number; imageHeight?: number; }) => any
```

| Param         | Type                                                                                                                                                         |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **`options`** | <code>{ title: string; description: string; imageUrl: string; imageLinkUrl: string; buttonTitle: string; imageWidth?: number; imageHeight?: number; }</code> |

**Returns:** <code>any</code>

--------------------

### talkInChannel(...)

```typescript
talkInChannel(options: { publicId: string; }) => any
```

| Param         | Type                               |
| ------------- |------------------------------------|
| **`options`** | <code>{ publicId: string; }</code> |

**Returns:** <code>any</code>

--------------------


## Settings

### Web

- Before the plugin can be used `initForWeb()` must be called your with your JavaScript `appkey`
- After `initForWeb()` resolves the other methods can be used. 

### Android

- Set AndroidManifest.xml

```xml
<!-- AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="io.ionic.starter">
  ...
  <!-- For Kakao Share (only if targeting Android 11) -->
+ <queries>
+   <package android:name="com.kakao.talk" />
+ </queries>
  ...
+   <meta-data
+       android:name="com.kakao.sdk.AppKey"
+       android:value="@string/kakao_app_key" />
    <!-- For Login -->
    <activity
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|smallestScreenSize|screenLayout|uiMode"
            android:name="org.nerdfriends.ddoit.app.MainActivity"
            android:label="@string/title_activity_main"
            android:theme="@style/AppTheme.NoActionBarLaunch"
            android:launchMode="singleTask"
            android:windowSoftInputMode="adjustPan"
    >
        <intent-filter android:autoVerify="true">
            <action android:name="android.intent.action.VIEW" />
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="@string/custom_url_scheme" android:host="org.nerdfriends.ddoit.app" />
+           <data android:host="kakaolink" android:scheme="@string/kakao_scheme" />
        </intent-filter>

    </activity>
    ...
+    <activity
+            android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity"
+            android:exported="true">
+        <intent-filter>
+            <action android:name="android.intent.action.VIEW" />
+            <category android:name="android.intent.category.DEFAULT" />
+            <category android:name="android.intent.category.BROWSABLE" />

+            <!-- Redirect URI: "kakao${NATIVE_APP_KEY}://oauth" -->
+            <data android:host="oauth" android:scheme="@string/kakao_scheme" />
+        </intent-filter>
+    </activity>
      ...
  </application>
</manifest>
```

- Set Kakao Repository to `build.gradle`

```shell
allprojects {
    repositories {
        google()
        jcenter()
        maven { url 'https://devrepo.kakao.com/nexus/content/groups/public/' }
    }
}
```

- Add Kakao Initialization

```java
public class MainActivity extends BridgeActivity {
    private CallbackManager callbackManager;

    @Override
    public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      // 카카오
+      KakaoSdk.init(this, getString(R.string.kakao_app_key);
    }
}
```

- Add kakao string variables

```xml
<string name="kakao_app_key">{NATIVE_APP_KEY}</string>
<string name="kakao_scheme">kakao{NATIVE_APP_KEY}</string>
```



### IOS

- **Kakao iOS SDK**는 위 **"iOS: Kakao SDK (SPM)"** 절차대로 SPM으로 추가해야 합니다.

- Add kakao values and schemes to `info.plist`

```xml
<dict>
  <array>
     <dict>
	<key>CFBundleURLSchemes</key>
   	<array>
	    <string>kakao{NATIVE_APP_KEY}</string>
	</array>
     </dict>
  </array>
  
  <key>KAKAO_APP_KEY</key>
  <string>{NATIVE_APP_KEY}</string>
  <key>LSApplicationQueriesSchemes</key>
  <array>
     <string>kakao{NATIVE_APP_KEY}</string>
     <string>kakaokompassauth</string>
     <string>storykompassauth</string>
     <string>kakaolink</string>
     <string>storylink</string>
     <string>kakaotalk</string>
  </array>
</dict>
```

- Add initial kakao codes to `AppDelegate.swift`

```swift
import UIKit
import Capacitor
import KakaoSDKAuth
import KakaoSDKCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  ...
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
    	// Initialize Kakao
+       let key = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String
+       KakaoSDK.initSDK(appKey: key!)
        return true
  }
  
  ...
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call
    
    	// Need for Login with KakaoTalk
+       if (AuthApi.isKakaoTalkLoginUrl(url)) {
+           return AuthController.handleOpenUrl(url: url)
+       }
        
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
  }
  
  ...
}
```
</docgen-api>

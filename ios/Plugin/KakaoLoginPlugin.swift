import Foundation
import Capacitor
import KakaoSDKUser
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKAuth
import KakaoSDKTalk


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

extension Encodable {
    
    var toDictionary : [String: Any]? {
        guard let object = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String:Any] else { return nil }
        return dictionary
    }
}

@objc(KakaoLoginPlugin)
public class KakaoLoginPlugin: CAPPlugin {
    func parseOAuthToken(oauthToken: OAuthToken) -> [String: Any] {
        var oauthTokenInfos: [String: Any] = [
            "success": true,
            "accessToken": oauthToken.accessToken,
            "expiredAt": oauthToken.expiredAt,
            "expiresIn": oauthToken.expiresIn,
            "refreshToken": oauthToken.refreshToken,
            "refreshTokenExpiredAt": oauthToken.refreshTokenExpiredAt,
            "refreshTokenExpiresIn": oauthToken.refreshTokenExpiresIn,
            "tokenType": oauthToken.tokenType
        ]
        if oauthToken.idToken != nil {
            oauthTokenInfos["idToken"] = oauthToken.idToken
        }
        if let scope = oauthToken.scope {
            oauthTokenInfos["scope"] = scope
        }
        if let scopes = oauthToken.scopes {
            oauthTokenInfos["scopes"] = scopes
        }
        return oauthTokenInfos
    }

    @objc public func sendLinkFeed(_ call: CAPPluginCall) -> Void {
        if ShareApi.isKakaoTalkSharingAvailable() {
            let title = call.getString("title") ?? ""
            let description = call.getString("description") ?? ""
            let imageUrl = call.getString("imageUrl") ?? ""
            let imageLinkUrl = call.getString("imageLinkUrl") ?? ""
            let buttonTitle = call.getString("buttonTitle") ?? ""
            let imageWidth: Int? = call.getInt("imageWidth")
            let imageHeight: Int? = call.getInt("imageHeight")



            let link = Link(webUrl: URL(string:imageLinkUrl)!,
                            mobileWebUrl: URL(string:imageLinkUrl)!)

            let button = Button(title: buttonTitle, link: link)
            let content = Content(title: title,
                                  imageUrl: URL(string:imageUrl)!,
                                  imageWidth: imageWidth,
                                  imageHeight: imageHeight,
                                  description: description,
                                  link: link)
            let feedTemplate = FeedTemplate(content: content, social: nil, buttons: [button])

            if let feedTemplateJsonData = (try? SdkJSONEncoder.custom.encode(feedTemplate)) {
                if let templateJsonObject = SdkUtils.toJsonObject(feedTemplateJsonData) {
                    ShareApi.shared.shareDefault(templateObject:templateJsonObject) {(linkResult, error) in
                        if let error = error {
                            print(error)
                            call.reject("error")
                        }
                        else {
                            guard let linkResult = linkResult else { return }
                            UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)

                            call.resolve()
                        }
                    }
                }
            }
        } else {
            call.reject("no-installed")
        }

    }

    @objc public func getUserInfo(_ call: CAPPluginCall) -> Void {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
                call.reject("me() failed.")
            }
            else {
                print("me() success.")
                call.resolve([
                    "value": user?.toDictionary as Any
                ])
            }
        }
    }
    @objc func goLogin(_ call: CAPPluginCall){
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                    call.reject("Error Logout: \(error)")
                    return
                }
                else {
                    print("loginWithKakaoTalk() success.");
                    if let oauthToken = oauthToken {
                       let oauthTokenInfos = self.parseOAuthToken(oauthToken: oauthToken)
                        call.resolve(oauthTokenInfos)
                   }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        print(error)
                        call.reject("Error Logout: \(error)")
                        return
                    }
                    else {
                        if let oauthToken = oauthToken {
                           let oauthTokenInfos = self.parseOAuthToken(oauthToken: oauthToken)
                            call.resolve(oauthTokenInfos)
                       }
                    }
                }
        }
        return
    }
    @objc func goLogout(_ call: CAPPluginCall) {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
                call.reject("Error Logout: \(error)")
            }
            else {
                print("Logout success.")
            }
        }
    }
}


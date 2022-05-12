import Foundation
import KakaoSDKUser
import KakaoSDKAuth
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

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
            if let scope = oauthToken.scope {
                oauthTokenInfos["scope"] = scope
            }
            if let scopes = oauthToken.scopes {
                oauthTokenInfos["scopes"] = scopes
            }
            return oauthTokenInfos
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
    
    func getToken() -> Int64 {
        var userId : Int64 = 0
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                print(user?.id! as Any)
                //do something
                userId = (user?.id)!
            }
        }
        return userId
    }
}


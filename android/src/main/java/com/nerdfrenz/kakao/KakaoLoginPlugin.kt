package com.nerdfrenz.kakao

import android.content.ContentValues.TAG
import android.util.Log
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.kakao.sdk.auth.AuthApiClient
import com.kakao.sdk.auth.model.OAuthToken
import com.kakao.sdk.common.model.ApiError
import com.kakao.sdk.common.model.AuthError
import com.kakao.sdk.common.model.ClientError
import com.kakao.sdk.common.model.KakaoSdkError
import com.kakao.sdk.user.UserApi
import com.kakao.sdk.user.UserApiClient

@CapacitorPlugin(name = "KakaoLoginPlugin")
class KakaoLoginPlugin : Plugin() {

    fun parseToken(token: OAuthToken): JSObject {
        var tokenInfos = JSObject();
        tokenInfos.putSafe("success", true);
        tokenInfos.putSafe("accessToken", token.accessToken);
        tokenInfos.putSafe("expiredAt", token.accessTokenExpiresAt.toString());
        tokenInfos.putSafe("refreshToken", token.refreshToken);
        token.refreshTokenExpiresAt?.let {
            tokenInfos.putSafe("refreshTokenExpiresAt", it.toString());
        }
        return tokenInfos
    }

    fun parseError(error: Throwable): JSObject? {
        var errorInfos = JSObject();
        var clientError = (error as? ClientError)
        if (clientError != null) {
            errorInfos.putSafe("success", false);
            errorInfos.putSafe("errorType", "ClientError");
            errorInfos.putSafe("errorMessage", clientError.msg);
            return errorInfos
        }
        var authError = (error as? AuthError)
        if (authError != null) {
            errorInfos.putSafe("success", false);
            errorInfos.putSafe("errorType", "AuthError");
            errorInfos.putSafe("errorMessage", authError.msg);
            return errorInfos
        }
        var apiError = (error as? ApiError)
        if (apiError != null) {
            errorInfos.putSafe("success", false);
            errorInfos.putSafe("errorType", "ApiError");
            errorInfos.putSafe("errorMessage", apiError.msg);
            errorInfos.putSafe("errorCode", apiError.statusCode);
            return errorInfos
        }
        return null
    }

    @PluginMethod
    fun goLogin(call: PluginCall) {
        val callback: (OAuthToken?, Throwable?) -> Unit = { token, error ->
            if (error != null) {
                call.resolve(parseError(error));
            }
            else if (token != null) {
                call.resolve(parseToken(token))
            }
        }

        if (UserApiClient.instance.isKakaoTalkLoginAvailable(context)) {
            UserApiClient.instance.loginWithKakaoTalk(context, callback = callback)
        } else {
            UserApiClient.instance.loginWithKakaoAccount(context, callback = callback)
        }
    }
    @PluginMethod
    fun goLogout(call: PluginCall) {
        UserApiClient.instance.logout { error ->
            if (error != null) {
                call.reject("로그아웃 실패")
            } else {
                call.success()
            }
        }
    }
}


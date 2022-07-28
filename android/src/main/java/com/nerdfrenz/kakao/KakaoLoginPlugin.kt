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
import com.google.gson.Gson
import com.kakao.sdk.common.util.KakaoCustomTabsClient
import com.kakao.sdk.template.model.FeedTemplate
import com.kakao.sdk.share.ShareClient
import com.kakao.sdk.share.model.SharingResult
import com.kakao.sdk.talk.TalkApiClient
import com.kakao.sdk.template.model.Button
import com.kakao.sdk.template.model.Content
import com.kakao.sdk.template.model.Link
import org.json.JSONArray
import java.lang.Exception

val gson = Gson()

@CapacitorPlugin(name = "KakaoLoginPlugin")
class KakaoLoginPlugin : Plugin() {

    fun parseToken(token: OAuthToken): JSObject {
        var tokenInfos = JSObject();
        tokenInfos.putSafe("success", true);
        tokenInfos.putSafe("accessToken", token.accessToken);
        tokenInfos.putSafe("expiredAt", token.accessTokenExpiresAt.toString());
        tokenInfos.putSafe("refreshToken", token.refreshToken);
        token.idToken?.let {
               tokenInfos.putSafe("idToken", token.idToken);
        }
        token.refreshTokenExpiresAt?.let {
            tokenInfos.putSafe("refreshTokenExpiresAt", it.toString());
        }
        return tokenInfos
    }

    @PluginMethod
    fun goLogin(call: PluginCall) {
        val callback: (OAuthToken?, Throwable?) -> Unit = { token, error ->
            if (error != null) {
                call.reject(error.toString());
            }
            else if (token != null) {
                call.resolve(parseToken(token))
            } else {
                call.reject("no_data")
            }
        }

        if (UserApiClient.instance.isKakaoTalkLoginAvailable(context)) {
            UserApiClient.instance.loginWithKakaoTalk(context, callback = callback)
        } else {
            UserApiClient.instance.loginWithKakaoAccount(context, callback = callback)
        }
    }
    @PluginMethod
    fun talkInChannel(call: PluginCall) {
        try {
            val publicId: String = call.getString("publicId") ?: ""
            if(publicId != "") {
                val url = TalkApiClient.instance.channelChatUrl(publicId)
                KakaoCustomTabsClient.openWithDefault(context, url)
                call.resolve()
            } else {
                call.reject("채팅 보내기 실")
            }
        } catch (e: Exception) {
           call.reject(e.toString());
        }
    }
    @PluginMethod
    fun sendLinkFeed(call: PluginCall) {
        val imageLinkUrl = call.getString("imageLinkUrl")
        val imageUrl: String = if (call.getString("imageUrl") === null) "" else call.getString("imageUrl")!!
        val title: String = if (call.getString("title") === null) "" else call.getString("title")!!
        val description = call.getString("description")
        val buttonTitle: String = if (call.getString("buttonTitle") === null) "" else call.getString("buttonTitle")!!
        val imageWidth: Int? = call.getInt("imageWidth")
        val imageHeight: Int? = call.getInt("imageHeight")

        val link = Link(imageLinkUrl, imageLinkUrl, null, null)
        val content = Content(title, imageUrl, link, description, imageWidth, imageHeight)
        val buttons = ArrayList<Button>()
        buttons.add(Button(buttonTitle, link))
        val feed = FeedTemplate(content, null, null, buttons)
        ShareClient.instance
            .shareDefault(
                    activity,
                    feed
            ) { linkResult: SharingResult?, error: Throwable? ->
                if (error != null) {
                    call.reject("kakao link failed: " + error.toString())
                } else if (linkResult != null) {
                    activity.startActivity(linkResult.intent)
                }
                call.resolve()
            }
    }
    @PluginMethod
    fun getUserInfo(call: PluginCall) {
        // 사용자 정보 요청 (기본)
        UserApiClient.instance.me { user, error ->
            if (error != null) {
                Log.e(TAG, "사용자 정보 요청 실패", error)
                call.reject(error.toString());
            }
            else if (user != null) {
                Log.i(TAG, "사용자 정보 요청 성공" +
                        "\n회원번호: ${user.id}" +
                        "\n이메일: ${user.kakaoAccount?.email}" +
                        "\n닉네임: ${user.kakaoAccount?.profile?.nickname}" +
                        "\n프로필사진: ${user.kakaoAccount?.profile?.thumbnailImageUrl}")
                val userJsonData = JSObject(gson.toJson(user).toString())
                val ret = JSObject()
                ret.put("value", userJsonData)
                call.resolve(ret)
            }
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


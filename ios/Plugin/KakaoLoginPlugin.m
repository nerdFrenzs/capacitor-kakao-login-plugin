#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(KakaoLoginPlugin, "KakaoLoginPlugin",
           CAP_PLUGIN_METHOD(goLogin, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(goLogout, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getUserInfo, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(sendLinkFeed, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(talkInChannel, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(initForWeb, CAPPluginReturnPromise);
)

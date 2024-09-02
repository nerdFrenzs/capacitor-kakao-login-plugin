import { WebPlugin } from '@capacitor/core';

import type { KakaoLoginPlugin, KakaoLoginResponse } from './definitions';

interface LoginParams {
  throughTalk?: boolean;
  persistAccessToken?: boolean;
  scope?: string;
  success: (response: LoginResponse) => void;
  fail: (error: KakaoError) => void;
}

interface LoginResponse {
  token_type: string;
  access_token: string;
  expires_in: number;
  refresh_token: string;
  refresh_token_expires_in: number;
  scope: string;
  id_token?: string;
}

interface KakaoError {
  error: string;
  error_description: string;
}

interface Profile {
  nickname: string;
  profile_image: string;
  thumbnail_image_url: string;
  profile_needs_agreement?: boolean;
}

interface KakaoAccount {
  profile: Profile;
  email: string;
  age_range: string;
  birthday: string;
  birthyear: string;
  gender: 'female' | 'male';
  phone_number: string;
  ci: string;
}

interface UserProfile {
  id: number;
  kakao_account: KakaoAccount;
  synched_at: string;
  connected_at: string;
  properties: Profile;
}

interface RequestParams {
  url: string;
  success: (profile: UserProfile) => void;
  fail: (error: KakaoError) => void;
}

interface KakaoAPI {
  request: (params: RequestParams) => void;
}

declare global {
  interface Window {
    Kakao?: {
      init: (...args: any[]) => void;
      Auth: {
        login: (params: LoginParams) => void;
        loginForm: (params: LoginParams) => void;
        logout: (callback: () => void) => void;
        getAccessToken: () => string | null;
      };
      API: KakaoAPI;
    };
  }
}

export class KakaoLoginPluginWeb extends WebPlugin implements KakaoLoginPlugin {
  private response?: LoginResponse;
  private hasInit = false;

  public initForWeb = async (appkey: string): Promise<void> => {
    try {
      await this.loadSDK(appkey);
      this.testSDK();
      if (!this.hasInit) {
        window.Kakao?.init(appkey);
        this.hasInit = true;
      }
    } catch (e) {
      console.error('Error loading Kakao SDK', e);
      return Promise.reject(e);
    }
  };

  public goLogin = (): Promise<KakaoLoginResponse> => {
    this.testSDK();
    return new Promise<KakaoLoginResponse>((resolve, reject) => {
      try {
        window.Kakao!.Auth.login({
          throughTalk: true,
          persistAccessToken: true,
          success: (response: LoginResponse) => {
            console.log(response);
            this.response = response;
            const tokenExpire = new Date();
            tokenExpire.setSeconds(
              tokenExpire.getSeconds() + response.expires_in,
            );
            const refreshTokenExpire = new Date();
            refreshTokenExpire.setSeconds(
              refreshTokenExpire.getSeconds() +
                response.refresh_token_expires_in,
            );
            resolve({
              accessToken: response.access_token,
              expiredAt: tokenExpire.toISOString(),
              expiresIn: response.expires_in.toString(10),
              refreshToken: response.refresh_token,
              refreshTokenExpiresIn: response.refresh_token_expires_in.toString(
                10,
              ),
              tokenType: response.token_type,
              idToken: response.id_token,
              refreshTokenExpiredAt: response.refresh_token_expires_in.toString(
                10,
              ),
            });
          },
          fail: (error: KakaoError) => {
            console.error('Kakao Login Failed', error);
            reject(new Error('Kakao Login Failed'));
          },
        });
      } catch (e) {
        console.error('Error during Kakao login', e);
        reject(e);
      }
    });
  };

  public async goLogout(): Promise<void> {
    this.testSDK();

    return new Promise<void>((resolve, reject) => {
      const callBack = () => {
        this.response = undefined;
        resolve();
      }
      try {
        window.Kakao?.Auth.logout(callBack);
      } catch (e) {
        console.error('Error logging out', e);
        reject(e);
      }
    });
  }

  public getUserInfo(): Promise<{ value: any }> {
    this.testSDK();
    if (!this.response) {
      return Promise.reject('Not logged in.');
    }
    return new Promise((resolve, reject) => {
      window.Kakao!.API.request({
        url: '/v2/user/me',
        success: profile => {
          resolve({ value: profile });
        },
        fail: error => {
          console.error(error);
          reject(error);
        },
      });
    });
  }

  private loadSDK = (_appkey: string) => {
    return new Promise<void | Event>((resolve, reject) => {
      if (document.getElementById('kakao-script')) {
        return resolve();
      }
      const script = document.createElement('script');
      script.id = 'kakao-script';
      script.type = 'text/javascript';
      script.onload = resolve;
      script.onerror = reject;
      script.src = '//developers.kakao.com/sdk/js/kakao.min.js';
      document.head.appendChild(script);
    });
  };

  public sendLinkFeed(_options: never): Promise<void> {
    throw this.unimplemented('Not implemented on web.');
  }

  public talkInChannel(_options: never): Promise<void> {
    throw this.unimplemented('Not implemented on web.');
  }

  private testSDK() {
    if (!window.Kakao) {
      throw new Error('Kakao script not loaded. Call initForWeb for first');
    }
  }
}

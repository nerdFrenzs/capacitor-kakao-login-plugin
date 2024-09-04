export interface KakaoLoginResponse {
  accessToken: string;
  expiredAt: string;
  expiresIn: string;
  refreshToken: string;
  idToken?: string;
  refreshTokenExpiredAt: string;
  refreshTokenExpiresIn: string;
  tokenType: string;
}

export interface KakaoLoginPlugin {
  goLogin(): Promise<KakaoLoginResponse>;

  goLogout(): Promise<any>;
  getUserInfo(): Promise<{ value: any }>;
  sendLinkFeed(options: {
    title: string;
    description: string;
    imageUrl: string;
    imageLinkUrl: string;
    buttonTitle: string;
    imageWidth?: number;
    imageHeight?: number;
  }): Promise<void>;
  talkInChannel(options: { publicId: string }): Promise<any>;
  initForWeb(appkey: string): Promise<void>;
}

export interface KakaoLoginPlugin {
  goLogin(): Promise<{
    "accessToken": string,
    "expiredAt": string,
    "expiresIn": string,
    "refreshToken": string,
    "idToken": string,
    "refreshTokenExpiredAt": string,
    "refreshTokenExpiresIn": string,
    "tokenType": string}>;
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
}

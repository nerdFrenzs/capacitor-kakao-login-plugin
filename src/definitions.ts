export interface KakaoLoginPlugin {
  goLogin(): Promise<{
    "accessToken": string,
    "expiredAt": string,
    "expiresIn": string,
    "refreshToken": string,
    "refreshTokenExpiredAt": string,
    "refreshTokenExpiresIn": string,
    "tokenType": string}>;
  goLogout(): Promise<any>;
}

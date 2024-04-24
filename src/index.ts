import { registerPlugin } from '@capacitor/core';

import { KakaoLoginPlugin } from './definitions';

const KakaoLoginPlugin = registerPlugin<KakaoLoginPlugin>('KakaoLoginPlugin', {
});

export * from './definitions';
export { KakaoLoginPlugin };

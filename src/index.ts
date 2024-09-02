import { registerPlugin } from '@capacitor/core';

import { KakaoLoginPlugin } from './definitions';

const KakaoLoginPlugin = registerPlugin<KakaoLoginPlugin>('KakaoLoginPlugin', {
  web: () => import('./web').then(m => new m.KakaoLoginPluginWeb()),
});

export * from './definitions';
export { KakaoLoginPlugin };

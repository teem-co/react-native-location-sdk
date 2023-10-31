import { NativeEventEmitter, NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-location-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const LocationSdk = NativeModules.LocationSdk
  ? NativeModules.LocationSdk
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const eventEmitter = new NativeEventEmitter(LocationSdk);

export type PermissionStatus =
  | 'always'
  | 'when_in_use'
  | 'denied'
  | 'restricted'
  | 'not_determined';

export interface Location {
  coordinate: {
    longitude: number;
    latitude: number;
  };
  altitude: number;
  course: number;
  horizontalAccuracy: number;
  speed: number;
  speedAccuracy: number;
  timestamp: string;
  verticalAccuracy: number;
}

export function check(): Promise<boolean> {
  return LocationSdk.check();
}

export function requestPermission(): Promise<PermissionStatus> {
  return LocationSdk.requestPermission();
}

export function getPermissionStatus(): Promise<PermissionStatus> {
  return LocationSdk.getPermissionStatus();
}

export function start(): Promise<void> {
  return LocationSdk.start();
}

export function stop(): Promise<void> {
  return LocationSdk.stop();
}

export function isEnabled(): Promise<boolean> {
  return LocationSdk.isEnabled();
}

export function onLocation(callback: (location: Location) => void) {
  return eventEmitter.addListener('location', callback);
}

export function onEnabledChanged(callback: (enabled: boolean) => void) {
  return eventEmitter.addListener('enabled_changed', callback);
}

export function onAuthorizationChange(
  callback: (status: PermissionStatus) => void
) {
  return eventEmitter.addListener('changeAuthorization', callback);
}

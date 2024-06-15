import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-printer-pt220' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const PrinterPt220 = NativeModules.PrinterPt220
  ? NativeModules.PrinterPt220
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export const {PT_ALIGN_CENTER, PT_ALIGN_RIGHT, PT_ALIGN_LEFT} = PrinterPt220.getConstants();

export function ptConnect(name: string): Promise<string> {
  return PrinterPt220.ptConnect(name);
}

export function ptSetPrinter(command: string): Promise<boolean> {
  return PrinterPt220.ptSetPrinter(command);
}

export function ptPrintText(text: string): Promise<boolean> {
  return PrinterPt220.ptPrintText(text);
}

export function ptGetDevices(): Promise<string[]> {
  return PrinterPt220.ptGetDevices();
}
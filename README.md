# react-native-printer-pt220

React Native Module For PT-220 Thermal Printer

## Installation

```sh
npm i react-native-printer-pt220
```

## iOS Configuration

Open your project's `Info.plist` and add the following lines inside the outermost `<dict>` tag:

```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Need Bluetooth</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need Bluetooth</string>
```

## Android Configuration

None

## Usage

```tsx
import * as React from 'react';

import { StyleSheet, View, Button, Platform } from 'react-native';
import { ptConnect, ptSetPrinter, ptPrintText, PT_ALIGN_CENTER, ptInit } from 'react-native-printer-pt220';

export default function App() {

  const [result, setResult] = React.useState<string>();
  const printerName = 'PT-220';

  React.useEffect(() => {

    if(Platform.OS === 'ios') {
      ptInit();
      setTimeout(() => {
        ptConnect(printerName).then(setResult);
      }, 2000);
    } else {
      // call connect right away
      ptConnect(printerName).then(setResult);
    }
  }, []);

  return (
    <View style={styles.container}>
      <Button title='Print Text' onPress={() => {
        ptSetPrinter(PT_ALIGN_CENTER)
        .then(ret => {
          console.log(ret);
          console.log('Set printer to align center');

          ptPrintText('React Native Module Test...\n\n')
          .then(pret => {
            console.log(pret);
            console.log('Text printed...');
          })
          .catch(pe => {
            console.log(pe);
          });

        })
        .catch(e => {
          console.log(e);
        });

      }} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
```
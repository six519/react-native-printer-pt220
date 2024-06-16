import * as React from 'react';

import { StyleSheet, View, Button, Platform } from 'react-native';
import { ptConnect, ptSetPrinter, ptPrintText, ptPrintImage, PT_ALIGN_CENTER, ptInit } from 'react-native-printer-pt220';

export default function App() {

  const [result, setResult] = React.useState<string>();
  const printerName = 'PT-220';

  React.useEffect(() => {

    if(Platform.OS === 'ios') {
      ptInit();
      setTimeout(() => {
        console.log('Connecting...');
        ptConnect(printerName).then(setResult);
      }, 2000);
    } else {
      // call connect right away
      console.log('Connecting...');
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

            ptPrintImage('react_native_logo')
            .then(pret2 => {
              console.log(pret2);
              console.log('Image printed...');
            })
            .catch(pe2 => {
              console.log(pe2);
            });

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
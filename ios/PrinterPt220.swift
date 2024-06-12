import UIKit
import CoreBluetooth

@objc(PrinterPt220)
class PrinterPt220: NSObject, BLEManagerDelegate, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral!
    var currentCharacteristic: CBCharacteristic!
    var bleManager: Any!
    var bleManager2: BLEManager!
    var printerCommands: [String: [UInt8]] = [
        "ALIGN_CENTER": [27, 97, 1],
        "ALIGN_RIGHT": [27, 97, 2],
        "ALIGN_LEFT": [27, 97, 0]
    ]
    
    let PRINTER_SERVICE = "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"
    let PRINTER_CHARACTERISTIC = "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"
    
    //BLEManagerDelegate
    func didUpdate(_ state: CBManagerState) {
        switch(state) {
        case .poweredOn:
            print("powered on")
            bleManager2.scan(forPeripherals: PRINTER_SERVICE)
        case .poweredOff:
            print("powered off")
        default:
            print("Uknown")
        }
    }
    
    func didPeripheralFound(_ peripheral: CBPeripheral, advertisementData: BLEAdvertisementData?, rssi RSSI: NSNumber?) {
        print("FOUND A PERIPHERAL OK!!!")
        self.peripheral = peripheral
        self.peripheral.delegate = self
        bleManager2.connect(self.peripheral)
    }
    
    func didConnect(_ peripheral: CBPeripheral) {
        self.peripheral.discoverServices([CBUUID(string: PRINTER_SERVICE)])
    }
    
    func didFail(toConnect peripheral: CBPeripheral, error: (any Error)?) {
    }
    
    func didDisconnectPeripheral(_ peripheral: CBPeripheral, error: (any Error)?) {
    }
    
    func didServicesFound(_ peripheral: CBPeripheral, services: [CBService]?) {
    }
    
    //CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard let services = peripheral.services else {return}
        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: PRINTER_CHARACTERISTIC)], for: service)
            print("Service discovered")
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else {return}
        for characteristic in characteristics {
            currentCharacteristic = characteristic
            print("Char discovered")
            break
        }
    }

    @objc(ptConnect:withResolver:withRejecter:)
    func ptConnect(address: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        
        bleManager = BLEManager.sharedInstance()
        bleManager2 = bleManager as? BLEManager
        bleManager2.delegate = self
        resolve(address)
    }
    
    @objc(ptSetPrinter:withResolver:withRejecter:)
    func ptSetPrinter(command: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        let data = Data(bytes: printerCommands[command]!, count: printerCommands[command]!.count)
        peripheral.writeValue(data, for: currentCharacteristic, type: .withoutResponse)
        resolve(true)
    }
    
    @objc(ptPrintText:withResolver:withRejecter:)
    func ptPrintText(text: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        let data = Data(text.utf8)
        peripheral.writeValue(data, for: currentCharacteristic, type: .withoutResponse)
        resolve(true)
    }
    
    @objc
    func constantsToExport() -> [AnyHashable : Any]! {
      return [
        "ALIGN_CENTER": "ALIGN_CENTER",
        "ALIGN_LEFT": "ALIGN_LEFT",
        "ALIGN_RIGHT": "ALIGN_RIGHT"
      ]
    }
}

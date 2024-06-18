import UIKit
import CoreBluetooth
import CoreImage

@objc(PrinterPt220)
class PrinterPt220: NSObject, BLEManagerDelegate, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral!
    var currentCharacteristic: CBCharacteristic!
    var bleManager: BLEManager!
    var printerCommands: [String: [UInt8]] = [
        "ALIGN_CENTER": [27, 97, 1],
        "ALIGN_RIGHT": [27, 97, 2],
        "ALIGN_LEFT": [27, 97, 0]
    ]
    var btDevices = [String: CBPeripheral]()
    
    let PRINTER_SERVICE = "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"
    let PRINTER_CHARACTERISTIC = "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"
    
    enum PrinterError: Error {
        case printerSet
        case printerPrintText
        case printerPrintImage
        case printerPrintQRCode
        case printerConnect
    }
    
    //BLEManagerDelegate
    func didUpdate(_ state: CBManagerState) {
        switch(state) {
        case .poweredOn:
            print("powered on")
            bleManager.scan(forPeripherals: PRINTER_SERVICE)
        case .poweredOff:
            print("powered off")
        default:
            print("Uknown")
        }
    }
    
    func didPeripheralFound(_ peripheral: CBPeripheral, advertisementData: BLEAdvertisementData?, rssi RSSI: NSNumber?) {
        btDevices[peripheral.name!] = peripheral
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
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else {return}
        for characteristic in characteristics {
            currentCharacteristic = characteristic
            break
        }
    }
    
    @objc(ptInit)
    func ptInit() -> Void {
        bleManager = BLEManager.sharedInstance() as? BLEManager
        bleManager.delegate = self
    }
    
    @objc(ptGetDevices:rejecter:)
    func ptGetDevices(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        var devArray = [String]()
        
        for k in btDevices.keys {
            devArray.append(k)
        }
        
        resolve(devArray)
    }

    @objc(ptConnect:withResolver:withRejecter:)
    func ptConnect(name: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        
        if btDevices[name] == nil {
            reject("Connect event", "Invalid name.", PrinterError.printerConnect)
            return
        }
        bleManager.stopScan()
        self.peripheral = btDevices[name]
        self.peripheral.delegate = self
        bleManager.connect(self.peripheral)
        resolve(name)
    }
    
    func printerExecute(data: Data, label: String, err: PrinterError, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        
        if peripheral != nil {
            peripheral.writeValue(data, for: currentCharacteristic, type: .withoutResponse)
            resolve(true)
        } else {
            reject(label, "Not connected to the device.", err)
        }
    }
    
    @objc(ptSetPrinter:withResolver:withRejecter:)
    func ptSetPrinter(cmd: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        printerExecute(data: Data(bytes: printerCommands[cmd]!, count: printerCommands[cmd]!.count), label: "Set printer", err: PrinterError.printerSet, resolve: resolve, reject: reject)
    }
    
    @objc(ptPrintText:withResolver:withRejecter:)
    func ptPrintText(text: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        printerExecute(data: Data(text.utf8), label: "Print text", err: PrinterError.printerPrintText, resolve: resolve, reject: reject)
    }
    
    func generateImageCommand(img: UIImage) -> Data {
        let codeContent = Util.pixToEscRastBitImageCmd(
            src: Util.bitmapToBWPix(mBitmap: img)!
        )
        
        let cgImage = img.cgImage
        let value: [UInt8] = [
            29,
            118,
            48,
            0,
            UInt8((cgImage!.width * 2) / 8 % 256),
            UInt8((cgImage!.width * 2) / 8 / 256),
            UInt8((cgImage!.height * 2) % 256),
            UInt8((cgImage!.height * 2) / 256)
        ]
        
        var data = Data()
        data.append(Data(bytes: value, count: value.count))
        data.append(Data(bytes: codeContent, count: codeContent.count))
        
        return data
    }
    
    @objc(ptPrintImage:withResolver:withRejecter:)
    func ptPrintImage(name: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        let data = generateImageCommand(img: UIImage(named: name)!)
        printerExecute(data: data, label: "Print image", err: PrinterError.printerPrintImage, resolve: resolve, reject: reject)
    }
    
    @objc(ptPrintQRCode:size:withResolver:withRejecter:)
    func ptPrintQRCode(text: String, size: NSNumber, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        
        var thisSize = size.intValue
        
        if thisSize > 200 {
            reject("Print QR code", "Invalid size.", PrinterError.printerPrintQRCode)
            return
        }
        
        thisSize = thisSize / 2
        
        let data = text.data(using: String.Encoding.ascii)
        let cgsize = CGSize(width: thisSize, height: thisSize)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("L", forKey: "inputCorrectionLevel")

            guard let qrCodeImage = filter.outputImage else {
                return
            }

            let transform = CGAffineTransform(scaleX: cgsize.width / qrCodeImage.extent.size.width, y: cgsize.height / qrCodeImage.extent.size.height)
            let scaledQRCodeImage = qrCodeImage.transformed(by: transform)

            let context:CIContext = CIContext.init(options: nil)
            let cgImage:CGImage = context.createCGImage(scaledQRCodeImage, from: scaledQRCodeImage.extent)!

            //let imageData = generateImageCommand(img: UIImage(ciImage: scaledQRCodeImage))
            let imageData = generateImageCommand(img: UIImage.init(cgImage: cgImage))
            printerExecute(data: imageData, label: "Print QR code", err: PrinterError.printerPrintQRCode, resolve: resolve, reject: reject)
            return
        }
        
        reject("Print QR code", "Unable to create image.", PrinterError.printerPrintQRCode)
    }
    
    @objc(constantsToExport)
    func constantsToExport() -> [AnyHashable : Any]! {
      return [
        "PT_ALIGN_CENTER": "ALIGN_CENTER",
        "PT_ALIGN_LEFT": "ALIGN_LEFT",
        "PT_ALIGN_RIGHT": "ALIGN_RIGHT"
      ]
    }
}

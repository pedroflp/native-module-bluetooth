
import Foundation
import React
import CoreBluetooth

@objc(Bluetooth)
class Bluetooth: RCTEventEmitter, CBCentralManagerDelegate, CBPeripheralDelegate {
  var centralManager: CBCentralManager? = nil
  var peripherals: [String: CBPeripheral] = [:]
  let GenericAccessUUID = CBUUID(string: "0x1800")
  
  override func supportedEvents() -> [String]! {
    return ["peripherals", "connectedPeripheral"]
  }
  
  @objc override static func requiresMainQueueSetup() -> Bool {
      return false
  }
  
  @objc func startScan() {
    if(centralManager != nil) {
      centralManager?.stopScan()
    }
    centralManager =  CBCentralManager(delegate: self, queue: nil)
  }
  
  @objc func stopScan() {
    centralManager?.stopScan()
    centralManager = nil
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      centralManager?.scanForPeripherals(withServices: nil)
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    let alreadyInList = peripherals.contains { p in
       p.key == peripheral.name
    }
    
    if peripheral.name != nil && !alreadyInList {
      peripherals[peripheral.name!] = peripheral
    }
    
    sendPeripherals(peripherals: peripherals)
  }
  
  @objc func connectPeripheral(_ peripheralIdentifier: NSString) {
    let peripheral = peripherals.first { (key: String, value: CBPeripheral) in
      value.identifier.uuidString == peripheralIdentifier as String
    }
    
    if peripheral == nil && centralManager == nil {
      return
    }
        
    centralManager?.connect(peripheral!.value)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    sendConnectedPeripheral(peripheral: peripheral)
    peripheral.discoverServices([GenericAccessUUID])
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//    print("services \(peripheral.services)")
//    peripheral.service {
//      for service in services {
//        service.car
//      }
//    }
  }
  
  func sendPeripherals(peripherals: [String: CBPeripheral]) {
    let mappedPeripherals = peripherals.map { (key: String, value: CBPeripheral) in
      var peripheral: [String: [String: String]] = [:]
      peripheral[key] = [
        "name": value.name!,
        "identifier": value.identifier.uuidString
      ]
      return peripheral
    }
    
    sendEvent(withName: "peripherals", body: mappedPeripherals)
  }
  
  func sendConnectedPeripheral(peripheral: CBPeripheral) {
    let mappedPeripheral: [String: Any] = [
      "name": peripheral.name!,
      "identifier": peripheral.identifier.uuidString,
      "state": peripheral.state,
    ]
    
    sendEvent(withName: "connectedPeripheral", body: mappedPeripheral)
  }
  
}

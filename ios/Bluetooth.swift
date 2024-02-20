
import Foundation
import React
import CoreBluetooth

@objc(Bluetooth)
class Bluetooth: RCTEventEmitter, CBCentralManagerDelegate, CBPeripheralDelegate {
  var centralManager: CBCentralManager? = nil
  var peripherals: [String: CBPeripheral] = [:]
  var connectedPeripheral: CBPeripheral? = nil
  var characteristic: CBCharacteristic? = nil
  
  @objc override static func requiresMainQueueSetup() -> Bool {
      return false
  }
  
  // Define which events Swift will send to React side, to be listened there when used in sendEvent method here
  override func supportedEvents() -> [String]! {
    return ["peripherals", "connectedPeripheral", "disconnectedPeripheral", "transferData"]
  }
  
  
  // Extern method to be called in React side to star scanning for peripherals
  @objc func startScan() {
    if(centralManager != nil) {
      centralManager?.stopScan()
    }
    centralManager = CBCentralManager(delegate: self, queue: nil)
    
    print("🔎☑️ Start scanning")
  }
  
  
  // Delegate call when central manager is on and started to scanning for peripherals
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      centralManager?.scanForPeripherals(withServices: [])
    }
  }
  
  // Delegate call when discover new pripherals while scanning to send to React side
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    let alreadyInList = peripherals.contains { p in
       p.key == peripheral.name
    }
    
    if peripheral.name != nil && !alreadyInList {
      peripherals[peripheral.identifier.uuidString] = peripheral
    }
    
    sendPeripherals(peripherals: peripherals)
  }
  
  
  // Extern method to be called in React side to stop scanning for peripherals
  @objc func stopScan() {
    centralManager?.stopScan()
    centralManager = nil
    print("🔎🛑 Stop scanning")
  }
  
  
  // Extern method to be called in React side to connect central to peripheral
  @objc func connectPeripheral(_ peripheralIdentifier: NSString) {
    let peripheral = peripherals.first { (key: String, value: CBPeripheral) in
      value.identifier.uuidString == peripheralIdentifier as String
    }?.value
    
    if peripheral == nil || centralManager == nil {
      return
    }
    
    centralManager?.connect(peripheral!)
    print("⌛️📲 Connecting to peripheral \(String(describing: peripheral!.name))")
  }
  
  
  // Delegate call when connect central to peripheral
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.delegate = self
        
    if (peripheral.state == .connected) {
      centralManager?.stopScan()
      connectedPeripheral = peripheral
      sendConnectedPeripheral(peripheral: peripheral, state: "connected")
      peripheral.discoverServices(nil)
      
      print("✅🔎 Connected. Searching for services")
    }
    
  }
  
  
  // Delegate call when result discovering services between central and peripheral
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    peripheral.services?.forEach { service in
      peripheral.discoverCharacteristics(nil, for: service)
    }
    
    print("✅🔎 Services found. Searching characteristic in services")
  }
  
  // Delegate call when result discovering characteristics from service
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let char = service.characteristics?.first(where: { $0.uuid == transferCharacteristicUUID }) {
      peripheral.setNotifyValue(true, for: char)
      characteristic = char
      
      print("✅💬 Central & Peripheral ready to transfer")
    }
    
  }
            
  // Extern method to be called in React side to transfer data from central to peripheral
  @objc func transferData() {
    if connectedPeripheral == nil || characteristic == nil {
      return
    }
            
    let data = "Hey there".data(using: .utf8)
    
    connectedPeripheral?.writeValue(data!, for: characteristic!, type: CBCharacteristicWriteType.withResponse)
    
    print("🚚📦 Transfering data")
  }
  
    
  // Delegate call result for transfering data from central to peripheral
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      print("Erro ao escrever valor para a característica \(characteristic.uuid): \(error.localizedDescription)")
      return
    }
    
    sendTransferData(peripheral: peripheral)
    print("Succes writing to characteristic \(characteristic.uuid) ✅")
  }

  
  // Extern method to be called in React side to disconnect peripheral from central
  @objc func disconnectPeripheral(_ peripheralIdentifier: NSString) {
    let peripheral = peripherals.first { (key: String, value: CBPeripheral) in
      value.identifier.uuidString == peripheralIdentifier as String
    }!.value
    
    centralManager?.cancelPeripheralConnection(peripheral)
  }
  
  
  // Delegate call when disconnect central from peripheral
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    connectedPeripheral = nil
    sendDisconnectedPeripheral(peripheral: peripheral)
    
    print("❌📲 Peripheral \(String(describing: peripheral.name)) disconnected")
  }
  
  
  // Event sender to send events with data to React side //
  
  // Send list of all peripherals scanned
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
  
  // Send the current connected peripheral
  func sendConnectedPeripheral(peripheral: CBPeripheral, state: String) {
    let mappedPeripheral: [String: Any] = [
      "name": peripheral.name!,
      "identifier": peripheral.identifier.uuidString,
      "state": state,
    ]
    
    sendEvent(withName: "connectedPeripheral", body: mappedPeripheral)
  }
  
  // Send that peripheral was disconnected
  func sendDisconnectedPeripheral(peripheral: CBPeripheral) {
    let body: [String: Any] = [
      "peripheralId": peripheral.identifier.uuidString,
      "disconnected": true
    ]
    
    sendEvent(withName: "disconnectedPeripheral", body: body)
  }
  
  // Send that transfering data was successfully result
  func sendTransferData(peripheral: CBPeripheral) {
    let body: [String: String] = [
      "peripheralId": peripheral.identifier.uuidString,
      "message": "Os dados foram enviados com sucesso para este dispositivo"
    ]
    
    sendEvent(withName: "transferData", body: body )
  }
  
}

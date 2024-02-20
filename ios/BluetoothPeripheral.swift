//
//  BluetoothPeripheral.swift
//  bluetooth
//
//  Created by Pedro Felipe on 09/02/24.
//

import Foundation
import React
import CoreBluetooth

class BluetoothPeripheral: NSObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var characteristic: CBMutableCharacteristic!

    override init() {
        super.init()

        setupPeripheral()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    private func setupPeripheral() {
        characteristic = CBMutableCharacteristic(
            type: transferCharacteristicUUID,
            properties: [.write, .notify, .read],
            value: nil,
            permissions: [.writeable, .readable]
        )

        let service = CBMutableService(type: transferServiceUUID, primary: true)
        service.characteristics = [characteristic]

        peripheralManager.add(service)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
          print("Peri ligado")
          peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [characteristic.service!.uuid]])
        }
    }
  
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?) {
      if (error != nil) {
        print(error)
        return
      }
      
      print("advertising")
      print(peripheral.isAdvertising)
    }
  
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
          print("Central \(central.identifier.uuidString) se inscreveu nas notificações da característica \(characteristic.uuid)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic == characteristic {
                if let data = request.value {
                    if let stringValue = String(data: data, encoding: .utf8) {
                        print("Dados recebidos: \(stringValue)")
                    }
                }

                peripheralManager.respond(to: request, withResult: .success)
            } else {
                peripheralManager.respond(to: request, withResult: .attributeNotFound)
            }
        }
    }
}

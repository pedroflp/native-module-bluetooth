//
//  utils.swift
//  bluetooth
//
//  Created by Pedro Felipe on 09/02/24.
//

import Foundation
import CoreBluetooth

let TRANSFER_SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD666661"
let TRANSFER_CHARACTERISTIC_UUID = "AF0BADB1-5B99-43CD-917A-A77BC549E3CC"

let transferServiceUUID = CBUUID(string: TRANSFER_SERVICE_UUID)
let transferCharacteristicUUID = CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)


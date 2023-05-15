/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Transfer service and characteristics UUIDs
*/

import Foundation
import CoreBluetooth

struct TransferService {
    //0x2713-0000-1000-8000-00805f9b34fb
	static let serviceUUID = CBUUID(string: "E20A39F4-0000-1000-8000-00805f9b34fb")
	static let characteristicUUID = CBUUID(string: "08590F7E-0000-1000-8000-00805f9b34fb")
}

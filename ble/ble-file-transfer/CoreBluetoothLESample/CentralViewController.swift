/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A class to discover, connect, receive notifications and write data to peripherals by using a transfer service and characteristic.
 */

import UIKit
import CoreBluetooth
import os
import AVFoundation
import Opus

class CentralViewController: UIViewController {
    // UIViewController overrides, properties specific to this class, private helper methods, etc.

    var centralManager: CBCentralManager!

    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    var connectionIterationsComplete = 0
    
    let defaultIterations = 1     // change this value based on test usecase
    
    var receivedData = Data()

    // MARK: - view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])

        configureEngine(with: opusFormat)

        statusLabel.text = "decoding opus file..."

        self.decodeOpus(with: self.opusFormat)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Don't keep it going while we're not showing.
        centralManager.stopScan()
        os_log("Scanning stopped")

        receivedData.removeAll(keepingCapacity: false)
        
        super.viewWillDisappear(animated)
    }

    // MARK: - Private Section -

    @IBOutlet private var textView: UITextView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var playButton: UIButton!
    private var audioPlayer: AVAudioPlayer?

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var needsAudioBufferScheduled = true


    private lazy var opusFormat: AVAudioFormat = {
        guard let opusFormat = AVAudioFormat(opusPCMFormat: .float32, sampleRate: .opus16khz, channels: 1) else {
            fatalError("unable to generate desired opus format")
        }

        return opusFormat
    }()
    
    @IBAction private func didTapPlay(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
            playButton.setTitle("Play", for: .normal)
        } else {
            if needsAudioBufferScheduled {
                decodeOpus(with: opusFormat)
            }
            player.play()
            playButton.setTitle("Pause", for: .normal)
        }
    }


    private func configureEngine(with audioFormat: AVAudioFormat) {

        engine.attach(player)

        engine.connect(player, to: engine.outputNode, format: audioFormat)

        engine.prepare()

        do {
            try engine.start()
        } catch {
            print("Error starting the player: \(error.localizedDescription)")
        }
    }


    private func scheduleAudioBuffer(buffer: AVAudioPCMBuffer) {
        //seekFrame = 0

        player.scheduleBuffer(buffer, at: nil, options: [], completionCallbackType: .dataPlayedBack) { callbackType in
            print("finished scheduling for type : \(callbackType.rawValue)")
            print("player is playing: \(self.player.isPlaying)")
            print("last render time: \(self.player.lastRenderTime)")
        }
    }


    private func decodeOpus(with opusFormat: AVAudioFormat) {
        guard let opusDecoder = try? Opus.Decoder(format: opusFormat) else {
            statusLabel.text = "Unable to create an opus decoder, error"
            playButton.isEnabled = false
            return
        }

        //            let dataFromBytesChunk = Data([184, 126, 24, 175, 175, 20, 213, 243, 102, 80, 123, 76, 253, 54, 175, 84, 134, 102, 155, 137, 114, 147, 242, 176, 168, 186, 132, 197, 234, 217, 236, 38, 77, 177, 205, 20, 70, 129, 90, 23])
        //            let decodedData = try opusDecoder.decode(dataFromBytesChunk)
        let dataFromFile = Utilities.dataFromAudioFile(filename: "test", fileExtension: "opus")!
        let frameSizeInBytes = 40
        var offset = 0

        print("file size: \(dataFromFile.count)")
        print("frame size: \(frameSizeInBytes)")
        needsAudioBufferScheduled = false

        DispatchQueue.global(qos: .background).async { [weak self] in

            guard let this = self else {
                return
            }

            while offset < dataFromFile.count {
                let upperLimit = min(offset + frameSizeInBytes, dataFromFile.count)
                os_log("\ndecoding from offset: %d to upper limit: %d ~~~", offset, upperLimit)
                let decodingDebugText = "\ndecoding from offset: \(offset) to upper limit: \(upperLimit)"
                DispatchQueue.main.async {
                    this.textView.text.append(decodingDebugText)
                }
                let opusFrame = dataFromFile[offset..<upperLimit]
                do {
                    let decodedFrame = try opusDecoder.decode(opusFrame)
                    os_log("successfully decoded ++++++++++")
                    os_log("decodedFrame: %@", decodedFrame.debugDescription)
                    //self.textView.text.append("\ndecoded frame: \(decodedFrame.debugDescription)\n")
                    os_log("++++++++++++++++++++++++++++++\n")
                    this.scheduleAudioBuffer(buffer: decodedFrame)
                } catch {
                    os_log("failed decoding opus frame ----------")
                    os_log("error: %@", error.localizedDescription)
                    //self.textView.text.append("\ndecoding error: \(error.localizedDescription)\n")
                    os_log(" ------------------------------\n")
                }
                offset += frameSizeInBytes
            }
            this.needsAudioBufferScheduled = true
            DispatchQueue.main.sync {
                this.statusLabel.text = "finished decoding opus file"
                this.playButton.isEnabled = true
            }
        }
    }


    /*
     * We will first check if we are already connected to our counterpart
     * Otherwise, scan for peripherals - specifically for our service's 128bit CBUUID
     */
    private func retrievePeripheral() {

        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [TransferService.serviceUUID]))

        os_log("Found connected Peripherals with transfer service: %@", connectedPeripherals)

        DispatchQueue.main.async {
            self.statusLabel.text = "Found connected peripherals with transfer service: \(connectedPeripherals.debugDescription)"
        }

        if let connectedPeripheral = connectedPeripherals.last {
            os_log("Connecting to peripheral %@", connectedPeripheral)
            self.discoveredPeripheral = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }

    /*
     *  Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    private func cleanup() {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = discoveredPeripheral,
              case .connected = discoveredPeripheral.state else { return }

        for service in (discoveredPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.characteristicUUID && characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    self.discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                }
            }
        }

        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }

}

extension CentralViewController: CBCentralManagerDelegate {
    // implementations of the CBCentralManagerDelegate methods

    /*
     *  centralManagerDidUpdateState is a required protocol method.
     *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
     *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
     *  the Central is ready to be used.
     */
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            os_log("CBManager is powered on")
            retrievePeripheral()
        case .poweredOff:
            os_log("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            os_log("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            if #available(iOS 13.0, *) {
                switch central.authorization {
                case .denied:
                    os_log("You are not authorized to use Bluetooth")
                case .restricted:
                    os_log("Bluetooth is restricted")
                default:
                    os_log("Unexpected authorization")
                }
            } else {
                // Fallback on earlier versions
            }
            return
        case .unknown:
            os_log("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            os_log("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            os_log("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }

    /*
     *  This callback comes whenever a peripheral that is advertising the transfer serviceUUID is discovered.
     *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
     *  we start the connection process
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending on your app’s use case.
        guard RSSI.intValue >= -50
        else {
            os_log("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
            return
        }
        
        os_log("Discovered %s with RSSI: %d", String(describing: peripheral.name), RSSI.intValue)

        DispatchQueue.main.async {
            let message = "Discovered peripheral: \(peripheral.name ?? "NO NAME") with RSSI: \(RSSI.intValue)\n"
            self.textView.text.append(message)
            self.statusLabel.text = message
        }


        // Device is in range - have we already seen it?
        if discoveredPeripheral != peripheral {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it.
            discoveredPeripheral = peripheral
            
            // And finally, connect to the peripheral.
            os_log("Connecting to perhiperal %@", peripheral)
            centralManager.connect(peripheral, options: nil)
        }
    }

    /*
     *  If the connection fails for whatever reason, we need to deal with it.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        os_log("Failed to connect to %@. %s", peripheral, String(describing: error))

        DispatchQueue.main.async {
            let msg = "Failed to connect to \(peripheral.name ?? "NO NAME") with error: \(String(describing: error))\n"
            self.textView.text.append(msg)
            self.statusLabel.text = msg
        }

        cleanup()
    }
    
    /*
     *  We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("Peripheral Connected")
        
        // Stop scanning
        centralManager.stopScan()
        os_log("Scanning stopped")

        DispatchQueue.main.async {
            let msg = "connected to peripheral: \(peripheral.name ?? "NO NAME"). Scanning stopped \n"
            self.textView.text.append(msg)
            self.statusLabel.text = msg
        }

        // set iteration info
        connectionIterationsComplete += 1

        // Clear the data that we may already have
        receivedData.removeAll(keepingCapacity: false)
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([TransferService.serviceUUID])
    }
    
    /*
     *  Once the disconnection happens, we need to clean up our local copy of the peripheral
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("Perhiperal Disconnected")
        discoveredPeripheral = nil
        
        // We're disconnected, so start scanning again
        if connectionIterationsComplete < defaultIterations {
            retrievePeripheral()
        } else {
            os_log("Connection iterations completed")
        }
    }

}

extension CentralViewController: CBPeripheralDelegate {
    // implementations of the CBPeripheralDelegate methods

    /*
     *  The peripheral letting us know when services have been invalidated.
     */
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
        for service in invalidatedServices where service.uuid == TransferService.serviceUUID {
            os_log("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([TransferService.serviceUUID])
        }
    }

    /*
     *  The Transfer Service was discovered
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            os_log("Error discovering services: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics([TransferService.characteristicUUID], for: service)
        }
    }
    
    /*
     *  The Transfer characteristic was discovered.
     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Deal with errors (if any).
        if let error = error {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicUUID {
            // If it is, subscribe to it
            transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        // Once this is complete, we just need to wait for the data to come in.
    }
    
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard let characteristicData = characteristic.value else { return }

        // Check for end of file
        if let stringFromData = String(data: characteristicData, encoding: .utf8),
           stringFromData == "EOM" {
            os_log("Received EOM")

            // End-of-message case: show the data.
            // Dispatch the text view update to the main queue for updating the UI, because
            // we don't know which thread this method will be called back on.
            DispatchQueue.main.async() {
                self.textView.text.append("Finished receiving file")
                self.playButton.isEnabled = true
            }
        } else {
            // Otherwise, just append the data to what we have previously received.
            os_log("Received %d bytes", characteristicData.count)
            receivedData.append(characteristicData)
            DispatchQueue.main.async() {
                self.textView.text.append("received \(characteristicData.count) bytes. Total so far: \(self.receivedData.count) \n")
            }
        }
    }

    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            os_log("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            os_log("Notification began on %@", characteristic)
        } else {
            // Notification has stopped, so disconnect from the peripheral
            os_log("Notification stopped on %@. Disconnecting", characteristic)
            cleanup()
        }
        
    }
}

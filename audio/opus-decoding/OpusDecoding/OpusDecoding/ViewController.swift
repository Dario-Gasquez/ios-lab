//
//  ViewController.swift
//  OpusDecoding
//
//  Created by Dario on 05/01/2022.
//

import UIKit
import AVFoundation
import Opus

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false) else {
            print("unable to create audio format")
            return
        }

        // Create output file
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsURL.appendingPathComponent("test-audio.caf")
            outputFile = try AVAudioFile(forWriting: outputURL, settings: audioFormat.settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let audioFile = outputFile  else {
            assertionFailure("outputFile not present")
            return
        }

        decodeOpus(to: audioFile)

        print("=== FINISHED DECODING, CONFIGURE PLAYER ====")
        do {
            player = try AVAudioPlayer(contentsOf: audioFile.url)
        } catch {
            print("unable to create audio player. Error: \(error)")
        }
    }

    // MARK: - Private
    @IBOutlet private var decodingStateLabel: UILabel!
    @IBOutlet private var playButton: UIButton!

    private enum DecodingState {
        case idle
        case decoding
        case didFail(errorDescription: String)
        case didSucceed
    }

    private var outputFile: AVAudioFile?
    private var player: AVAudioPlayer?
    private var decodingState: DecodingState = .idle {
        didSet {
            updateUI()
        }
    }

    @IBAction private func didTapPlay(_ sender: UIButton) {
        player?.play()
    }


    private func updateUI() {
        decodingStateLabel.text = "Decoding State: \(decodingState)"
        switch decodingState {
        case .idle, .decoding:
            playButton.isEnabled = false
            break
        case .didFail(let errorDescription):
            decodingStateLabel.text?.append(contentsOf: "\n error: \(errorDescription)")
            playButton.isEnabled = false
            break
        case .didSucceed:
            playButton.isEnabled = true
            break
        }
    }


    private func decodeOpus(to outputFile: AVAudioFile) {
        do {

            //convert from opus
            guard let opusFormat = AVAudioFormat(opusPCMFormat: .float32, sampleRate: .opus16khz, channels: 1) else {
                print("unable to create opusFormat")
                decodingState = .didFail(errorDescription: "Unable to create opusFormat")
                return
            }

            let opusDecoder = try Opus.Decoder(format: opusFormat)

            let dataFromFile = Utilities.dataFromAudioFile(filename: "test", fileExtension: "opus")!
            let frameSizeInBytes = 40
            var offset = 0

            print("file size: \(dataFromFile.count)")
            print("frame size: \(frameSizeInBytes)")

            decodingState = .decoding
            while offset < dataFromFile.count {
                let upperLimit = min(offset + frameSizeInBytes, dataFromFile.count)
                print("\ndecoding from offset: \(offset) to upper limit: \(upperLimit) ~~~~~~~~~~~~~~~")
                let opusFrameData = dataFromFile[offset..<upperLimit]
                do {
                    let decodedFrame = try opusDecoder.decode(opusFrameData)
                    print("successfully decoded ++++++++++")
                    print("decodedFrame: \(decodedFrame.debugDescription)")
                    print("++++++++++++++++++++++++++++++\n")
                    try outputFile.write(from: decodedFrame)
                } catch {
                    print("failed decoding opus frame ----------")
                    print("error: \(error.localizedDescription)")
                    print(" ------------------------------\n")
                }
                offset += frameSizeInBytes
            }
        } catch {
            print("error: \(error.localizedDescription)")
            decodingState = .didFail(errorDescription: error.localizedDescription)
        }

        decodingState = .didSucceed
    }
}

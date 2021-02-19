import SwiftUI
import AVFoundation

struct Waveform: View {
    let audioFile: AVAudioFile
    let waveformData: [WaveformData] = []
    
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                updateWaveformData()
            }
    }
    
    func updateWaveformData() {
        guard
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        else { return }
        
        #warning("Handle errors")
        try? audioFile.read(into: buffer)
        print("Read")
        let channels = buffer.format.channelCount
        let length = buffer.frameLength
        
        #warning("handle ints if necessary")
        guard let floatChannelData = buffer.floatChannelData else { return }
        for s in 0..<Int(length) {
            var sample: Float = 0
            for c in 0..<Int(channels) {
                if floatChannelData[c][s].magnitude > sample.magnitude {
                    sample = floatChannelData[c][s]
                }
            }
        }
        print("Finished")
    }
}

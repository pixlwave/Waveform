import SwiftUI
import AVFoundation

struct Waveform: View {
    let audioFile: AVAudioFile
    
    private let audioBuffer: AVAudioPCMBuffer?
    @State private var waveformData: [WaveformData] = []
    
    @State private var frameSize: CGSize = .zero
    
    init(audioFile: AVAudioFile) {
        self.audioFile = audioFile
        self.audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        
        #warning("Handle errors")
        guard let audioBuffer = audioBuffer else { return }
        try? audioFile.read(into: audioBuffer)
        print("Read")
    }
    
    var body: some View {
        GeometryReader { geometry in
            WaveformRenderer(waveformData: $waveformData)
                .preference(key: SizeKey.self, value: geometry.size)
        }
        .onPreferenceChange(SizeKey.self) {
            guard frameSize != $0 else { return }
            frameSize = $0
        }
        .onChange(of: frameSize) {
            print("Frame size \($0)")
            updateWaveformData(width: $0.width)
        }
    }
    
    func updateWaveformData(width: CGFloat) {
        waveformData = []
        DispatchQueue.global(qos: .userInteractive).async {
            guard let buffer = audioBuffer else { return }
            
            let channels = Int(buffer.format.channelCount)
            let length = Int(buffer.frameLength)
            let samplesPerPoint = length / Int(width)
            
            #warning("handle ints if necessary")
            guard let floatChannelData = buffer.floatChannelData else { return }
            
            DispatchQueue.concurrentPerform(iterations: Int(width)) { point in
                var data: WaveformData = .zero
                for sample in 0..<samplesPerPoint {
                    for channel in 0..<channels {
                        let value = floatChannelData[channel][(point * samplesPerPoint) + sample]
                        data.min = min(value, data.min)
                        data.max = max(value, data.max)
                    }
                }
                DispatchQueue.main.async { waveformData.append(data) }
            }
        }
    }
}

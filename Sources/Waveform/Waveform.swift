import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    let audioFile: AVAudioFile
    
    private let audioBuffer: AVAudioPCMBuffer?
    @State private var waveformData: [WaveformData] = []
    
    @State private var frameSize: CGSize = .zero
    
    init(audioFile: AVAudioFile) {
        self.audioFile = audioFile
        self.audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        
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
            generateWaveformData(width: $0.width)
        }
    }
    
    func generateWaveformData(width: CGFloat) {
        waveformData = []
        DispatchQueue.global(qos: .userInteractive).async {
            guard let buffer = audioBuffer else { return }
            
            let channels = Int(buffer.format.channelCount)
            let length = Int(buffer.frameLength)
            let samplesPerPoint = length / Int(width)
            
            guard let floatChannelData = buffer.floatChannelData else { return }
            
            DispatchQueue.concurrentPerform(iterations: Int(width)) { point in
                var data: WaveformData = .zero
                    for channel in 0..<channels {
                        let pointer = floatChannelData[channel].advanced(by: point * samplesPerPoint)
                        let stride = vDSP_Stride(buffer.stride)
                        let length = vDSP_Length(samplesPerPoint)
                        
                        var value: Float = 0
                        
                        // calculate minimum value for point
                        vDSP_minv(pointer, stride, &value, length)
                        data.min = min(value, data.min)
                        
                        // calculate maximum value for point
                        vDSP_maxv(pointer, stride, &value, length)
                        data.max = max(value, data.max)
                    }
                DispatchQueue.main.async { waveformData.append(data) }
            }
        }
    }
}

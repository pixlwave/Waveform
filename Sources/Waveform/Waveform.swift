import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    let audioFile: AVAudioFile
    
    private let audioBuffer: AVAudioPCMBuffer
    @State private var generator: WaveformGenerator?
    @State private var waveformData: [WaveformData] = []
    
    @State private var frameSize: CGSize = .zero
    
    @Binding var startSample: Int
    @Binding var endSample: Int
    
    init?(audioFile: AVAudioFile, startSample: Binding<Int>, endSample: Binding<Int>) {
        let capacity = AVAudioFrameCount(audioFile.length)
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: capacity) else { return nil }
        
        do {
            try audioFile.read(into: audioBuffer)
        } catch {
            return nil
        }
        
        self.audioFile = audioFile
        self.audioBuffer = audioBuffer
        
        _startSample = startSample
        _endSample = endSample
    }
    
    var body: some View {
        GeometryReader { geometry in
            WaveformRenderer(waveformData: waveformData)
                .preference(key: SizeKey.self, value: geometry.size)
        }
        .onPreferenceChange(SizeKey.self) {
            guard frameSize != $0 else { return }
            frameSize = $0
        }
        .onChange(of: frameSize) {
            print("Frame size \($0)")
            generateWaveformData()
        }
        .onChange(of: startSample) { _ in
            generateWaveformData()
        }
        .onChange(of: endSample) { _ in
            generateWaveformData()
        }
    }
    
    func generateWaveformData() {
        generator?.cancel()
        generator = WaveformGenerator(audioBuffer: audioBuffer)
        
        waveformData = [WaveformData](repeating: .zero, count: Int(frameSize.width))
        generator?.generateWaveformData(width: frameSize.width, startSample: startSample, endSample: endSample) { index, data in
            self.waveformData[index] = data
        }
    }
}

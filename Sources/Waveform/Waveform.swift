import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    let audioFile: AVAudioFile
    
    private let audioBuffer: AVAudioPCMBuffer?
    @State private var generator: WaveformGenerator?
    @State private var waveformData: [WaveformData] = []
    
    @State private var frameSize: CGSize = .zero
    
    @State private var currentZoom: CGFloat = 1
    @State private var gestureZoom: CGFloat = 1
    
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
                .scaleEffect(x: currentZoom * gestureZoom, y: 1, anchor: .center)
        }
        .onPreferenceChange(SizeKey.self) {
            guard frameSize != $0 else { return }
            frameSize = $0
        }
        .onChange(of: frameSize) {
            print("Frame size \($0)")
            generateWaveformData(width: $0.width)
        }
        .gesture(magnification)
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                gestureZoom = amount
            }
            .onEnded { finalAmount in
                currentZoom *= finalAmount
                gestureZoom = 1
            }
    }
    
    func generateWaveformData(width: CGFloat) {
        generator?.cancel()
        generator = WaveformGenerator(audioBuffer: audioBuffer)
        
        waveformData = [WaveformData](repeating: .zero, count: Int(width))
        generator?.generateWaveformData(width: width) { index, data in
            self.waveformData[index] = data
        }
    }
}

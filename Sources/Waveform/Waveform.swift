import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    let audio: WaveformAudio
    
    @Binding var startSample: Int
    @Binding var endSample: Int
    
    @State private var generateTask: GenerateWaveformTask?
    @State private var waveformData: [WaveformData] = []
    
    @State private var frameSize: CGSize = .zero
    
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
        generateTask?.cancel()
        generateTask = GenerateWaveformTask(audioBuffer: audio.audioBuffer)
        
        waveformData = [WaveformData](repeating: .zero, count: Int(frameSize.width))
        generateTask?.generateWaveformData(width: frameSize.width, startSample: startSample, endSample: endSample) { index, data in
            self.waveformData[index] = data
        }
    }
}

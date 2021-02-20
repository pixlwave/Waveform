import SwiftUI
import AVFoundation
import Accelerate

struct Waveform: View {
    @ObservedObject var audio: WaveformAudio
    
    @Binding var startSample: Int
    @Binding var endSample: Int
    
    @State private var frameSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            WaveformRenderer(waveformData: audio.sampleData)
                .preference(key: SizeKey.self, value: geometry.size)
        }
        .onPreferenceChange(SizeKey.self) {
            guard frameSize != $0 else { return }
            frameSize = $0
        }
        .onChange(of: frameSize) {
            print("Frame size \($0)")
            refreshData()
        }
        .onChange(of: startSample) { _ in
            refreshData()
        }
        .onChange(of: endSample) { _ in
            refreshData()
        }
    }
    
    func refreshData() {
        audio.refreshData(width: frameSize.width, startSample: startSample, endSample: endSample)
    }
}

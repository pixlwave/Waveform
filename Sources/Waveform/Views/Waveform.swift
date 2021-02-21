import SwiftUI
import AVFoundation
import Accelerate

typealias SampleRange = Range<Int>

struct Waveform: View {
    @ObservedObject var audio: WaveformAudio
    
    @State private var zoomGestureValue: CGFloat = 1
    @State private var panGestureValue: CGFloat = 0
    
    @Binding var selectedSamples: SampleRange
    @Binding var selectionBlendMode: BlendMode
    
    @Environment(\.colorScheme) var colorScheme
    
    init(audio: WaveformAudio, selectedSamples: Binding<SampleRange>, selectionBlendMode: Binding<BlendMode>? = nil) {
        self.audio = audio
        self._selectedSamples = selectedSamples
        
        self._selectionBlendMode = .constant(.normal)   // needs initialising before the next line?
        self._selectionBlendMode = selectionBlendMode ?? (colorScheme == .light ? .constant(.screen) : .constant(.multiply))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Renderer(waveformData: audio.sampleData)
                    .preference(key: SizeKey.self, value: geometry.size)
                Highlight(selectedSamples: selectedSamples)
                    .foregroundColor(.accentColor)
                    .opacity(0.7)
                    .blendMode(selectionBlendMode)
            }
            .padding(.bottom, 30)
            
            Handle(selectedSamples: $selectedSamples)
                .foregroundColor(.accentColor)
        }
        .gesture(SimultaneousGesture(zoom, pan))
        .environmentObject(audio)
        .onPreferenceChange(SizeKey.self) {
            guard audio.width != $0.width else { return }
            audio.width = $0.width
        }
    }
    
    var zoom: some Gesture {
        MagnificationGesture()
            .onChanged {
                let zoomAmount = $0 / zoomGestureValue
                zoom(amount: zoomAmount)
                zoomGestureValue = $0
            }
            .onEnded {
                let zoomAmount = $0 / zoomGestureValue
                zoom(amount: zoomAmount)
                zoomGestureValue = 1
            }
    }
    
    var pan: some Gesture {
        DragGesture()
            .onChanged {
                let panAmount = $0.translation.width - panGestureValue
                pan(amount: panAmount)
                panGestureValue = $0.translation.width
            }
            .onEnded {
                let panAmount = $0.translation.width - panGestureValue
                pan(amount: panAmount)
                panGestureValue = 0
            }
    }
    
    var samplesPerPoint: Int {
        guard audio.width != 0 else { return 0 }
        return audio.renderSamples.count / Int(audio.width)
    }
    
    func zoom(amount: CGFloat) {
        let count = audio.renderSamples.count
        let newCount = CGFloat(count) / amount
        let delta = (count - Int(newCount)) / 2
        let renderStartSample = max(0, audio.renderSamples.lowerBound + delta)
        let renderEndSample = min(audio.renderSamples.upperBound - delta, Int(audio.audioBuffer.frameLength))
        audio.renderSamples = renderStartSample..<renderEndSample
    }
    
    func pan(amount: CGFloat) {
        let delta = samplesPerPoint * Int(amount)
        var renderStartSample = audio.renderSamples.lowerBound - delta
        var renderEndSample = audio.renderSamples.upperBound - delta
        if renderStartSample < 0 {
            renderStartSample = 0
            renderEndSample = audio.renderSamples.count
        } else if renderEndSample > Int(audio.audioBuffer.frameLength) {
            renderEndSample = Int(audio.audioBuffer.frameLength)
            renderStartSample = renderEndSample - audio.renderSamples.count
        }
        audio.renderSamples = renderStartSample..<renderEndSample
    }
}

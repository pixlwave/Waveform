import SwiftUI
import AVFoundation
import Accelerate

/// A range of integers representing samples from an AVAudioFile.
public typealias SampleRange = Range<Int>

/// An interactive waveform generated from an `AVAudioFile`.
public struct Waveform: View {
    @ObservedObject var audio: WaveformAudio
    
    @State private var zoomGestureValue: CGFloat = 1
    @State private var panGestureValue: CGFloat = 0
    @Binding var selectedSamples: SampleRange
    
    /// Creates an instance powered by the supplied generator.
    /// - Parameters:
    ///   - audio: The object that will supply waveform data.
    ///   - selectedSamples: A binding to a `SampleRange` to update with the selection chosen in the waveform.
    public init(audio: WaveformAudio, selectedSamples: Binding<SampleRange>) {
        self.audio = audio
        self._selectedSamples = selectedSamples
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // invisible rectangle needed to register gestures that aren't on top of the waveform
                Rectangle()
                    .foregroundColor(Color(.systemBackground).opacity(0.01))
                
                Renderer(waveformData: audio.sampleData)
                    .preference(key: SizeKey.self, value: geometry.size)
                Highlight(selectedSamples: selectedSamples)
                    .foregroundColor(.accentColor)
                    .opacity(0.7)
            }
            .padding(.bottom, 30)
            
            StartHandle(selectedSamples: $selectedSamples)
                .foregroundColor(.accentColor)
            EndHandle(selectedSamples: $selectedSamples)
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
                pan(offset: -panAmount)
                panGestureValue = $0.translation.width
            }
            .onEnded {
                let panAmount = $0.translation.width - panGestureValue
                pan(offset: -panAmount)
                panGestureValue = 0
            }
    }
    
    func zoom(amount: CGFloat) {
        let count = audio.renderSamples.count
        let newCount = CGFloat(count) / amount
        let delta = (count - Int(newCount)) / 2
        let renderStartSample = max(0, audio.renderSamples.lowerBound + delta)
        let renderEndSample = min(audio.renderSamples.upperBound - delta, Int(audio.audioBuffer.frameLength))
        audio.renderSamples = renderStartSample..<renderEndSample
    }
    
    func pan(offset: CGFloat) {
        let count = audio.renderSamples.count
        var startSample = audio.sample(audio.renderSamples.lowerBound, with: offset)
        var endSample = startSample + count
        
        if startSample < 0 {
            startSample = 0
            endSample = audio.renderSamples.count
        } else if endSample > Int(audio.audioBuffer.frameLength) {
            endSample = Int(audio.audioBuffer.frameLength)
            startSample = endSample - audio.renderSamples.count
        }
        
        audio.renderSamples = startSample..<endSample
    }
}

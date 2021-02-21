import SwiftUI
import AVFoundation
import Waveform

struct ContentView: View {
    @StateObject var generator = WaveformGenerator(audioFile: try! AVAudioFile(forReading: AudioResources.aberration))!
    @State var selectedSamples = 3_000_000..<5_000_000

    @State var isShowingDebug = false

    @State var start: Double = 0
    @State var end: Double = 1
    
    @State var waveformColor = Color.primary
    @State var backgroundColor = Color.clear
    @State var selectionColor = Color.accentColor

    var body: some View {
        VStack {
            Waveform(generator: generator, selectedSamples: $selectedSamples)
                .layoutPriority(1)
                .foregroundColor(waveformColor)
                .background(backgroundColor)
                .accentColor(selectionColor)
            
            HStack {
                Text("Debug:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                Spacer()
                Button { withAnimation { isShowingDebug.toggle() } } label: {
                    Image(systemName: isShowingDebug ? "chevron.down.circle" : "chevron.up.circle" )
                }
            }
            if isShowingDebug {
                VStack {
                    Slider(value: $start, in: 0...1)
                    Slider(value: $end, in: 0...1)
                    HStack {
                        ColorPicker("Waveform:", selection: $waveformColor)
                        Spacer()
                        ColorPicker("Background:", selection: $backgroundColor)
                        Spacer()
                        ColorPicker("Selection:", selection: $selectionColor)
                    }
                }
                .transition(.offset(x: 0, y: 150))
            }
        }
        .padding()
        .onChange(of: start) {
            let sample = Int($0 * Double(generator.audioFile.length))
            let startSample = sample < generator.renderSamples.upperBound ? sample : generator.renderSamples.upperBound - 1
            generator.renderSamples = startSample..<generator.renderSamples.upperBound
        }
        .onChange(of: end) {
            let sample = Int($0 * Double(generator.audioFile.length))
            let endSample = sample > generator.renderSamples.lowerBound ? sample : generator.renderSamples.lowerBound + 1
            generator.renderSamples = generator.renderSamples.lowerBound..<endSample
        }
        .onChange(of: generator.renderSamples) {
            start = Double($0.lowerBound) / Double(generator.audioBuffer.frameLength)
            end = Double($0.upperBound) / Double(generator.audioBuffer.frameLength)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

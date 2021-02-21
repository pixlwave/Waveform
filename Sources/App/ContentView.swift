import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var audio = WaveformAudio(audioFile: try! AVAudioFile(forReading: AudioResources.aberration))!
    @State var selectedSamples = 3_000_000..<5_000_000

    @State var isShowingDebug = false

    @State var start: Double = 0
    @State var end: Double = 1
    
    @State var waveformColor = Color.primary
    @State var backgroundColor = Color.clear
    @State var selectionColor = Color.accentColor

    var body: some View {
        VStack {
            Waveform(audio: audio, selectedSamples: $selectedSamples)
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
            let sample = Int($0 * Double(audio.audioFile.length))
            let startSample = sample < audio.renderSamples.upperBound ? sample : audio.renderSamples.upperBound - 1
            audio.renderSamples = startSample..<audio.renderSamples.upperBound
        }
        .onChange(of: end) {
            let sample = Int($0 * Double(audio.audioFile.length))
            let endSample = sample > audio.renderSamples.lowerBound ? sample : audio.renderSamples.lowerBound + 1
            audio.renderSamples = audio.renderSamples.lowerBound..<endSample
        }
        .onChange(of: audio.renderSamples) {
            start = Double($0.lowerBound) / Double(audio.audioBuffer.frameLength)
            end = Double($0.upperBound) / Double(audio.audioBuffer.frameLength)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

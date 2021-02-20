import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var audio = WaveformAudio(audioFile: try! AVAudioFile(forReading: AudioResources.aberration))!
    
    @State var startSample: Int = 0
    @State var endSample: Int = 0
    
    @State var start: Double = 0
    @State var end: Double = 1
    
    var body: some View {
        VStack {
            Waveform(audio: audio, startSample: $startSample, endSample: $endSample)
                .environmentObject(audio)
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                .cornerRadius(15)
            Slider(value: $start, in: 0...1)
            Slider(value: $end, in: 0...1)
        }
        .padding()
        .onChange(of: start) {
            let sample = Int($0 * Double(audio.audioFile.length))
            startSample = sample < endSample ? sample : endSample - 1
        }
        .onChange(of: end) {
            let sample = Int($0 * Double(audio.audioFile.length))
            endSample = sample > startSample ? sample : startSample + 1
        }
        .onAppear {
            endSample = Int(audio.audioFile.length)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import SwiftUI
import AVFoundation

struct ContentView: View {
    let audioFile = try! AVAudioFile(forReading: AudioResources.aberration)
    
    @State var startSample: Int = 0
    @State var endSample: Int = 0
    
    @State var start: Double = 0
    @State var end: Double = 1
    
    var body: some View {
        VStack {
            Waveform(audioFile: audioFile, startSample: $startSample, endSample: $endSample)
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                .cornerRadius(15)
            Slider(value: $start, in: 0...1) { isEditing in
                guard !isEditing else { return }
                let sample = Int(start * Double(audioFile.length))
                startSample = sample < endSample ? sample : endSample - 1
            }
            Slider(value: $end, in: 0...1) { isEditing in
                guard !isEditing else { return }
                let sample = Int(end * Double(audioFile.length))
                endSample = sample > startSample ? sample : startSample + 1
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

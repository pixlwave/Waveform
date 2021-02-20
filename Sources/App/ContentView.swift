import SwiftUI
import AVFoundation

struct ContentView: View {
    let audioFile = try! AVAudioFile(forReading: AudioResources.aberration)
    
    var body: some View {
        Waveform(audioFile: audioFile)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

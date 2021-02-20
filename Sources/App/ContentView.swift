import SwiftUI
import AVFoundation

struct ContentView: View {
    let audioFile = try! AVAudioFile(forReading: AudioResources.aberration)
    
    var body: some View {
        Waveform(audioFile: audioFile)
            .background(Color(red: 0.9, green: 0.9, blue: 0.9))
            .cornerRadius(15)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

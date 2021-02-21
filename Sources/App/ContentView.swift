import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var audio = WaveformAudio(audioFile: try! AVAudioFile(forReading: AudioResources.aberration))!
    @State var selectedSamples = 3_000_000..<5_000_000

    @State var isShowingDebug = true

    @State var start: Double = 0
    @State var end: Double = 1
    
    @State var waveformColor = Color.primary
    @State var backgroundColor = Color.clear
    @State var selectionColor = Color.accentColor
    @State var blendMode = BlendMode.screen

    var body: some View {
        VStack {
            Waveform(audio: audio, selectedSamples: $selectedSamples, selectionBlendMode: $blendMode)
                .layoutPriority(1)
                .foregroundColor(waveformColor)
                .background(backgroundColor)
                .accentColor(selectionColor)
                .cornerRadius(15)
            
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
                        ColorPicker("Waveform Colour:", selection: $waveformColor)
                        Spacer()
                        ColorPicker("Background Colour:", selection: $backgroundColor)
                        Spacer()
                        ColorPicker("Selection Colour:", selection: $selectionColor)
                        Spacer()
                        Picker("Blend Mode:", selection: $blendMode) {
                            Group {
                                Text("normal").tag(BlendMode.normal)
                                Text("multiply").tag(BlendMode.multiply)
                                Text("screen").tag(BlendMode.screen)
                                Text("overlay").tag(BlendMode.overlay)
                                Text("darken").tag(BlendMode.darken)
                                Text("lighten").tag(BlendMode.lighten)
                                Text("colorDodge").tag(BlendMode.colorDodge)
                            }
                            Group {
                                Text("colorBurn").tag(BlendMode.colorBurn)
                                Text("softLight").tag(BlendMode.softLight)
                                Text("hardLight").tag(BlendMode.hardLight)
                                Text("difference").tag(BlendMode.difference)
                                Text("exclusion").tag(BlendMode.exclusion)
                                Text("hue").tag(BlendMode.hue)
                                Text("saturation").tag(BlendMode.saturation)
                            }
                            Group {
                                Text("color").tag(BlendMode.color)
                                Text("luminosity").tag(BlendMode.luminosity)
                                Text("sourceAtop").tag(BlendMode.sourceAtop)
                                Text("destinationOver").tag(BlendMode.destinationOver)
                                Text("destinationOut").tag(BlendMode.destinationOut)
                                Text("plusDarker").tag(BlendMode.plusDarker)
                                Text("plusLighter").tag(BlendMode.plusLighter)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .transition(.offset(x: 0, y: 100))
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

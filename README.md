# Waveform

A SwiftUI Package to display an interactive waveform of an audio file.

![Zooming Waveform](https://github.com/pixlwave/Waveform/blob/main/Images/zoom.gif?raw=true)

The project is currently in a very early stage having been created as part of SwiftUI Jam 2021. Code from the end of the Jam will be in the `swiftuijam` branch.

## Installation

To include it in your Xcode project click `File | Swift Packages | Add Package Dependency…` and enter the following url:

```
https://github.com/pixlwave/Waveform
```

For now, you'll need to select `Branch` and ensure it's set to `main` until v0.1.0 is released.

## Usage

![Waveform Selection](https://github.com/pixlwave/Waveform/blob/main/Images/select.gif?raw=true)

To use Waveform create a `WaveformGenerator` object with your audio file:

```swift
let audioFile = try! AVAudioFile(forReading: URL))!
let generator = WaveformGenerator(audioFile: audioFile)   // this generator object is observable
```

And then pass this to a `Waveform` along with a selection range if you need this:

```swift
var body: some View {
    Waveform(generator: generator, selectedSamples: $selection, selectionEnabled: .constant(true))
}
```

## Caveats

- More work is required on optimisation for acceptable performance on older devices.
- Any audio file you use is loaded into memory in the `WaveformGenerator`. For now it would be worth watching your app's memory usage until this is addressed.

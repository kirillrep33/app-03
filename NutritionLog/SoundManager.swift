import Foundation
import AVFoundation
import SwiftUI

final class SoundManager {
    static let shared = SoundManager()
    
    private var buttonPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playButtonSound() {
        // Загружаем и воспроизводим звук "button" из основного бандла
        guard let url = Bundle.main.url(forResource: "button", withExtension: "mp3") ??
                        Bundle.main.url(forResource: "button", withExtension: "wav") else {
            return
        }
        
        do {
            buttonPlayer = try AVAudioPlayer(contentsOf: url)
            buttonPlayer?.prepareToPlay()
            buttonPlayer?.play()
        } catch {
            // В проде можно повесить лог, но тут просто молча игнорируем
        }
    }
}

struct SoundButton<Label: View>: View {
    let action: () -> Void
    let label: () -> Label
    
    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(action: {
            SoundManager.shared.playButtonSound()
            action()
        }, label: {
            label()
        })
    }
}


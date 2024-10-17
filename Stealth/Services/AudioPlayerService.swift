//
//  AudioPlayerService.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/11/24.
//

import Foundation
import AVFoundation

class AudioPlayerService: NSObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    weak var delegate: AudioPlayerServiceProtocol?
    
    func playAudio(data: Data) {
        do {
            // Configure audio session
            print("[AudioPlayerService] configuringAudioSession")
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            // Play Audio
            print("[AudioPlayerService] Playing Audio...")
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            delegate?.audioPlayerDidStartplaying()
        } catch {
            print("[AudioPlayerService] playAudio() Failed to configure and activate audio session: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("[AudioPlayerService] audioPlayerDidFinishPlaying")
        delegate?.audioPlayerDidFinishPlaying(player, successfully: flag)
    }
}

protocol AudioPlayerServiceProtocol: AnyObject {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    func audioPlayerDidStartplaying()
}


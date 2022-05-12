//
//  ViewController.swift
//  launchPad
//
//  Created by Maciej Mikołajek on 12/05/2022.
//

import UIKit
import AVFoundation

/// LaunchPad main and only view.
///
/// LaunchPad is a simple application, written just in training purposes. It may be useful potentially for
/// artists and sound designers. It uses EDM soundpack from [freesounds.org](freesounds.org)
class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayers: [AVAudioPlayer] = []
    
    /// The content view in the application. Doesn't really serve any purpose, other than making the app look cool.
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// The header stating "LaunchPad". Nothing fancy here.
    private let header: UILabel = {
            let label = UILabel()
            label.text = "LaunchPad"
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 42)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

    /// Happens right after view had ended loading. It prepares the audio players and all the views.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<16 { audioPlayers.append(AVAudioPlayer()) }

        view.backgroundColor = .systemBackground
        view.addSubview(header)
        view.addSubview(contentView)
        
        setupAutoLayout()
        drawLaunchpadButtons()
    }
    
    /// Makes the `ContentView` look good.
    func setupAutoLayout() {
        header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }

    /// Generates 16 launchpad buttons.
    func drawLaunchpadButtons(){
        let offset         = 10
        let btnsOnX        = 4
        let btnsOnY        = 4
        let btnSizeX       = (Int(view.frame.width-40) - (offset * (btnsOnX + 1))) / btnsOnX
        let btnSizeY       = (Int(view.frame.height-(view.safeAreaInsets.top+120)) - (offset * (btnsOnY + 1))) / btnsOnY
        var xRow           = 0
        var xPosMultiplier = 0
        
        for i in 0..<16 {
            xPosMultiplier += 1
            
            if (i % btnsOnX == 0) {
                xRow += 1
                xPosMultiplier = 0
                print("")
            }
           
            let xPos = offset + (xPosMultiplier * offset) + (xPosMultiplier * btnSizeX)
            let yPos = (offset + (xRow * offset) + (xRow * btnSizeY)) - (btnSizeY + offset)
            
            let btn      = UIButton()
            let btnColor = UIColor(hue: CGFloat(i)/16.0, saturation: 1.0, brightness: 0.8, alpha: 0.8)
            btn.frame    = CGRect(x: CGFloat(xPos), y: CGFloat(yPos), width: CGFloat(btnSizeX), height: CGFloat(btnSizeY))
            btn.tag      = i
            
            btn.backgroundColor    = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.9)
            btn.layer.borderWidth  = 1.0
            btn.layer.cornerRadius = 24
            btn.layer.borderColor  = btnColor.cgColor
            
            let img = UIImage(systemName: "play.circle")?
                .withTintColor(btnColor, renderingMode: .alwaysOriginal)
                .resizeImageTo(size: CGSize(width: 50.0, height: 50.0))
            btn.setImage(img, for: .normal)
            btn.setTitleColor(UIColor.darkGray, for: UIControl.State())
            btn.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
            self.contentView.addSubview(btn)

            if (i % btnsOnX  == 0) {
                xPosMultiplier = 0
            }
        }
    }
    
    /// Happens after clicking the buton on launchpad.
    ///
    /// Plays the music as well as changes the appearance of the pressed button for as long as the sound plays.
    ///
    /// - Parameter sender: the clicked button.
    @objc func buttonSelected(sender: UIButton!){
        let btnColor    = UIColor(hue: CGFloat(sender.tag)/16.0, saturation: 1.0, brightness: 0.8, alpha: 0.8)
        let originalImg = sender.currentImage
        let originalBg  = sender.backgroundColor
        
        let img = UIImage(systemName: "pause.circle")?
            .withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
            .resizeImageTo(size: CGSize(width: 50.0, height: 50.0))
        sender.setImage(img, for: .normal)
        sender.backgroundColor = btnColor
        
        let soundURL = Bundle.main.url(forResource: "\(sender.tag)", withExtension: "wav")
        do {
            audioPlayers[sender.tag] = try AVAudioPlayer(contentsOf: soundURL!)
            audioPlayers[sender.tag].play()
            let audioAsset = AVURLAsset.init(url: soundURL!, options: nil)
            let duration = audioAsset.duration
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration.seconds) {
                sender.setImage(originalImg, for: .normal)
                sender.backgroundColor = originalBg
            }
        } catch {
            print("Cant load file: \(error)")
        }
    }

}


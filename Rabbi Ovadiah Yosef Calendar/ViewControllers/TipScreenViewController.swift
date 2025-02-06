//
//  TipScreenViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 6/12/23.
//

import UIKit
import AVKit

class TipScreenViewController: UIViewController {
    
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!

    @IBOutlet weak var videoPlayer: UIView!
    @IBAction func okay(_ sender: UIButton) {
        dismissAllViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let path = Bundle.main.path(forResource: "explanation", ofType:"mp4") else {
            debugPrint("explanation.mp4 not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPlayer.layer.addSublayer(avPlayerLayer)
        // **Add observer for when the video reaches the end**
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer.frame = videoPlayer.layer.bounds
    }
    
    @objc func videoDidEnd(notification: Notification) {
        player.seek(to: .zero)
        player.play()
    }
    
    func dismissAllViews() {
        let welcome = super.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController
        let inIsraelView = super.presentingViewController?.presentingViewController?.presentingViewController
        let zmanimLanguagesView = super.presentingViewController?.presentingViewController
        let getUserLocationView = super.presentingViewController
        
        super.dismiss(animated: false) {//when this view is dismissed, dismiss the superview as well
            if zmanimLanguagesView != nil {
                zmanimLanguagesView?.dismiss(animated: false)
                if inIsraelView != nil {
                    inIsraelView?.dismiss(animated: false) {
                        if getUserLocationView != nil {
                            getUserLocationView?.dismiss(animated: false) {
                                if welcome != nil {
                                    welcome?.dismiss(animated: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

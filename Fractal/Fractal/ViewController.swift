//
//  ViewController.swift
//  Fractal
//
//  Created by Ildar Usmanov on 02.06.2020.
//  Copyright © 2020 Ildar Usmanov. All rights reserved.
//

import UIKit

@IBDesignable
class ViewController: UIViewController {

    var fractal: Fractal?
    let fractalQueue = OperationQueue()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fractal = Fractal(self.view.frame.size)
        fractal?.delegate = self
        
        fractal?.resetFractal()

        setGestures()
    }
    func setGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(zoom))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
    }
    
    @objc func zoom(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: self.view)
            fractal?.zoom(Int(point.x), Int(point.y))
        }
    }

}

extension ViewController: FractalDelegate {
    func updateUIImage(uiimage: UIImage?) {
        if uiimage != nil {
            DispatchQueue.main.async {
                self.imageView.image = uiimage
            }
        }
    }
}

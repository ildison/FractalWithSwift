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

    @IBOutlet var movingButtons: [UIButton]!
    @IBOutlet weak var iterationSlider: UISlider!
    @IBOutlet weak var right: UIButton!
    var fractal: Fractal?
    let fractalQueue = OperationQueue()
    var pinchScale: CGFloat = 1
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fractal = Fractal(self.view.frame.size)
        fractal?.delegate = self
        fractal?.resetFractal()
        
        iterationSlider.maximumValue = 5
        iterationSlider.minimumValue = 1
        iterationSlider.value = iterationSlider.minimumValue
        iterationSlider.addTarget(self, action: #selector(changingMaxIteration), for: .valueChanged)
        iterationSlider.addTarget(self, action: #selector(endedChangeMaxIterstion), for: .touchCancel)
        
        setGestures()
//        right.point(inside: <#T##CGPoint#>, with: <#T##UIEvent?#>)
    }
    func setGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(scale))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        self.view.addGestureRecognizer(doubleTap)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scale))
        self.view.addGestureRecognizer(pinch)
    }
    @objc func ft_pinch(pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
            case .began:
                print("began")
            case .changed:
                print(pinch.scale)
            default: return
        }
    }
    
    @objc func scale(gesture: UIGestureRecognizer) {
        let point = gesture.location(in: self.view)
        switch gesture {

            case let pinch as UIPinchGestureRecognizer:
                switch pinch.state {

                    case .began:
                        self.fractal?.maxIteration = 19
                    print(pinch.scale)

                    case .changed:
                        if pinch.scale - self.pinchScale > 0.1 {
                            fractal?.scale(Int(point.x), Int(point.y), 0.91)
                        } else if self.pinchScale - pinch.scale > 0.1 {
                            fractal?.scale(Int(point.x), Int(point.y), 1.09)
                        } else { return }
                        self.pinchScale = pinch.scale

                    case .ended:
                        print(pinch.scale)
                        self.fractal?.maxIteration = 25
                        self.fractal?.redrawFractal() //перерисовать
                        self.pinchScale = 1
                    default: return
                }

            case let tap as UITapGestureRecognizer:
                if tap.state == .ended {
                    fractal?.scale(Int(point.x), Int(point.y), 0.8)
            }
            default: return
            

        }
    }
    @IBAction func move(sender: UIButton) {
        guard let orientation = sender.accessibilityIdentifier else {
            return
        }
        fractal?.move(orientation)
    }
    @IBAction func reset() {
        fractal?.resetFractal()
    }
    @objc func changingMaxIteration(slider: UISlider) {
        let currentValue = Int(slider.value) * 25
        if fractal?.maxIteration != currentValue {
            print(currentValue)
            fractal?.maxIteration = currentValue
            fractal?.redrawFractal()
        }
    }
    @objc func endedChangeMaxIterstion(slider: UISlider) {
        print("end")
        fractal?.maxIteration = 25
        fractal?.redrawFractal()
        slider.value = slider.minimumValue
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

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view is UIButton? ? false : true
    }
}

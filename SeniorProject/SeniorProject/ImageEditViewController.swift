//
//  ImageEditViewController.swift
//  SeniorProject
//
//  Created by Sigh on 3/17/18.
//  Copyright © 2018 Sigh. All rights reserved.
//

import UIKit
import ZoomImageView.Swift

class ImageEditViewController: UIViewController {
    var passingImage: UIImage?
    var sliderImage: UIImage?
    var type: String? = nil
    var isSliderChanged:Bool = false
    var isSliderChanged2:Bool = false
    var isSliderChanged3:Bool = false
    var holdingValue:Int = 25
    var holdingValue2:Int = 0
    var holdingValue3:Int = 13
    @IBOutlet weak var num: UITextField!
    @IBOutlet weak var sliderTitle: UILabel!
    @IBOutlet weak var sliderTitle2: UILabel!
    @IBOutlet weak var sliderTitle3: UILabel!
    @IBOutlet weak var imageView: ZoomImageView!
    @IBOutlet weak var slideBar: UISlider!
    @IBOutlet weak var slideBar2: UISlider!
    @IBOutlet weak var slideBar3: UISlider!

    @IBAction func clickToSharpen(_ sender: Any) {
        passingImage = toSharpenImage(image: passingImage!)
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }
    
    @IBAction func clickToDenoise(_ sender: Any) {
        passingImage = toDenoisedImage(image: passingImage!)
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        if type == "lr"{
            if isSliderChanged{
                let number = Int(num.text!)
                slideBar.setValue(Float(number!), animated: true)
                passingImage = deconvolutionLucyRichardson(image: sliderImage!, iteration: holdingValue2, sigmaG: Double(number!))
            }else if isSliderChanged2{
                let number = Int(num.text!)
                slideBar2.setValue(Float(number!), animated: true)
                passingImage = deconvolutionLucyRichardson(image: sliderImage!, iteration: number!, sigmaG: Double(holdingValue))
            }
        }else if type == "wiener"{
            if isSliderChanged{
                let number = Int(num.text!)
                slideBar.setValue(Float(number!), animated: true)
                passingImage = Wiener(image: sliderImage!, diameter: number!, k: 0.01, angle: holdingValue2)
            }else if isSliderChanged2{
                let number = Int(num.text!)
                slideBar2.setValue(Float(number!), animated: true)
                passingImage = Wiener(image: sliderImage!, diameter: holdingValue, k: 0.01, angle: number!)
            }
            
        }else if type == "c"{
            if isSliderChanged{
                let number = Int(num.text!)
                slideBar.setValue(Float(number!), animated: true)
                passingImage = convolution(image: sliderImage!, len: number!, angle: holdingValue2, iteration: holdingValue3)

            }else if isSliderChanged2{
                let number = Int(num.text!)
                slideBar2.setValue(Float(number!), animated: true)
                passingImage = convolution(image: sliderImage!, len: holdingValue, angle: number!, iteration: holdingValue3)
                
            }else if isSliderChanged3{
                let number = Int(num.text!)
                slideBar3.setValue(Float(number!), animated: true)
                passingImage = convolution(image: sliderImage!, len: holdingValue, angle: holdingValue2, iteration: number!)

            }
        }
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }
    
    @IBAction func slider3(_ sender: UISlider) {
        isSliderChanged = false
        isSliderChanged2 = false
        isSliderChanged3 = true
        if type == "c"{
            num.text = String(Int(sender.value))
            holdingValue3 = Int(sender.value)
            passingImage = convolution(image: sliderImage!, len: holdingValue, angle: holdingValue2, iteration: holdingValue3)
        }
        
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }
    @IBAction func slider2(_ sender: UISlider) {
        isSliderChanged = false
        isSliderChanged2 = true
        isSliderChanged3 = false
        if type == "c"{
            num.text = String(Int(sender.value))
            holdingValue2 = Int(sender.value)
            passingImage = convolution(image: sliderImage!, len: holdingValue, angle: holdingValue2, iteration: holdingValue3)
        }else if type == "lr"{
            num.text = String(Int(sender.value))
            holdingValue2 = Int(sender.value)
            passingImage = deconvolutionLucyRichardson(image: sliderImage!, iteration: holdingValue2, sigmaG: Double(holdingValue))
        }else if type == "wiener"{
            num.text = String(Int(sender.value))
            holdingValue2 = Int(sender.value)
            passingImage = Wiener(image: sliderImage!, diameter: holdingValue, k: 0.01, angle: holdingValue2)
        }
        
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }
    @IBAction func slider(_ sender: UISlider) {
        isSliderChanged = true
        isSliderChanged2 = false
        isSliderChanged3 = false
        if type == "lr"{
            num.text = String(Int(sender.value))
            holdingValue = Int(sender.value)
            passingImage = deconvolutionLucyRichardson(image: sliderImage!, iteration: holdingValue2, sigmaG: Double(holdingValue))
        }else if type == "wiener"{
            num.text = String(Int(sender.value))
            holdingValue = Int(sender.value)
            passingImage = Wiener(image: sliderImage!, diameter: holdingValue, k: 0.01, angle: holdingValue2)
        }else if type == "c"{
            num.text = String(Int(sender.value))
            holdingValue = Int(sender.value)
            passingImage = convolution(image: sliderImage!, len: holdingValue, angle: holdingValue2, iteration: holdingValue3)
        }
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }

    @IBAction func rotateLeft(_ sender: Any) {
        passingImage = passingImage?.rotate(radians: .pi/2)
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }
    
    func deconvolutionLucyRichardson(image: UIImage, iteration: Int, sigmaG: Double) -> UIImage{
        return OpenCVWrapper.deconvolutionLucyRichardson(from: image, iteration: Int32(iteration), sigmaG: sigmaG)
    }
    
    func Wiener(image: UIImage, diameter: Int, k:Double, angle:Int) -> UIImage{
        return OpenCVWrapper.wiener(from: image, diameter: Int32(diameter), k: k, angle: Double(angle))
    }

    
    func convolution(image:UIImage, len: Int, angle:Int, iteration:Int) -> UIImage{
        return OpenCVWrapper.convolution(from: image, len: Double(len), angle: Double(angle), iteration: Int32(iteration))
    }
    
    func toSharpenImage(image: UIImage) -> UIImage{
        return OpenCVWrapper.sharpen(from: image)
    }
    
    func toDenoisedImage(image: UIImage) -> UIImage{
        return OpenCVWrapper.denoising(from: image)
    }
    
    func toGrayscale(image: UIImage) -> UIImage{
        return OpenCVWrapper.makeGray(from: image)
    }
    
    /*func WienerImpl(grayImage: UIImage, size: Int) -> UIImage{
        return OpenCVWrapper.wiener(from: grayImage, size: Int32(size))
    }
    
    func Wiener(grayImage: UIImage, size: Int, iteration: Int) -> UIImage{
        let result = WienerImpl(grayImage: grayImage, size: size)
        if iteration > 1 {
            return Wiener(grayImage: result, size: size, iteration: iteration-1)
        }else{
            return result
        }
        
    }
    
    func WienerImpl(grayImage: UIImage, noiseVariance: Double, size: Int) -> UIImage{
        return OpenCVWrapper.wiener(from: grayImage, noiseVariance: noiseVariance, size: Int32(size))
    }
    
    func Wiener(grayImage: UIImage, noiseVariance: Double, size: Int, iteration: Int) -> UIImage{
        let result = WienerImpl(grayImage: grayImage, noiseVariance: noiseVariance, size: size)
        if iteration > 1 {
            return Wiener(grayImage: result, size: size, iteration: iteration-1)
        }else{
            return result
        }
    }*/
    
    @IBAction func rotateRight(_ sender: Any) {
        passingImage = passingImage?.rotate(radians: .pi/1)
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }
    
    @IBAction func filpping(_ sender: Any) {
        passingImage = passingImage?.withHorizontallyFlippedOrientation()
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sliderImage = passingImage
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
        if type == "lr"{
            slideBar3.isHidden = true
            sliderTitle3.isHidden = true
            sliderTitle2.text = "Iteration"
            slideBar.maximumValue = 10.0
            slideBar.minimumValue = 0.0
            slideBar.value = 5.0
            slideBar2.maximumValue = 26
            slideBar2.minimumValue = 1.0
            slideBar2.value = 13.0
        }else if type == "wiener"{
            sliderTitle.text = "Length"
            sliderTitle2.text = "Angle"
            slideBar3.isHidden = true
            sliderTitle3.isHidden = true
            slideBar.maximumValue = 51.0
            slideBar.minimumValue = 5
            slideBar.value = 28.0
            slideBar2.maximumValue = 360
            slideBar2.minimumValue = 0
            slideBar2.value = 0
        }else if type == "c"{
            slideBar3.isHidden = true
            sliderTitle3.isHidden = true
            sliderTitle.text = "Length"
            sliderTitle2.text = "Angle"
            sliderTitle3.text = "Iteration"
            slideBar.maximumValue = 51.0
            slideBar.minimumValue = 5
            slideBar.value = 28.0
            slideBar2.maximumValue = 360
            slideBar2.minimumValue = 0
            slideBar2.value = 0
            slideBar3.maximumValue = 26
            slideBar3.minimumValue = 1.0
            slideBar3.value = 13.0
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showImageViewWithPassingImage(_ sender: Any) {
        let nextScreen = storyboard?.instantiateViewController(withIdentifier: "image_detail") as! ImageViewController
        nextScreen.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if let i = imageView.image {
            nextScreen.passingImage = i
        }
        present(nextScreen, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContext(newSize);
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

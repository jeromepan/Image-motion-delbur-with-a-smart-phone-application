//
//  ImageScreenController.swift
//  SeniorProject
//
//  Created by Sigh on 1/31/18.
//  Copyright © 2018 Sigh. All rights reserved.
//

import UIKit

class ImageScreenController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet var imageView: UIImageView!
    var imageList = [UIImage]()
    @IBOutlet weak var acticityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var button: UIButton!
    var timer = Timer()
    var passingImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
        progressBar.setProgress(0, animated: true)
        timer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(ImageScreenController.go), userInfo: nil, repeats: true)
    }
    
    
    func loadImage() -> Void{
        var startingTime: Double
        var endingTime: Double
        var grayImage: UIImage!
        
        startingTime = Date.timeIntervalSinceReferenceDate
        let i = UIImage(data:(UIImage(data:(passingImage?.jpeg(.lowest))!)?.jpeg(.lowest))!)
        //let i = passingImage
        endingTime = Date.timeIntervalSinceReferenceDate
        print("resize (run time): " + String(endingTime - startingTime) + " s")
        
        startingTime = Date.timeIntervalSinceReferenceDate
        grayImage = toGrayscale(image: i!)
        endingTime = Date.timeIntervalSinceReferenceDate
        print("grayscale (run time): " + String(endingTime - startingTime) + " s")
        imageList.append(grayImage)
        
        /*imageList.append(toAntiColorImage(image: grayImage))
        imageList.append(toSharpenImage(image: i!))
        imageList.append(toInvertImage(image: i!))
        imageList.append(toSculptureImage(image: grayImage))
        imageList.append(toWaveImage(image: i!))*/
        imageList.append(toDenoisedImage(image: toSharpenImage(image:convolution(image: i!, len: 22, angle: -2, iteration: 25))))

        //var denoisedImage: UIImage
        startingTime = Date.timeIntervalSinceReferenceDate
        //denoisedImage = toDenoisedImage(image: convolution(image: toGrayscale(image:i!)))
        //imageList.append(denoisedImage)
        endingTime = Date.timeIntervalSinceReferenceDate
        print("denoise (run time): " + String(endingTime - startingTime) + " s")
        
        imageList.append(toSharpenImage(image: i!))

        startingTime = Date.timeIntervalSinceReferenceDate
        imageList.append(toEdge(image: grayImage!))
        endingTime = Date.timeIntervalSinceReferenceDate
        print("edge detecting (run time): " + String(endingTime - startingTime) + " s")
        
        let afterGaussianBlur:UIImage
        let sigma = 6.0
        let size = 8*sigma+1
        startingTime = Date.timeIntervalSinceReferenceDate
        afterGaussianBlur = toGaussianBlur(image: grayImage, size: Int(size), sigma: sigma)
        imageList.append(afterGaussianBlur)
        endingTime = Date.timeIntervalSinceReferenceDate
        print("gaussian blur (run time): " + String(endingTime - startingTime) + " s")
        
        imageList.append(test(image: i!));
        
        
    }
    
    func convolution(image:UIImage, len:Double, angle: Double, iteration:Int) -> UIImage{
        return OpenCVWrapper.convolution(from: image, len: len, angle: angle, iteration: Int32(iteration))
    }
    
    func test(image:UIImage) -> UIImage{
        return OpenCVWrapper.test(image)
    }
    
    func toGrayscale(image: UIImage) -> UIImage{
        return OpenCVWrapper.makeGray(from: image)
    }
    
    func toInvertImage(image: UIImage) -> UIImage{
        return OpenCVWrapper.invert(from: image)
    }
    
    func toSharpenImage(image: UIImage) -> UIImage{
        return OpenCVWrapper.sharpen(from: image)
    }
    
    func toAntiColorImage(image: UIImage) -> UIImage{
        return OpenCVWrapper.antiColor(from: image)
    }
    
    func toSculptureImage(image: UIImage) -> UIImage{
        return OpenCVWrapper.sculpting(from: image)
    }
    
    func toWaveImage(image: UIImage) -> UIImage{
        return OpenCVWrapper.waving(from: image)
    }
    
    func toDenoisedImage(image: UIImage) -> UIImage{
        return OpenCVWrapper.denoising(from: image)
    }
    
    func toEdge(image: UIImage) -> UIImage{
        return OpenCVWrapper.edgeDetecting(from: image)
    }
    
    func toGaussianBlur(image: UIImage, size: Int, sigma: Double) -> UIImage{
        return OpenCVWrapper.gaussianBlur(from: image, size: Int32(size), sigma: sigma)
    }
    
    @IBAction func animating(_ sender: Any) {
        button.isHidden = true
        progressBar.isHidden = false
        acticityIndicator.startAnimating()

    }
    
    @objc func go(){
        if !progressBar.isHidden{
            progressBar.progress += 0.05
        }
    }
    
    @IBAction func deblurShowNextScreen(_ sender: Any) {
        let nextScreen = storyboard?.instantiateViewController(withIdentifier: "image_detail") as! ImageViewController
        nextScreen.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        //loadImage()
        nextScreen.passingImage = passingImage
        present(nextScreen, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}

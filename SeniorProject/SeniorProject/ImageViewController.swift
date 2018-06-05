//
//  ImageViewController.swift
//  SeniorProject
//
//  Created by Sigh on 1/31/18.
//  Copyright © 2018 Sigh. All rights reserved.
//

import UIKit
import ZoomImageView.Swift

class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: ZoomImageView!

    var passingImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*if let p = passingImage {
            imageView.image = p
            saveImage(image: p, name: "tmp")
        }else{
            imageView.image = getSavedImage(named: "tmp")
        }*/
        imageView.image = passingImage
        imageView.contentMode = .scaleAspectFit
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lrShowNextScreen(_ sender: Any) {
        let nextScreen = storyboard?.instantiateViewController(withIdentifier: "image_edit") as! ImageEditViewController
        nextScreen.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        nextScreen.passingImage = passingImage!
        //nextScreen.passingImage = toGrayscale(image: passingImage!)

        nextScreen.type = "lr"

        present(nextScreen, animated: true, completion: nil)
    }
    
    @IBAction func convolutionShowNextScreen(_ sender: Any) {
        let nextScreen = storyboard?.instantiateViewController(withIdentifier: "image_edit") as! ImageEditViewController
        nextScreen.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        nextScreen.passingImage = passingImage!
        //nextScreen.passingImage = toGrayscale(image: passingImage!)
        
        nextScreen.type = "c"
        
        present(nextScreen, animated: true, completion: nil)
    }
    @IBAction func wienerShowNextScreen(_ sender: Any) {
        let nextScreen = storyboard?.instantiateViewController(withIdentifier: "image_edit") as! ImageEditViewController
        nextScreen.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        nextScreen.passingImage = passingImage!
        //nextScreen.passingImage = toGrayscale(image: passingImage!)

        nextScreen.type = "wiener"
        
        present(nextScreen, animated: true, completion: nil)
    }
    
    func toGrayscale(image: UIImage) -> UIImage{
        return OpenCVWrapper.makeGray(from: image)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac1 = UIAlertController(title: "Saved!", message: "Your image has been saved to your Photos.", preferredStyle: .alert)
            ac1.addAction(UIAlertAction(title: "OK", style: .default){ (action) in
                let ac2 = UIAlertController(title: "Go to Photos?", message: "Open your Photo albums?", preferredStyle: .alert)
                let positive = UIAlertAction(title: "Yes", style: .default) { (action) in
                    UIApplication.shared.open(URL(string:"photos-redirect://")!)
                }
                let negative = UIAlertAction(title: "No", style: .default)
                ac2.addAction(negative)
                ac2.addAction(positive)
                self.present(ac2, animated: true)
            })
            present(ac1, animated: true)
            
        }
    }
    
    @IBAction func saveImage(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(passingImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    /*func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func saveImage(image: UIImage, name: String) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(name + ".png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

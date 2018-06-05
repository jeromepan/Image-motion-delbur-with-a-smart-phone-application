//
//  DeblurScreenController.swift
//  SeniorProject
//
//  Created by Sigh on 1/31/18.
//  Copyright © 2018 Sigh. All rights reserved.
//

import UIKit

class DeblurScreenController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var passingImages = [UIImage?]()
    
    @IBOutlet weak var tableView: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passingImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let picture = passingImages[indexPath.row]
        cell.picture.image = picture
        /*switch indexPath.row {
        case 0:
            cell.filter = "Grayscale"
            break
        case 1:
            cell.filter = "Denoise"
            break
        case 2:
            cell.filter = "Edge"
            break
        case 3:
            cell.filter = "Gaussian Blur"
            break
        default:
            cell.filter = "Undefined"
        }*/
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "image_detail") as! ImageViewController
        vc.modalTransitionStyle = .coverVertical
        vc.passingImage = passingImages[indexPath.row]
        present(vc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if passingImages.count != 0 {
            var counter = 1
            for i in passingImages{
                saveImage(image: i!, name: "tmp"+String(counter))
                
                counter = counter + 1
            }
        }else{
            var counter = 1
            while let i = getSavedImage(named: "tmp"+String(counter)){
                passingImages.append(i)
                counter = counter + 1
            }
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
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

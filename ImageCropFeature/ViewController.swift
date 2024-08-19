//
//  ViewController.swift
//  ImageCropFeature
//  Created by sohamp on 22/07/24.
//

import UIKit
import Photos

class ViewController: UIViewController {

    private var croppingStyle = CropViewCroppingStyle.default
    private var croppedRect = CGRect.zero
    var customCameraVC = CustomCameraController()
    var customPhotoPickerVC = CustomPhotoPickerViewController()

    @IBOutlet weak var croppedImageView: UIImageView!

    func getTopMostViewController() -> UIViewController? {
         var topController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
         while let presentedViewController = topController?.presentedViewController {
             topController = presentedViewController
         }
         return topController
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
    }

 
    
    @IBAction func selectImage(_ sender: UIButton) {
        self.croppedImageView.image = nil
        presentSourceOption()

    }
    
    
    public func presentSourceOption() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            if (type.rawValue == 1) {
                self.actionForCamera()
            } else if (type.rawValue == 0){
                self.actionForLibrary()
                }   else{
                //None
            }
        }
    }
    private func actionForCamera(){
        self.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            if let topController = getTopMostViewController() {
                self.customCameraVC.delegate = self
                self.customCameraVC.modalPresentationStyle = .fullScreen
                topController.present(self.customCameraVC, animated: true, completion: nil)
            }
        })
    }
    
    // Using PHImageManager //
    private func actionForLibrary(){
        customPhotoPickerVC.delegate = self
        present(customPhotoPickerVC, animated: true, completion: nil)
    }
    
}

   
// MARK: - CustomPhotoPickerDelegate - (PHImageManager) -
extension ViewController: CustomPhotoPickerDelegate {
    func photoPicker(_ picker: CustomPhotoPickerViewController, didPickImage image: UIImage) {
        self.customPhotoPickerVC.dismiss(animated: true, completion: { [weak self] in
               guard let self = self else { return }
               self.launchCropViewController(image: image)
           })
    }
    
    func photoPickerDidCancel(_ picker: CustomPhotoPickerViewController) {
        self.customPhotoPickerVC.dismiss(animated: true)

    }
   
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
    
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}


extension ViewController: CustomCameraControllerDelegate {
    
    // MARK: - CustomCameraControllerDelegate
    func didSelect(image: UIImage?) {
        if (image != nil){
            let rotatedImage = image!.rotate(radians: getAngleForOrientation())
            self.customCameraVC.dismiss(animated: true) {
                self.launchCropViewController(image: rotatedImage!)
            }
        }
    }
    
    func getAngleForOrientation () -> Float {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        print(orientation)
        switch (orientation) {
        case .portrait:
            print("portrait")
            return  0
        case .landscapeRight:
            print("landscapeRight")
            return .pi / 2
        case .landscapeLeft:
            print("landscapeLeft")
            return .pi * 1.5
        case .portraitUpsideDown:
            print("portraitUpsideDown")
            return .pi
        default:
            print("default")
            return 0
        }
    }
}


extension ViewController: CropViewControllerDelegate {
    
    public func launchCropViewController (image: UIImage){
        let cropController = ImageCropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        cropController.rotateButtonsHidden = false
        cropController.rotateClockwiseButtonHidden = false
        cropController.toolbar.clampButtonHidden = false
        self.present(cropController, animated: true, completion: nil)
    }
    
// MARK: - CropViewControllerDelegate
    func cropViewController(_ cropViewController: ImageCropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: ImageCropViewController) {
        layoutImageView()
        self.croppedImageView.image = image

        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.croppedImageView.isHidden = true
        cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                               toView: croppedImageView,
                                               toFrame: CGRect.zero,
                                               setup: { self.layoutImageView() },
                                               completion: {
                                                    self.croppedImageView.isHidden = false
                                                })
    }
    
    public func layoutImageView() {
        guard croppedImageView.image != nil else { return }
        
        let padding: CGFloat = 20.0
        
        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))
        
        var imageFrame = CGRect.zero
        imageFrame.size = croppedImageView.image!.size;
        
        if croppedImageView.image!.size.width > viewFrame.size.width || croppedImageView.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            croppedImageView.frame = imageFrame
        }
        else {
            self.croppedImageView.frame = imageFrame;
            self.croppedImageView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
    }
    

}

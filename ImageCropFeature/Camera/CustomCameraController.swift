//
//  CustomCameraController.swift
//  ImageCropFeature
//  Created by sohamp on 22/07/24.
//


import UIKit
import AVFoundation

public protocol CustomCameraControllerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

class CustomCameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    weak var delegate: CustomCameraControllerDelegate?
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!

    lazy private var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy private var takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo.circle"), for: .normal)
        button.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCameraAuthorization()
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           previewLayer?.frame = view.layer.bounds
    }
    
    func checkCameraAuthorization() {
         let status = AVCaptureDevice.authorizationStatus(for: .video)
         
         switch status {
         case .authorized:
             setupCaptureSession()
             setupPreviewLayer()
             startCaptureSession()
         case .notDetermined:
             AVCaptureDevice.requestAccess(for: .video) { granted in
                 DispatchQueue.main.async {
                     if granted {
                         self.setupCaptureSession()
                         self.setupPreviewLayer()
                         self.startCaptureSession()
                     } else {
                         self.showAuthorizationAlert()
                     }
                 }
             }
         case .denied, .restricted:
             showAuthorizationAlert()
         @unknown default:
             fatalError("Unknown authorization status")
         }
     }
    
    func showAuthorizationAlert() {
           let alert = UIAlertController(
               title: "Camera Access Required",
               message: "Please allow camera access in Settings to take photos.",
               preferredStyle: .alert
           )
        
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                   self.handleAuthorizationCancel()
               })
        
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
               guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
               if UIApplication.shared.canOpenURL(settingsUrl) {
                   UIApplication.shared.open(settingsUrl, completionHandler: nil)
               }
           })
           present(alert, animated: true, completion: nil)
       }
    
    func handleAuthorizationCancel() {
        self.handleDismiss()
      }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
       captureSession?.sessionPreset = .photo

       guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
       let videoInput: AVCaptureDeviceInput

       do {
           videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
       } catch {
           return
       }

       if let captureSession = captureSession, captureSession.canAddInput(videoInput) {
           captureSession.addInput(videoInput)
       }

       photoOutput = AVCapturePhotoOutput()
       if let captureSession = captureSession, captureSession.canAddOutput(photoOutput!) {
           captureSession.addOutput(photoOutput!)
       }
        
   }
        
    func setupPreviewLayer() {
        if let captureSession = captureSession {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.frame = view.layer.bounds
                previewLayer?.videoGravity = .resizeAspectFill
                if let previewLayer = previewLayer {
                    view.layer.addSublayer(previewLayer)
                }
        }
    }

    func startCaptureSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
           guard let self = self else { return }
                captureSession.startRunning()
        }
        self.setupUI()
    }
    
    func takePhoto() {
        guard let photoOutput = photoOutput else {
           print("Photo output is not initialized")
           return
       }
       let settings = AVCapturePhotoSettings()
       photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        self.delegate?.didSelect(image: image)
    }
    
    @objc private func handleTakePhoto() {
        takePhoto()
    }


    private func setupUI() {
        view.addSubviews(backButton, takePhotoButton)
        takePhotoButton.makeConstraints(top: nil, left: nil, right: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 15, width: 80, height: 80)
        takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backButton.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, left: nil, right: view.rightAnchor, bottom: nil, topMargin: 15, leftMargin: 0, rightMargin: 10, bottomMargin: 0, width: 50, height: 50)
    }
        
    @objc private func handleDismiss() {
          self.dismiss(animated: true, completion: nil)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
    }
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
            return .portrait
    }

    override var shouldAutorotate: Bool {
             return false
    }
    
}


//
//  CustomPhotoPickerViewController.swift
//  BravaView
//
//  Created by sohamp on 23/07/24.
//

import UIKit
import Photos


protocol CustomPhotoPickerDelegate: AnyObject {
    func photoPicker(_ picker: CustomPhotoPickerViewController, didPickImage image: UIImage)
    func photoPickerDidCancel(_ picker: CustomPhotoPickerViewController)
}


class CustomPhotoPickerViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var assets: [PHAsset] = []
    weak var delegate: CustomPhotoPickerDelegate?
    private let imageManager = PHCachingImageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        requestPhotoLibraryAuthorization()
        setupCancelButton()
    }
    
    private func setupCollectionView() {
           let layout = CustomFlowLayout()
           collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
           collectionView.delegate = self
           collectionView.dataSource = self
           collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
           collectionView.backgroundColor = .white // Default background color
           view.addSubview(collectionView)
           collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       }
       
   override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()
       collectionView.frame = view.bounds
       collectionView.collectionViewLayout.invalidateLayout()
   }
    
    private func requestPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .authorized:
                    self.fetchPhotos()
                case .denied, .restricted:
                    self.showAuthorizationAlert()
                case .notDetermined:
                    break // Handle as needed
                case .limited:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        fetchResult.enumerateObjects { [weak self] asset, _, _ in
            self?.assets.append(asset)
        }
        collectionView.reloadData()
    }
    
    private func fetchImage(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
       // let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        // Adjust target size based on screen scale
        let scale = UIScreen.main.scale
        let scaledTargetSize = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
        
        imageManager.requestImage(for: asset, targetSize: scaledTargetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
            completion(image)
        }
    }

  
    private func handleSelectedAsset(_ asset: PHAsset) {
        // Ensure that the image is fetched at the correct size
        let targetSize = CGSize(width: 500, height: 500) // Adjust size as needed
        
        fetchImage(for: asset, targetSize: targetSize) { [weak self] image in
            guard let self = self else { return }
            
            // Ensure the image is not nil before calling the delegate
            if let image = image {
                // Pass the image to the delegate
                self.delegate?.photoPicker(self, didPickImage: image)
            }
        }
    }

    
    private func showAuthorizationAlert() {
        let alert = UIAlertController(
            title: "Permission Required",
            message: "Please allow access to your photo library in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }))
        present(alert, animated: true)
    }
    private func setupCancelButton() {
          let cancelButton = UIButton(type: .system)
          cancelButton.setTitle("Cancel", for: .normal)
          cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
          cancelButton.setTitleColor(.systemBlue, for: .normal)
          cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
          
          // Add constraints or set frame for the button
          cancelButton.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(cancelButton)
          
          NSLayoutConstraint.activate([
              cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
              cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
          ])
      }
   
    @objc private func cancelButtonTapped() {
       delegate?.photoPickerDidCancel(self)
    }
}

extension CustomPhotoPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let asset = assets[indexPath.item]
        
        // Calculate the cell size and scale it
        let cellSize = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? CGSize(width: 100, height: 100)
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        cell.configure(with: asset, targetSize: targetSize)
        
        return cell
    }


    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        handleSelectedAsset(asset)
    }
}


class PhotoCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with asset: PHAsset, targetSize: CGSize) {
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { [weak self] image, _ in
            self?.imageView.image = image
        }
    }
}



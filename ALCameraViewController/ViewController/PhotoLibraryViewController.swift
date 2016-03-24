//
//  ALImagePickerViewController.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

internal let ImageCellIdentifier = "ImageCell"

internal let defaultItemSpacing: CGFloat = 1

typealias PhotoLibraryViewSelectionComplete = (asset: PHAsset?) -> Void

public class PhotoLibraryViewController: UIViewController {
    
    internal var onSelectionComplete: PhotoLibraryViewSelectionComplete?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CameraGlobals.shared.photoLibraryThumbnailSize
        layout.minimumInteritemSpacing = defaultItemSpacing
        layout.minimumLineSpacing = defaultItemSpacing
        layout.sectionInset = UIEdgeInsetsZero
        
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    }()
    
    private var assets: PHFetchResult!
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        view.backgroundColor = UIColor(white: 0.2, alpha: 1)
        view.addSubview(collectionView)

        collectionView.backgroundColor = UIColor.clearColor()
        
        ImageFetcher()
            .onFailure(onFailure)
            .onSuccess(onSuccess)
            .fetch()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.userInteractionEnabled = true
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.frame
    }
    
    public func dismiss() {
        onSelectionComplete?(asset: nil)
    }
    
    private func onSuccess(photos: PHFetchResult) {
        assets = photos
        configureCollectionView()
    }
    
    private func onFailure(error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        permissionsView.titleLabel.text = localizedString("permissions.library.title")
        permissionsView.descriptionLabel.text = localizedString("permissions.library.description")
        
        view.addSubview(permissionsView)
    }
    
    private func configureCollectionView() {
        collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> PHAsset {
        return assets[indexPath.row] as! PHAsset
    }
}

// MARK: - UICollectionViewDataSource -
extension PhotoLibraryViewController : UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let model = itemAtIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath) as! ImageCell
        
        cell.configureWithModel(model)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate -
extension PhotoLibraryViewController : UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let asset = itemAtIndexPath(indexPath)
        onSelectionComplete?(asset: asset)
    }
}

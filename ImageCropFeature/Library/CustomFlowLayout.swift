//
//  CustomFlowLayout.swift
//  BravaView
//
//  Created by sohamp on 23/07/24.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        configureLayout()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    private func configureLayout() {
        guard let collectionView = collectionView else { return }
        
        let orientation = UIDevice.current.orientation
        var numberOfColumns: CGFloat = orientation.isLandscape ? 5 : 3
        if(UIDevice.current.userInterfaceIdiom == .phone){
             numberOfColumns = orientation.isLandscape ? 5 : 3
        } else {
             numberOfColumns = orientation.isLandscape ? 5 : 5
        }
        let padding: CGFloat = 2
        let totalPadding = padding * (numberOfColumns - 1)
        let availableWidth = collectionView.bounds.width - totalPadding
        let itemWidth = availableWidth / numberOfColumns
        
        itemSize = CGSize(width: itemWidth, height: itemWidth)
        minimumInteritemSpacing = padding
        minimumLineSpacing = padding
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        return attributes
    }
}

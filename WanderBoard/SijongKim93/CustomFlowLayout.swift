//
//  CustomFlowLayout.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 5/31/24.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if let newFrame = layoutAttributesForItem(at: layoutAttribute.indexPath)?.frame {
                    layoutAttribute.frame = newFrame
                }
            }
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as! UICollectionViewLayoutAttributes
        let spacing: CGFloat = 16
        let additionalOffset: CGFloat = 50

        switch indexPath.item {
        case 0:
            attributes.frame.origin.y = 0
            attributes.frame.origin.x = 0
        case 1:
            attributes.frame.origin.y = additionalOffset
            attributes.frame.origin.x = attributes.frame.width + spacing
        case 2:
            if let firstItemAttributes = layoutAttributesForItem(at: IndexPath(item: 0, section: indexPath.section)) {
                attributes.frame.origin.y = firstItemAttributes.frame.maxY + spacing
                attributes.frame.origin.x = 0
            }
        case 3:
            if let secondItemAttributes = layoutAttributesForItem(at: IndexPath(item: 1, section: indexPath.section)) {
                attributes.frame.origin.y = secondItemAttributes.frame.maxY + spacing
                attributes.frame.origin.x = secondItemAttributes.frame.minX
            }
        default:
            break
        }
        return attributes
    }
}

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
        let spacing: CGFloat = 10

        switch indexPath.item {
        case 0:
            attributes.frame.origin.y = 0
            attributes.frame.origin.x = 0
        case 1:
            attributes.frame.origin.y = 0
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
            let row = (indexPath.item - 4) / 2 + 2
            let column = indexPath.item % 2
            
            if column == 0 {
                if let aboveItemAttributes = layoutAttributesForItem(at: IndexPath(item: indexPath.item - 2, section: indexPath.section)) {
                    attributes.frame.origin.y = aboveItemAttributes.frame.maxY + spacing
                    attributes.frame.origin.x = 0
                }
            } else {
                if let aboveItemAttributes = layoutAttributesForItem(at: IndexPath(item: indexPath.item - 2, section: indexPath.section)) {
                    attributes.frame.origin.y = aboveItemAttributes.frame.maxY + spacing
                    attributes.frame.origin.x = aboveItemAttributes.frame.width + spacing
                }
            }
        }
        return attributes
    }
}

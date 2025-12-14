import Foundation

public struct PaperFormat
{
    public enum Orientation {
        case portrait
        case landscape
    }
    
    public enum Size {
        case a0
        case a1
        case a2
        case a3
        case a4
        case a5
        case a6
        case letter
    }
    
    public static let `default` = PaperFormat()

    public let size:Size
    public let orientation:Orientation
    public let margin:CGFloat
    
    public init(size: Size = .a4, orientation:Orientation = .portrait, margin: CGFloat = .mm(10))
    {
        self.size = size
        self.orientation = orientation
        self.margin = margin
    }
        
    public var artSize:CGSize {
        let paperSize = self.mediaSize
        if orientation == .portrait {
            return CGSize(width: paperSize.width - 2 * margin, height: paperSize.height - 2 * margin)
        } else {
            return CGSize(width: paperSize.height - 2 * margin, height: paperSize.width - 2 * margin)
        }
    }
    
    public var mediaSize:CGSize {
        let width:CGFloat
        let height:CGFloat
        switch size {
        case .a0:
            width = .mm(841)
            height = .mm(1189)
        case .a1:
            width = .mm(594)
            height = .mm(841)
        case .a2:
            width = .mm(420)
            height = .mm(594)
        case .a3:
            width = .mm(297)
            height = .mm(420)
        case .a4:
            width = .mm(210)
            height = .mm(297)
        case .a5:
            width = .mm(148)
            height = .mm(210)
        case .a6:
            width = .mm(105)
            height = .mm(148)
        case .letter:
            width = .mm(216)
            height = .mm(279)
        }
        
        return CGSize(width: width, height: height)
    }
}

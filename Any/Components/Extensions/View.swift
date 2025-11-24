
import UIKit

@IBDesignable
public class RoundedView: UIView {

    @IBInspectable public var topLeft: Bool = false      { didSet { setNeedsLayout() } }
    @IBInspectable public var topRight: Bool = false     { didSet { setNeedsLayout() } }
    @IBInspectable public var bottomLeft: Bool = false   { didSet { setNeedsLayout() } }
    @IBInspectable public var bottomRight: Bool = false  { didSet { setNeedsLayout() } }
    @IBInspectable public var cornerRadius: CGFloat = 0  { didSet { setNeedsLayout() } }

    public override func layoutSubviews() {
        super.layoutSubviews()

        var options = UIRectCorner()

        if topLeft     { options.formUnion(.topLeft) }
        if topRight    { options.formUnion(.topRight) }
        if bottomLeft  { options.formUnion(.bottomLeft) }
        if bottomRight { options.formUnion(.bottomRight) }

        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: options,
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))

        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}

class BorderView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        // Initialization code
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.init(red: 241/256, green: 241/256, blue: 241/256, alpha: 1).cgColor
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 1.0
        
        self.layer.masksToBounds = false
        // set backgroundColor in order to cover the shadow inside the bounds
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0)
    }
}
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
               value: NSUnderlineStyle.single.rawValue,
                   range:NSMakeRange(0,attributeString.length))
        return attributeString
    }
}

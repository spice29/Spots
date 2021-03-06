import UIKit
import Sugar
import Tailor
import Spots
import Brick
import Imaginary

class GridCell: UICollectionViewCell, SpotConfigurable {

  var size = CGSize(width: 160, height: 340)

  lazy var imageView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
    $0.adjustsImageWhenAncestorFocused = true
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ViewModel) {
    if item.image.isPresent {
      imageView.setImage(NSURL(string: item.image))
      imageView.tintColor = UIColor.whiteColor()
      imageView.frame.size = frame.size
      imageView.width -= 20
      imageView.height -= 20
    } else {
      imageView.image = nil
    }

    if item.size.height == 0.0 {
      item.size.height = size.height
    }

    item.size.height = item.meta("height", item.size.height)
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({
      if self.focused {
        self.layer.zPosition = 1000
      } else {
        self.layer.zPosition = 0
      }
      }, completion: nil)
  }
}

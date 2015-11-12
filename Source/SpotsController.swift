import UIKit

public class SpotsController: UIViewController {

  private let spots: [Spotable]
  static let reuseIdentifier = "SpotReuseIdentifier"
  
  weak public var spotDelegate: SpotsDelegate?

  lazy var layout: UICollectionViewLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.sectionInset = UIEdgeInsetsZero
    return layout
  }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)

    collectionView.alwaysBounceVertical = true
    collectionView.autoresizesSubviews = true
    collectionView.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    return collectionView
  }()

  public required init(spots: [Spotable]) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
    view.addSubview(collectionView)
    view.autoresizesSubviews = true
    view.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
    layout.invalidateLayout()
  }
}

extension SpotsController: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spots.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let spot = spots[indexPath.item]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SpotsController.reuseIdentifier, forIndexPath: indexPath)

    if spot.render().superview == nil {
      cell.contentView.subviews.forEach { $0.removeFromSuperview() }
      cell.contentView.addSubview(spot.render())
      cell.optimize()
      spot.sizeDelegate = self
      spot.spotDelegate = spotDelegate
    }

    return cell
  }
}

extension SpotsController: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var component = spots[indexPath.item].component
    if component.size == nil {
      spots[indexPath.item].setup()
      component.size = CGSize(
        width: UIScreen.mainScreen().bounds.width,
        height: spots[indexPath.item].render().frame.height)
    }

    return component.size!
  }
}

extension SpotsController: SpotSizeDelegate {

  public func sizeDidUpdate() {
    collectionView.collectionViewLayout.invalidateLayout()
  }

  public func scrollToPreviousCell(component: Component) {
    for (index, spot) in spots.enumerate() {
      if spot.component == component {
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
          let prevIndex = index - 1
          if prevIndex >= 0 {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: prevIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
          }
        }, completion: nil)
        break
      }
    }
  }

  public func scrollToNextCell(component: Component) {
    for (index, spot) in spots.enumerate() {
      if spot.component == component {
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
          let nextIndex = index + 1
          if nextIndex < self.spots.count {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: nextIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
          }
          }, completion: nil)
        break
      }
    }
  }
}
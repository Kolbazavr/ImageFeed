import UIKit

final class ParallaxImageView: UIImageView {

    func parallaxEffect(offset: CGFloat) {
        let reducedScale: CGFloat = 0.85
        let maxShift = (1.0 - reducedScale) / 2
        let clampedOffset = max(-1, min(1, offset))

        let yOffset = 0.5 - (reducedScale / 2) + (clampedOffset * maxShift)

        let contentsRect = CGRect(
            x: 0,
            y: yOffset,
            width: 1.0,
            height: reducedScale
        )

        layer.contentsRect = contentsRect
    }
}

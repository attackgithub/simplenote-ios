import Foundation
import UIKit


// MARK: - UIView's Animation Methods
//
extension UIView {

    /// Animates a visibility switch, when applicable
    ///
    func animateVisibility(isHidden: Bool, duration: TimeInterval = 0.3) {
        guard self.isHidden != isHidden else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.isHidden = isHidden
        }
    }

    /// Fades In the receiver
    ///
    @objc
    func fadeIn() {
        self.alpha = UIKitConstants.alphaZero
        UIView.animate(withDuration: UIKitConstants.animationQuickDuration) {
            self.alpha = UIKitConstants.alphaFull
        }
    }

    /// Fades Out the receiver
    ///
    @objc
    func fadeOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: UIKitConstants.animationQuickDuration, animations: {
            self.alpha = UIKitConstants.alphaZero
        }, completion: { _ in
            completion?()
        })
    }
}

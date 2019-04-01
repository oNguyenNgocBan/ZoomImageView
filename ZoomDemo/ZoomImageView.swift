//
//  ZoomImageView.swift
//  ZoomDemo
//
//  Created by nguyen.ngoc.ban on 4/1/19.
//  Copyright © 2019 nguyen.ngoc.ban. All rights reserved.
//

import UIKit

protocol ZoomImageViewDelegate: class {
    func zoomViewDidTap(_ tap: UITapGestureRecognizer)
}

class ZoomImageView: UIView {

    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var imageView: UIImageView!

    fileprivate var url = ""
    fileprivate var imageLoaded: UIImage?
    fileprivate var maximumDoubleTapZoomScale: CGFloat = 0
    weak var delegate: ZoomImageViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }

    fileprivate func loadView() {
        configView()
        addTapAction()

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }

        // TODO xoá
        self.loadImage(image: UIImage(named: "0"))
    }

    fileprivate func addTapAction() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        self.scrollView.addGestureRecognizer(singleTap)

        singleTap.require(toFail: doubleTap)
    }

    /// have to implement load url image here
    func loadImage(urlString: String) {
        self.url = urlString
        // indicator.isHidden = false

        // load image from url here
//        imageView?.setImageStringCompletion(str: url, placeholderImage: nil, progress: nil,
//                                            completion: { [weak self] image in
//                                                self?.loadImage(image: image)
//        })
    }

    func loadImage(image: UIImage?) {
        self.imageLoaded = image
        self.imageView.image = image
        self.displayImage()
    }

    fileprivate func configView() {
        self.backgroundColor = .clear

        self.scrollView = UIScrollView(frame: self.bounds)
        self.addSubview(scrollView)
        scrollView.boundsToSuperView()
        scrollView.backgroundColor = .clear

        self.imageView = UIImageView(frame: self.bounds)
        self.imageView.isUserInteractionEnabled = true // true if handle tap event to image
        imageView.backgroundColor = .clear
        scrollView.addSubview(imageView)

        // add subview to imageView if need to display

        scrollView.delegate = self
        scrollView.delaysContentTouches = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
    }

    func displayImage() {
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        scrollView.contentSize = .zero

        if let image = self.imageLoaded {
            //            indicator.isHidden = true
            imageView.frame = CGRect(origin: .zero, size: image.size)
            scrollView.contentSize = image.size
            setMaxMinZoomScalesForCurrentBounds()
        } else {
            //            indicator.isHidden = false
        }
        self.setNeedsLayout()
    }

    func setMaxMinZoomScalesForCurrentBounds() {
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1

        guard let image = self.imageLoaded else {
            return
        }
        var boundsSize = self.bounds.size
        boundsSize.width -= 0.1
        boundsSize.height -= 0.1

        let imageSize = image.size
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height

        let minScale = min(xScale, yScale)
        let maxScale: CGFloat = 4.0

        // Calculate Max Scale Of Double Tap
        var maxDoubleTapZoomScale = 4.0 * minScale

        // Make sure maxDoubleTapZoomScale isn't larger than maxScale
        maxDoubleTapZoomScale = min(maxDoubleTapZoomScale, maxScale)

        // Set
        scrollView.maximumZoomScale = maxScale
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        self.maximumDoubleTapZoomScale = maxDoubleTapZoomScale

        // Reset position
        imageView.frame = CGRect(origin: .zero, size: imageView.frame.size)

        self.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Center the image as it becomes smaller than the size of the screen
        let boundsSize = self.bounds.size
        var frameToCenter = imageView.frame

        // Horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = CGFloat(floorf(Float((boundsSize.width - frameToCenter.size.width) / 2.0)))
        } else {
            frameToCenter.origin.x = 0
        }

        // Vertically
        if frameToCenter.size.height < boundsSize.height {
            let y = CGFloat(floorf(Float((boundsSize.height - frameToCenter.size.height) / 2.0)))
            frameToCenter.origin.y = y
        } else {
            frameToCenter.origin.y = 0
        }

        // Center
        if !imageView.frame.equalTo(frameToCenter) {
            imageView.frame = frameToCenter
        }
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        delegate?.zoomViewDidTap(sender)
    }

    @objc fileprivate func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: imageView)
        if scrollView.zoomScale == self.maximumDoubleTapZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let targetSize = CGSize(width: self.frame.width / self.maximumDoubleTapZoomScale, height: self.frame.height / self.maximumDoubleTapZoomScale)
            let targetPoint = CGPoint(x: touchPoint.x - targetSize.width / 2, y: touchPoint.y - targetSize.height / 2)

            scrollView.zoom(to: CGRect(origin: targetPoint, size: targetSize), animated: true)
        }
    }

}

extension ZoomImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

fileprivate extension UIView {

    func boundsToSuperView() {
        if let superView = self.superview {
            self.frame = superView.bounds
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.translatesAutoresizingMaskIntoConstraints = true
        }
    }

}

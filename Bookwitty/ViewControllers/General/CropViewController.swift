//
//  CropViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 12/25/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AKImageCropperView

protocol CropViewControllerDelegate: class {
  func crop(_ viewController: CropViewController, didFinishWith croppedImage: UIImage)
}

class CropViewController: UIViewController {
  
  let image: UIImage
  var cropView: AKImageCropperView!
  weak var delegate: CropViewControllerDelegate?
  init(with image:UIImage) {
    self.image = image
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.cropView = AKImageCropperView(frame:.zero)
    let overlay = AKImageCropperOverlayView(configuraiton: AKImageCropperCropViewConfiguration())
    cropView.overlayView = overlay
    cropView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(cropView)
    cropView.image = self.image
    cropView.bindFrameToSuperviewBounds()
    cropView.delegate = self
    
    let kMargin: CGFloat = -10.0
    let done = UIButton(type: .custom)
    done.setTitle(Strings.done(), for: .normal)
    done.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(done)
    done.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: kMargin).isActive = true
    done.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: kMargin).isActive = true
    done.addTarget(self, action: #selector(self.doneTouchUpInside(_:)), for: .touchUpInside)

    let cancel = UIButton(type: .custom)
    cancel.setTitle(Strings.cancel(), for: .normal)
    cancel.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(cancel)
    cancel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -kMargin).isActive = true
    cancel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: kMargin).isActive = true
    cancel.addTarget(self, action: #selector(self.cancelTouchUpInside(_:)), for: .touchUpInside)

  }
 
  func doneTouchUpInside(_ sender: UIButton) {
    
    guard let croppedImage = self.cropView.croppedImage else {
        return
    }
    self.delegate?.crop(self, didFinishWith: croppedImage)
  }
  
  func cancelTouchUpInside(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.cropView.showOverlayView(animationDuration: 1.0)
  }
}

extension CropViewController : AKImageCropperViewDelegate {
  func imageCropperViewDidChangeCropRect(view: AKImageCropperView, cropRect rect: CGRect) {
    print("New crop rectangle: \(rect)")
  }
}

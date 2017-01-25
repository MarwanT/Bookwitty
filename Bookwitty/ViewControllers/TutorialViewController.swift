//
//  TutorialViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol TutorialViewControllerDelegate {
  func tutorialViewController(_ tutorialViewController: TutorialViewController, didSelectPageAtIndex index: Int)
}

class TutorialViewController: UIPageViewController {
  let viewModel = TutorialViewModel()
  
  var tutorialDelegate: TutorialViewControllerDelegate? = nil
  
  fileprivate var orderedViewControllers: [UIViewController] = [UIViewController]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    
    orderedViewControllers.append(contentsOf: tutorialPagesViewControllers())
    
    if let firstViewController = orderedViewControllers.first {
      setViewControllers(
        [firstViewController],
        direction: UIPageViewControllerNavigationDirection.forward,
        animated: true, completion: nil)
    }
  }
  
  /// Generate tutorial pages view controllers based on provided data
  private func tutorialPagesViewControllers() -> [UIViewController] {
    var viewControllersArray = [UIViewController]()
    
    let instructionsData = viewModel.tutorialPageData
    guard instructionsData.count > 0 else {
      return viewControllersArray
    }
    
    for data in instructionsData {
      let instructionViewController = storyboard!.instantiateViewController(withIdentifier: "TutorialPageViewController") as! TutorialPageViewController
      instructionViewController.tutorialPageData = data
      viewControllersArray.append(instructionViewController)
    }
    
    return viewControllersArray
  }
  
  
  // MARK: Helper Methods
  
  fileprivate var currentViewControllerIndex: Int {
    guard let currentViewController = viewControllers?.first,
      let currentViewControllerIndex = orderedViewControllers.index(of: currentViewController) else {
        return 0
    }
    return currentViewControllerIndex
  }
}

extension TutorialViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let currentViewControllerIndex = orderedViewControllers.index(of: viewController) else {
      return nil
    }
    let previousIndex = currentViewControllerIndex-1
    guard previousIndex >= 0, previousIndex < orderedViewControllers.count else {
      return nil
    }
    return orderedViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let currentViewControllerIndex = orderedViewControllers.index(of: viewController) else {
      return nil
    }
    let nextIndex = currentViewControllerIndex+1
    guard nextIndex < orderedViewControllers.count else {
      return nil
    }
    return orderedViewControllers[nextIndex]
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return orderedViewControllers.count
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return currentViewControllerIndex
  }
}

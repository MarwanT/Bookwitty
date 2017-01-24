//
//  PageViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
  let viewModel = PageViewModel()
  
  fileprivate var orderedViewControllers: [UIViewController] = [UIViewController]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    
    orderedViewControllers.append(contentsOf: instructionsViewControllers())
    
    if let firstViewController = orderedViewControllers.first {
      setViewControllers(
        [firstViewController],
        direction: UIPageViewControllerNavigationDirection.forward,
        animated: true, completion: nil)
    }
  }
  
  /// Generate instructions view controllers based on provided data
  private func instructionsViewControllers() -> [UIViewController] {
    var viewControllersArray = [UIViewController]()
    
    let instructionsData = viewModel.instructionsData
    guard instructionsData.count > 0 else {
      return viewControllersArray
    }
    
    for data in instructionsData {
      let instructionViewController = storyboard!.instantiateViewController(withIdentifier: "IntroductionInformationViewController")
      // TODO: Send data to instruction VC
      viewControllersArray.append(instructionViewController)
    }
    
    return viewControllersArray
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension PageViewController: UIPageViewControllerDataSource {
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
    guard let currentViewController = viewControllers?.first,
      let currentViewControllerIndex = orderedViewControllers.index(of: currentViewController) else {
        return 0
    }
    return currentViewControllerIndex
  }
}

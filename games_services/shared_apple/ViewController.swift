//
//  ViewController.swift
//  games_services
//
//  Created by abedalkareem omreyh on 20/08/2022.
//

import Foundation

#if os(iOS) || os(tvOS)
typealias ViewController = UIViewController
#else
typealias ViewController = NSViewController
#endif

extension ViewController {
  func show(_ viewController: ViewController) {
#if os(iOS) || os(tvOS)
    self.present(viewController,
                 animated: true,
                 completion: nil)
#else
    self.presentAsSheet(viewController)
#endif
  }
  
  func dismiss(_ viewController: ViewController) {
#if os(iOS) || os(tvOS)
    self.dismiss(animated: true,
                 completion: nil)
#else
    self.dismiss(true)
#endif
  }
}

//
//  log.swift
//  games_services
//
//  Created by abedalkareem omreyh on 08/08/2024.
//

import Foundation

func log(_ message: String) {
  #if DEBUG
  print("[games_services] \(message)")
  #endif
}

//
//  WebViewSheet.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/13/25.
//

import SwiftUI
import SafariServices

struct WebViewSheet: UIViewControllerRepresentable {
    let url: URL
    let title: String
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        configuration.barCollapsingEnabled = true
        
        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.dismissButtonStyle = .close
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    WebViewSheet(url: URL(string: "https://dining.ncsu.edu")!, title: "Dining Menus")
}


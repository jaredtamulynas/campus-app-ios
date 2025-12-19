//
//  NavigatableRow.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/14/25.
//

import SwiftUI

// MARK: - Protocol

protocol NavigatableItem: Identifiable {
    var title: String { get }
    var subtitle: String? { get }
    var icon: String { get }
    var iconColor: Color { get }
    var navigationType: NavigationType { get }
    var navigationDestination: NavigationDestination { get }
}

// MARK: - Navigation Types

enum NavigationType {
    case link       // Opens URL in external browser
    case navigation // Pushes view onto navigation stack
    case sheet      // Presents sheet (SFSafari or custom)
    case action     // Opens URL via openURL (deep links, tel:, etc.)
    case none
}

struct NavigationDestination {
    var url: String?
    var viewIdentifier: String?
    var viewBuilder: (() -> AnyView)?
    var contactInfo: Resource.ContactInfo?
    
    init(
        url: String? = nil,
        viewIdentifier: String? = nil,
        viewBuilder: (() -> AnyView)? = nil,
        contactInfo: Resource.ContactInfo? = nil
    ) {
        self.url = url
        self.viewIdentifier = viewIdentifier
        self.viewBuilder = viewBuilder
        self.contactInfo = contactInfo
    }
}

// MARK: - Navigatable Row

struct NavigatableRow<Item: NavigatableItem>: View {
    let item: Item
    var isFavorite: Bool? = nil
    var onTap: (() -> Void)? = nil
    var onFavoriteToggle: (() -> Void)? = nil
    
    @State private var showingSheet = false
    @State private var isNavigating = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        switch item.navigationType {
        case .navigation:
            navigationRow
        case .link, .action:
            urlRow
        case .sheet:
            sheetRow
        case .none:
            plainRow
        }
    }
    
    // MARK: - Navigation Row (pushes view)
    
    private var navigationRow: some View {
        NavigationLink {
            if let viewBuilder = item.navigationDestination.viewBuilder {
                viewBuilder()
                    .onAppear { onTap?() }
            }
        } label: {
            rowContent
        }
    }
    
    // MARK: - URL Row (external link or deep link)
    
    private var urlRow: some View {
        Button {
            onTap?()
            if let urlString = item.navigationDestination.url,
               let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Sheet Row (SFSafari or contact sheet)
    
    private var sheetRow: some View {
        Button {
            onTap?()
            showingSheet = true
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingSheet) {
            sheetContent
        }
    }
    
    // MARK: - Plain Row (no navigation)
    
    private var plainRow: some View {
        rowContent
    }
    
    // MARK: - Row Content
    
    private var rowContent: some View {
        HStack {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .foregroundStyle(.primary)
                    
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } icon: {
                Image(systemName: item.icon)
                    .foregroundStyle(item.iconColor)
            }
            
            Spacer()
            
            if let isFavorite, let onFavoriteToggle {
                Button {
                    onFavoriteToggle()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(isFavorite ? .yellow : .secondary)
                }
                .buttonStyle(.borderless)
            }
        }
        .contentShape(Rectangle())
    }
    
    // MARK: - Sheet Content
    
    @ViewBuilder
    private var sheetContent: some View {
        if let contactInfo = item.navigationDestination.contactInfo,
           let resource = item as? Resource {
            ResourceContactSheet(resource: resource, contactInfo: contactInfo)
        } else if let urlString = item.navigationDestination.url,
                  let url = URL(string: urlString) {
            WebViewSheet(url: url, title: item.title)
        } else if let viewBuilder = item.navigationDestination.viewBuilder {
            viewBuilder()
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        NavigatableRow(
            item: Resource.previewSamples[0],
            isFavorite: true,
            onTap: { print("Tapped") },
            onFavoriteToggle: { print("Toggle favorite") }
        )
    }
}

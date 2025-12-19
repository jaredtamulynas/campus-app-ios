//
//  ResourceContactSheet.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/13/25.
//

import SwiftUI
import MapKit

struct ResourceContactSheet: View {
    let resource: Resource
    let contactInfo: Resource.ContactInfo
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            List {
                // Resource Info Section
                Section {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.15))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: resource.icon)
                                .font(.title3)
                                .foregroundStyle(.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(resource.name)
                                .font(.headline)
                            
                            Text(resource.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Contact Actions Section
                Section("Contact") {
                    if let phone = contactInfo.phone {
                        Button {
                            if let url = URL(string: "tel:\(phone.replacingOccurrences(of: "-", with: ""))") {
                                openURL(url)
                            }
                        } label: {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Phone")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(phone)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                            } icon: {
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    
                    if let email = contactInfo.email {
                        Button {
                            if let url = URL(string: "mailto:\(email)") {
                                openURL(url)
                            }
                        } label: {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Email")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(email)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                            } icon: {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                
                // Location Section
                if let location = contactInfo.location {
                    Section("Location") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text(location.address)
                                    .font(.body)
                            } icon: {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            
                            if let latitude = location.latitude,
                               let longitude = location.longitude {
                                
                                // Map Preview
                                Map(position: .constant(.region(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(
                                        latitude: latitude,
                                        longitude: longitude
                                    ),
                                    span: MKCoordinateSpan(
                                        latitudeDelta: 0.005,
                                        longitudeDelta: 0.005
                                    )
                                )))) {
                                    Marker(resource.name, coordinate: CLLocationCoordinate2D(
                                        latitude: latitude,
                                        longitude: longitude
                                    ))
                                    .tint(.red)
                                }
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .allowsHitTesting(false)
                                
                                // Open in Maps Button
                                Button {
                                    openInMaps(latitude: latitude, longitude: longitude)
                                } label: {
                                    Label("Open in Maps", systemImage: "map.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                // Main Link Section
                if let urlString = resource.destination.url {
                    Section {
                        Button {
                            if let url = URL(string: urlString) {
                                openURL(url)
                                dismiss()
                            }
                        } label: {
                            Label("Visit Website", systemImage: "arrow.up.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
            .navigationTitle("Contact Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func openInMaps(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = resource.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

//#Preview {
//    ResourceContactSheet(
//        resource: Resource(
//            id: "preview",
//            name: "Wolfpack OneCard",
//            description: "Manage your campus ID",
//            icon: "creditcard.fill",
//            category: .essentials,
//            type: .externalLink,
//            destination: Resource.ResourceDestination(
//                viewIdentifier: nil,
//                url: "https://onecard.ncsu.edu",
//                content: nil
//            ),
//            visibility: PerspectiveVisibility(perspectives: [.student]),
//            contactInfo: Resource.ContactInfo(
//                phone: "919-515-3090",
//                email: "onecard@ncsu.edu",
//                location: Resource.ContactInfo.LocationInfo(
//                    address: "2701 Cates Ave, Raleigh, NC 27695",
//                    latitude: 35.7866,
//                    longitude: -78.6647
//                )
//            )
//        ),
//        contactInfo: Resource.ContactInfo(
//            phone: "919-515-3090",
//            email: "onecard@ncsu.edu",
//            location: Resource.ContactInfo.LocationInfo(
//                address: "2701 Cates Ave, Raleigh, NC 27695",
//                latitude: 35.7866,
//                longitude: -78.6647
//            )
//        )
//    )
//}
//

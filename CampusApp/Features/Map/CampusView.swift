//
//  CampusView.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI
import MapKit

// MARK: - Campus View

struct CampusView: View {
    @Environment(CampusManager.self) private var campusManager
    @Environment(UserSettings.self) private var userSettings
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedCategory: MapCategory = .all
    @State private var selectedLocation: CampusLocation?
    @State private var showingLocationDetail = false
    @State private var searchText = ""
    @State private var showingLayerSheet = false
    @State private var selectedMapStyle: SelectedMapStyle = .standard
    
    // Layer visibility toggles
    @State private var showBuildings = true
    @State private var showDining = true
    @State private var showParking = true
    @State private var showBusStops = true
    @State private var showLibraries = true
    @State private var showAthletics = false
    @State private var showBusRoutes = false
    
    // Simulated live data
    @State private var busLocations: [LiveBusLocation] = []
    @State private var parkingAvailability: [String: Int] = [:]
    
    private var filteredLocations: [CampusLocation] {
        var locations = CampusLocation.allLocations
        
        // Filter by category
        if selectedCategory != .all {
            locations = locations.filter { $0.category == selectedCategory }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            locations = locations.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Filter by layer visibility
        locations = locations.filter { location in
            switch location.category {
            case .all: return true
            case .building: return showBuildings
            case .dining: return showDining
            case .parking: return showParking
            case .busStop: return showBusStops
            case .library: return showLibraries
            case .athletics: return showAthletics
            case .housing, .health, .recreation: return true
            }
        }
        
        return locations
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map
                mapView
                
                // Bottom Sheet with categories and search results
                bottomControls
            }
            .navigationTitle("Campus Map")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search locations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        // Map Style
                        Section("Map Style") {
                            Button {
                                selectedMapStyle = .standard
                            } label: {
                                Label("Standard", systemImage: selectedMapStyle == .standard ? "checkmark" : "")
                            }
                            
                            Button {
                                selectedMapStyle = .satellite
                            } label: {
                                Label("Satellite", systemImage: selectedMapStyle == .satellite ? "checkmark" : "")
                            }
                            
                            Button {
                                selectedMapStyle = .hybrid
                            } label: {
                                Label("Hybrid", systemImage: selectedMapStyle == .hybrid ? "checkmark" : "")
                            }
                        }
                        
                        Divider()
                        
                        // Layers
                        Section("Layers") {
                            Toggle("Buildings", isOn: $showBuildings)
                            Toggle("Dining", isOn: $showDining)
                            Toggle("Parking", isOn: $showParking)
                            Toggle("Bus Stops", isOn: $showBusStops)
                            Toggle("Libraries", isOn: $showLibraries)
                            Toggle("Athletics", isOn: $showAthletics)
                        }
                        
                        Divider()
                        
                        // Live Tracking
                        Section("Live Tracking") {
                            Toggle("Bus Routes", isOn: $showBusRoutes)
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            position = .region(campusManager.config.mapRegion)
                        }
                    } label: {
                        Image(systemName: "location.fill")
                    }
                }
            }
            .sheet(item: $selectedLocation) { location in
                LocationDetailSheet(location: location)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                position = .region(campusManager.config.mapRegion)
                loadSimulatedLiveData()
            }
        }
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        Map(position: $position, selection: $selectedLocation) {
            // Campus Locations
            ForEach(filteredLocations) { location in
                Marker(location.name, systemImage: location.category.icon, coordinate: location.coordinate)
                    .tint(location.category.color)
                    .tag(location)
            }
            
            // Live Bus Locations (if enabled)
            if showBusRoutes {
                ForEach(busLocations) { bus in
                    Annotation(bus.routeName, coordinate: bus.coordinate) {
                        LiveBusMarker(bus: bus)
                    }
                }
            }
            
            // Bus Route Polylines (if enabled)
            if showBusRoutes {
                // Simulated route paths
                MapPolyline(coordinates: wolflineBlueRoute)
                    .stroke(.blue, lineWidth: 4)
                
                MapPolyline(coordinates: wolflineRedRoute)
                    .stroke(.red, lineWidth: 4)
            }
        }
        .mapStyle(selectedMapStyle.mapStyle)
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 0) {
            // Category Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MapCategory.allCases, id: \.self) { category in
                        MapCategoryChip(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(.ultraThinMaterial)
            
            // Quick Access Cards (when not searching)
            if searchText.isEmpty {
                quickAccessSection
            } else if !filteredLocations.isEmpty {
                searchResultsList
            }
        }
    }
    
    // MARK: - Quick Access Section
    
    private var quickAccessSection: some View {
        VStack(spacing: 0) {
            // Live Status Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Wolfline Quick Card
                    MapQuickCard(
                        icon: "bus.fill",
                        iconColor: .blue,
                        title: "Wolfline",
                        subtitle: "3 buses nearby",
                        isLive: true
                    ) {
                        withAnimation {
                            showBusRoutes = true
                            selectedCategory = .busStop
                        }
                    }
                    
                    // Parking Quick Card
                    MapQuickCard(
                        icon: "parkingsign.circle.fill",
                        iconColor: .green,
                        title: "Parking",
                        subtitle: "Dan Allen: 45 spots",
                        isLive: true
                    ) {
                        withAnimation {
                            selectedCategory = .parking
                        }
                    }
                    
                    // Dining Quick Card
                    MapQuickCard(
                        icon: "fork.knife",
                        iconColor: .orange,
                        title: "Dining",
                        subtitle: "5 open nearby",
                        isLive: false
                    ) {
                        withAnimation {
                            selectedCategory = .dining
                        }
                    }
                    
                    // Libraries Quick Card
                    MapQuickCard(
                        icon: "building.columns.fill",
                        iconColor: .purple,
                        title: "Libraries",
                        subtitle: "Hill: Open",
                        isLive: false
                    ) {
                        withAnimation {
                            selectedCategory = .library
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(.regularMaterial)
        }
    }
    
    // MARK: - Search Results List
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredLocations.prefix(5)) { location in
                    Button {
                        selectedLocation = location
                        // Center map on location
                        withAnimation {
                            position = .region(MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            ))
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: location.category.icon)
                                .font(.title3)
                                .foregroundStyle(location.category.color)
                                .frame(width: 36, height: 36)
                                .background(location.category.color.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(location.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                if let subtitle = location.subtitle {
                                    Text(subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .frame(maxHeight: 250)
        .background(.regularMaterial)
    }
    
    // MARK: - Simulated Data
    
    private func loadSimulatedLiveData() {
        // Simulated bus locations
        busLocations = [
            LiveBusLocation(id: "bus-1", routeName: "Blue Route", routeColor: .blue,
                           coordinate: CLLocationCoordinate2D(latitude: 35.7850, longitude: -78.6700),
                           heading: 45, nextStop: "Talley Student Union", eta: "2 min"),
            LiveBusLocation(id: "bus-2", routeName: "Red Route", routeColor: .red,
                           coordinate: CLLocationCoordinate2D(latitude: 35.7880, longitude: -78.6750),
                           heading: 180, nextStop: "D.H. Hill Library", eta: "5 min"),
            LiveBusLocation(id: "bus-3", routeName: "Blue Route", routeColor: .blue,
                           coordinate: CLLocationCoordinate2D(latitude: 35.7720, longitude: -78.6780),
                           heading: 270, nextStop: "Hunt Library", eta: "3 min")
        ]
        
        // Simulated parking availability
        parkingAvailability = [
            "dan-allen": 45,
            "coliseum": 120,
            "reynolds": 80,
            "jeter": 25
        ]
    }
    
    // Simulated Wolfline routes
    private var wolflineBlueRoute: [CLLocationCoordinate2D] {
        [
            CLLocationCoordinate2D(latitude: 35.7866, longitude: -78.6689),
            CLLocationCoordinate2D(latitude: 35.7850, longitude: -78.6700),
            CLLocationCoordinate2D(latitude: 35.7800, longitude: -78.6720),
            CLLocationCoordinate2D(latitude: 35.7731, longitude: -78.6743),
            CLLocationCoordinate2D(latitude: 35.7700, longitude: -78.6780)
        ]
    }
    
    private var wolflineRedRoute: [CLLocationCoordinate2D] {
        [
            CLLocationCoordinate2D(latitude: 35.7900, longitude: -78.6650),
            CLLocationCoordinate2D(latitude: 35.7880, longitude: -78.6700),
            CLLocationCoordinate2D(latitude: 35.7866, longitude: -78.6689),
            CLLocationCoordinate2D(latitude: 35.7847, longitude: -78.6821)
        ]
    }
}

// MARK: - Selected Map Style

enum SelectedMapStyle: String, CaseIterable {
    case standard
    case satellite
    case hybrid
    
    var mapStyle: MapStyle {
        switch self {
        case .standard: return .standard
        case .satellite: return .imagery
        case .hybrid: return .hybrid
        }
    }
}

// MARK: - Map Category

enum MapCategory: String, CaseIterable {
    case all = "All"
    case building = "Buildings"
    case dining = "Dining"
    case parking = "Parking"
    case busStop = "Bus Stops"
    case library = "Libraries"
    case athletics = "Athletics"
    case housing = "Housing"
    case health = "Health"
    case recreation = "Recreation"
    
    var icon: String {
        switch self {
        case .all: return "map.fill"
        case .building: return "building.2.fill"
        case .dining: return "fork.knife"
        case .parking: return "parkingsign.circle.fill"
        case .busStop: return "bus.fill"
        case .library: return "building.columns.fill"
        case .athletics: return "sportscourt.fill"
        case .housing: return "house.fill"
        case .health: return "cross.case.fill"
        case .recreation: return "figure.run"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .building: return .blue
        case .dining: return .orange
        case .parking: return .green
        case .busStop: return .blue
        case .library: return .purple
        case .athletics: return .red
        case .housing: return .teal
        case .health: return .pink
        case .recreation: return .cyan
        }
    }
}

// MARK: - Campus Location

struct CampusLocation: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String?
    let category: MapCategory
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let phone: String?
    let hours: String?
    let description: String?
    
    static func == (lhs: CampusLocation, rhs: CampusLocation) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Sample campus locations
    static let allLocations: [CampusLocation] = [
        // Buildings
        CampusLocation(id: "belltower", name: "Memorial Belltower", subtitle: "Campus Landmark", category: .building,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7866, longitude: -78.6689),
                      address: "2500 Hillsborough St", phone: nil, hours: "Always accessible", description: "Historic campus landmark"),
        CampusLocation(id: "talley", name: "Talley Student Union", subtitle: "Student Center", category: .building,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7731, longitude: -78.6743),
                      address: "2610 Cates Ave", phone: "919-515-5277", hours: "7 AM - 11 PM", description: "Main student center"),
        CampusLocation(id: "eb2", name: "Engineering Building II", subtitle: "Engineering", category: .building,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7720, longitude: -78.6760),
                      address: "890 Oval Dr", phone: nil, hours: "7 AM - 10 PM", description: "Engineering classrooms and labs"),
        CampusLocation(id: "poe-hall", name: "Poe Hall", subtitle: "Education", category: .building,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7855, longitude: -78.6665),
                      address: "2310 Stinson Dr", phone: nil, hours: "7 AM - 10 PM", description: "College of Education"),
        CampusLocation(id: "witherspoon", name: "Witherspoon Student Center", subtitle: "Centennial Campus", category: .building,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7683, longitude: -78.6722),
                      address: "2810 Katharine Stinson Dr", phone: nil, hours: "7 AM - 10 PM", description: "Centennial Campus student center"),
        
        // Libraries
        CampusLocation(id: "hill-library", name: "D.H. Hill Jr. Library", subtitle: "Main Library", category: .library,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7868, longitude: -78.6704),
                      address: "2 Broughton Dr", phone: "919-515-3364", hours: "Open 24 hours (exam periods)", description: "Main campus library"),
        CampusLocation(id: "hunt-library", name: "James B. Hunt Jr. Library", subtitle: "Centennial Campus", category: .library,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7847, longitude: -78.6821),
                      address: "1070 Partners Way", phone: "919-515-7110", hours: "Open 24 hours", description: "Technology-focused library"),
        
        // Dining
        CampusLocation(id: "fountain", name: "Fountain Dining Hall", subtitle: "All-You-Care-To-Eat", category: .dining,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7865, longitude: -78.6650),
                      address: "110 Lampe Dr", phone: nil, hours: "7 AM - 9 PM", description: "Main dining hall"),
        CampusLocation(id: "clark-dining", name: "Clark Dining Hall", subtitle: "All-You-Care-To-Eat", category: .dining,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7890, longitude: -78.6620),
                      address: "2601 Cates Ave", phone: nil, hours: "7 AM - 8 PM", description: "North campus dining"),
        CampusLocation(id: "oval", name: "The Oval", subtitle: "Food Court", category: .dining,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7730, longitude: -78.6741),
                      address: "Talley Student Union", phone: nil, hours: "10 AM - 10 PM", description: "Multiple dining options"),
        CampusLocation(id: "atrium", name: "Atrium Food Court", subtitle: "Centennial Campus", category: .dining,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7685, longitude: -78.6720),
                      address: "Centennial Campus", phone: nil, hours: "7 AM - 3 PM", description: "Centennial Campus dining"),
        
        // Parking
        CampusLocation(id: "dan-allen", name: "Dan Allen Deck", subtitle: "Parking Deck", category: .parking,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7860, longitude: -78.6670),
                      address: "Dan Allen Dr", phone: nil, hours: "24 hours", description: "Central campus parking"),
        CampusLocation(id: "coliseum", name: "Coliseum Deck", subtitle: "Parking Deck", category: .parking,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7880, longitude: -78.6800),
                      address: "Trinity Rd", phone: nil, hours: "24 hours", description: "Near Reynolds Coliseum"),
        CampusLocation(id: "reynolds-lot", name: "Reynolds Lot", subtitle: "Surface Lot", category: .parking,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7870, longitude: -78.6810),
                      address: "Reynolds Coliseum", phone: nil, hours: "24 hours", description: "Surface parking lot"),
        CampusLocation(id: "jeter-lot", name: "Jeter Drive Lot", subtitle: "Surface Lot", category: .parking,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7900, longitude: -78.6650),
                      address: "Jeter Dr", phone: nil, hours: "24 hours", description: "North campus parking"),
        
        // Bus Stops
        CampusLocation(id: "bus-talley", name: "Talley Student Union", subtitle: "Bus Stop", category: .busStop,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7733, longitude: -78.6745),
                      address: "Cates Ave", phone: nil, hours: nil, description: "Multiple routes"),
        CampusLocation(id: "bus-hill", name: "D.H. Hill Library", subtitle: "Bus Stop", category: .busStop,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7870, longitude: -78.6700),
                      address: "Hillsborough St", phone: nil, hours: nil, description: "Blue, Red routes"),
        CampusLocation(id: "bus-hunt", name: "Hunt Library", subtitle: "Bus Stop", category: .busStop,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7845, longitude: -78.6825),
                      address: "Partners Way", phone: nil, hours: nil, description: "Centennial routes"),
        CampusLocation(id: "bus-gorman", name: "Gorman St", subtitle: "Bus Stop", category: .busStop,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7750, longitude: -78.6850),
                      address: "Gorman St", phone: nil, hours: nil, description: "Off-campus routes"),
        
        // Athletics
        CampusLocation(id: "carter-finley", name: "Carter-Finley Stadium", subtitle: "Football", category: .athletics,
                      coordinate: CLLocationCoordinate2D(latitude: 35.8009, longitude: -78.7180),
                      address: "4600 Trinity Rd", phone: nil, hours: "Game days", description: "Football stadium"),
        CampusLocation(id: "pnc-arena", name: "PNC Arena", subtitle: "Basketball & Hockey", category: .athletics,
                      coordinate: CLLocationCoordinate2D(latitude: 35.8033, longitude: -78.7219),
                      address: "1400 Edwards Mill Rd", phone: nil, hours: "Event days", description: "Basketball and hockey arena"),
        CampusLocation(id: "reynolds", name: "Reynolds Coliseum", subtitle: "Historic Arena", category: .athletics,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7875, longitude: -78.6830),
                      address: "2411 Dunn Ave", phone: nil, hours: "Varies", description: "Historic arena"),
        
        // Health
        CampusLocation(id: "student-health", name: "Student Health Center", subtitle: "Medical Services", category: .health,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7714, longitude: -78.6733),
                      address: "Talley Student Union, 3rd Floor", phone: "919-515-2563", hours: "8 AM - 5 PM", description: "Student medical services"),
        CampusLocation(id: "counseling", name: "Counseling Center", subtitle: "Mental Health", category: .health,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7714, longitude: -78.6733),
                      address: "Student Health Services", phone: "919-515-2423", hours: "8 AM - 5 PM", description: "Mental health support"),
        
        // Recreation
        CampusLocation(id: "carmichael", name: "Carmichael Gym", subtitle: "Recreation Center", category: .recreation,
                      coordinate: CLLocationCoordinate2D(latitude: 35.7856, longitude: -78.6817),
                      address: "2500 Cates Ave", phone: "919-515-3161", hours: "6 AM - 11 PM", description: "Main recreation facility")
    ]
}

// MARK: - Live Bus Location

struct LiveBusLocation: Identifiable {
    let id: String
    let routeName: String
    let routeColor: Color
    let coordinate: CLLocationCoordinate2D
    let heading: Double
    let nextStop: String
    let eta: String
}

// MARK: - Map Category Chip

struct MapCategoryChip: View {
    let category: MapCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color(.systemGray5))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Map Quick Card

struct MapQuickCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isLive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(iconColor)
                    
                    Spacer()
                    
                    if isLive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.red)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 130)
            .padding(12)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Live Bus Marker

struct LiveBusMarker: View {
    let bus: LiveBusLocation
    
    var body: some View {
        ZStack {
            Circle()
                .fill(bus.routeColor)
                .frame(width: 32, height: 32)
                .shadow(radius: 3)
            
            Image(systemName: "bus.fill")
                .font(.caption)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Location Detail Sheet

struct LocationDetailSheet: View {
    let location: CampusLocation
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(spacing: 16) {
                        Image(systemName: location.category.icon)
                            .font(.title)
                            .foregroundStyle(location.category.color)
                            .frame(width: 56, height: 56)
                            .background(location.category.color.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if let subtitle = location.subtitle {
                                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Description
                    if let description = location.description {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    
                    // Info Cards
                    VStack(spacing: 12) {
                        if let address = location.address {
                            LocationInfoRow(icon: "mappin.circle.fill", iconColor: .red, title: "Address", value: address)
                        }
                        
                        if let hours = location.hours {
                            LocationInfoRow(icon: "clock.fill", iconColor: .blue, title: "Hours", value: hours)
                        }
                        
                        if let phone = location.phone {
                            Button {
                                if let url = URL(string: "tel:\(phone.replacingOccurrences(of: "-", with: ""))") {
                                    openURL(url)
                                }
                            } label: {
                                LocationInfoRow(icon: "phone.fill", iconColor: .green, title: "Phone", value: phone, showChevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button {
                            openInMaps()
                        } label: {
                            Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(location.category.color)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .navigationTitle("Location Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Location Info Row

struct LocationInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CampusView()
        .environment(CampusManager())
        .environment(UserSettings())
}

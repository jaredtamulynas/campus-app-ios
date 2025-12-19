//
//  GuideDetailView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/3/25.
//

import SwiftUI
import MapKit
import EventKit

struct GuideDetailView: View {
    let guide: Guide
    @Environment(UserSettings.self) private var userSettings
    @State private var selectedEventCategory: EventCategory?
    @State private var showOnlyRSVP = false
    @State private var expandedFAQs: Set<String> = []
    @State private var showingCalendarAlert = false
    @State private var calendarAlertMessage = ""
    @State private var showingActiveGuide = false
    
    private var guideColor: Color {
        colorForName(guide.color)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
                if let headerImageUrl = guide.headerImageUrl {
                    heroImageSection(headerImageUrl)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Start Guide Button (if has sections)
                    if guide.hasSections {
                        startGuideButton
                    }
                    
                    // Urgent Updates
                    if let updates = guide.updates?.filter({ $0.type == .urgent || $0.type == .cancellation }), !updates.isEmpty {
                        urgentUpdatesSection(updates)
                    }
                    
                    // Todos Section
                    if guide.hasTodos {
                        todosSection
                    }
                    
                    // Events Section
                    if guide.hasEvents {
                        eventsSection
                    }
                    
                    // Map Section (if locations exist)
                    if guide.hasLocations {
                        mapSection
                    }
                    
                    // Content Sections
                    if guide.hasSections {
                        sectionsSection
                    }
                    
                    // FAQs
                    if guide.hasFAQs {
                        faqsSection
                    }
                    
                    // Quick Links
                    if guide.hasLinks {
                        linksSection
                    }
                    
                    // Contacts
                    if guide.hasContacts {
                        contactsSection
                    }
                    
                    // All Updates
                    if guide.hasUpdates {
                        allUpdatesSection
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(guide.headerImageUrl == nil ? .large : .inline)
        .alert("Calendar", isPresented: $showingCalendarAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(calendarAlertMessage)
        }
        .onAppear {
            userSettings.markGuideStarted(guide.id)
        }
        .sheet(isPresented: $showingActiveGuide) {
            ActiveGuideView(guide: guide)
        }
    }
    
    // MARK: - Start Guide Button
    
    private var startGuideButton: some View {
        Button {
            showingActiveGuide = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Guide")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(guideColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Hero Image Section
    
    private func heroImageSection(_ imageUrl: String) -> some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay { ProgressView() }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            case .failure:
                Rectangle()
                    .fill(guideColor.opacity(0.3))
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: guide.icon)
                            .font(.system(size: 60))
                            .foregroundStyle(guideColor)
                    }
            @unknown default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(guideColor.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: guide.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(guideColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(guide.department)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Quick stats
                    HStack(spacing: 12) {
                        if guide.hasTodos {
                            Label("\(guide.todos?.count ?? 0) tasks", systemImage: "checklist")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if guide.hasEvents {
                            Label("\(guide.events?.count ?? 0) events", systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            
            if !guide.description.isEmpty {
                Text(guide.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            // Alert banner
            if let alert = guide.alert {
                alertBanner(alert)
            }
        }
        .padding(.horizontal)
    }
    
    private func alertBanner(_ alert: GuideAlert) -> some View {
        HStack(spacing: 8) {
            Image(systemName: alert.type.icon)
            Text(alert.message)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorForName(alert.type.color), in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Urgent Updates Section
    
    private func urgentUpdatesSection(_ updates: [GuideUpdate]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(updates) { update in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: update.type.icon)
                        .foregroundStyle(colorForName(update.type.color))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(update.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(update.message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorForName(update.type.color).opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Todos Section
    
    private var todosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "To-Do List",
                icon: "checklist",
                badge: todoProgressBadge
            )
            
            if let todos = guide.todos {
                // Group by category
                let grouped = Dictionary(grouping: todos, by: { $0.category ?? "Tasks" })
                let sortedKeys = grouped.keys.sorted()
                
                ForEach(sortedKeys, id: \.self) { category in
                    if sortedKeys.count > 1 {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    
                    ForEach(grouped[category] ?? []) { todo in
                        TodoRow(
                            guideId: guide.id,
                            todo: todo,
                            isComplete: userSettings.isTodoComplete(guide.id, todoId: todo.id)
                        ) {
                            userSettings.toggleTodoComplete(guide.id, todoId: todo.id)
                        }
                    }
                }
            }
        }
    }
    
    private var todoProgressBadge: some View {
        let total = guide.todos?.count ?? 0
        let completed = userSettings.completedTodoCount(for: guide.id, totalTodos: total)
        
        return Text("\(completed)/\(total)")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(completed == total && total > 0 ? Color.green : guideColor, in: Capsule())
    }
    
    // MARK: - Events Section
    
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Schedule", icon: "calendar")
            
            // Filter chips
            eventFilterChips
            
            // RSVP toggle
            Toggle(isOn: $showOnlyRSVP) {
                Label("My Schedule", systemImage: "star.fill")
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
            // Events list
            let filteredEvents = filterEvents(guide.events ?? [])
            
            if filteredEvents.isEmpty {
                emptyEventsView
            } else {
                ForEach(filteredEvents) { event in
                    EventRow(
                        guideId: guide.id,
                        event: event,
                        guideColor: guideColor,
                        isRSVPd: userSettings.isEventRSVPd(guide.id, eventId: event.id),
                        onRSVP: {
                            userSettings.toggleEventRSVP(guide.id, eventId: event.id)
                        },
                        onAddToCalendar: {
                            addEventToCalendar(event)
                        }
                    )
                }
            }
        }
    }
    
    private var eventCategories: [EventCategory] {
        let categories = Set(guide.events?.map { $0.category } ?? [])
        return Array(categories).sorted { $0.rawValue < $1.rawValue }
    }
    
    private var eventFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" filter button
                Button {
                    selectedEventCategory = nil
                } label: {
                    Text("All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedEventCategory == nil ? guideColor : Color(.systemGray5), in: Capsule())
                        .foregroundStyle(selectedEventCategory == nil ? .white : .primary)
                }
                
                // Category filter buttons
                ForEach(eventCategories, id: \.self) { category in
                    Button {
                        selectedEventCategory = category
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption2)
                            Text(category.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedEventCategory == category ? guideColor : Color(.systemGray5), in: Capsule())
                        .foregroundStyle(selectedEventCategory == category ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var emptyEventsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.title)
                .foregroundStyle(.secondary)
            Text(showOnlyRSVP ? "No events in your schedule" : "No events match filter")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    private func filterEvents(_ events: [GuideEvent]) -> [GuideEvent] {
        var filtered = events
        
        if let category = selectedEventCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if showOnlyRSVP {
            filtered = filtered.filter { userSettings.isEventRSVPd(guide.id, eventId: $0.id) }
        }
        
        return filtered
    }
    
    // MARK: - Map Section
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Locations", icon: "map.fill")
            
            if let locations = guide.locations {
                // Map view
                let region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: locations.first?.latitude ?? 35.7847,
                        longitude: locations.first?.longitude ?? -78.6821
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
                
                Map(initialPosition: .region(region)) {
                    ForEach(locations) { location in
                        Marker(
                            location.name,
                            systemImage: location.icon ?? location.category?.icon ?? "mappin",
                            coordinate: CLLocationCoordinate2D(
                                latitude: location.latitude,
                                longitude: location.longitude
                            )
                        )
                        .tint(guideColor)
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Location list
                ForEach(locations) { location in
                    LocationRow(location: location)
                }
            }
        }
    }
    
    // MARK: - Sections Section
    
    private var sectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Information", icon: "doc.text.fill")
            
            if let sections = guide.sections?.sorted(by: { $0.order < $1.order }) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.headline)
                        
                        Text(section.content)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - FAQs Section
    
    private var faqsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "FAQs", icon: "questionmark.circle.fill")
            
            if let faqs = guide.faqs {
                ForEach(faqs) { faq in
                    FAQRow(
                        faq: faq,
                        isExpanded: expandedFAQs.contains(faq.id),
                        guideColor: guideColor
                    ) {
                        withAnimation {
                            if expandedFAQs.contains(faq.id) {
                                expandedFAQs.remove(faq.id)
                            } else {
                                expandedFAQs.insert(faq.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Links Section
    
    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Quick Links", icon: "link")
            
            if let links = guide.links {
                ForEach(links) { link in
                    LinkRow(link: link, guideColor: guideColor)
                }
            }
        }
    }
    
    // MARK: - Contacts Section
    
    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Contacts", icon: "person.crop.circle.fill")
            
            if let contacts = guide.contacts {
                ForEach(contacts) { contact in
                    ContactRow(contact: contact, guideColor: guideColor)
                }
            }
        }
    }
    
    // MARK: - All Updates Section
    
    private var allUpdatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Updates", icon: "bell.fill")
            
            if let updates = guide.updates {
                ForEach(updates) { update in
                    UpdateRow(update: update)
                }
            }
        }
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(title: String, icon: String, badge: (some View)? = nil as EmptyView?) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            if let badge = badge {
                badge
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Calendar Helper
    
    private func addEventToCalendar(_ event: GuideEvent) {
        let eventStore = EKEventStore()
        
        eventStore.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if granted {
                    let calendarEvent = EKEvent(eventStore: eventStore)
                    calendarEvent.title = event.title
                    calendarEvent.notes = event.description
                    calendarEvent.location = event.location
                    
                    // Parse date
                    let formatter = ISO8601DateFormatter()
                    if let startDate = formatter.date(from: event.startDate) {
                        calendarEvent.startDate = startDate
                        if let endDateStr = event.endDate, let endDate = formatter.date(from: endDateStr) {
                            calendarEvent.endDate = endDate
                        } else {
                            calendarEvent.endDate = startDate.addingTimeInterval(3600)
                        }
                    } else {
                        calendarEvent.startDate = Date()
                        calendarEvent.endDate = Date().addingTimeInterval(3600)
                    }
                    
                    calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try eventStore.save(calendarEvent, span: .thisEvent)
                        userSettings.markEventAddedToCalendar(guide.id, eventId: event.id)
                        calendarAlertMessage = "Event added to your calendar!"
                    } catch {
                        calendarAlertMessage = "Could not save event: \(error.localizedDescription)"
                    }
                } else {
                    calendarAlertMessage = "Calendar access not granted. Please enable in Settings."
                }
                showingCalendarAlert = true
            }
        }
    }
    
    // MARK: - Color Helper
    
    private func colorForName(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "teal": return .teal
        case "mint": return .mint
        case "gray": return .gray
        default: return .blue
        }
    }
}

// MARK: - Supporting Views

private struct TodoRow: View {
    let guideId: String
    let todo: GuideTodo
    let isComplete: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isComplete ? .green : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isComplete ? .secondary : .primary)
                        .strikethrough(isComplete)
                    
                    if let description = todo.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        if let dueDate = todo.dueDate {
                            Label(dueDate, systemImage: "clock")
                                .font(.caption2)
                                .foregroundStyle(todo.priorityLevel == .high ? .red : .secondary)
                        }
                        
                        if todo.priorityLevel == .high {
                            Text("High Priority")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Spacer()
                
                if let url = todo.linkedUrl, let _ = URL(string: url) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

private struct EventRow: View {
    let guideId: String
    let event: GuideEvent
    let guideColor: Color
    let isRSVPd: Bool
    let onRSVP: () -> Void
    let onAddToCalendar: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: event.category.icon)
                            .font(.caption)
                            .foregroundStyle(guideColor)
                        
                        Text(event.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if event.isRequiredEvent {
                            Text("Required")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.red, in: Capsule())
                        }
                    }
                    
                    Text(event.title)
                        .font(.headline)
                    
                    if let description = event.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onRSVP) {
                    Image(systemName: isRSVPd ? "star.fill" : "star")
                        .foregroundStyle(isRSVPd ? .yellow : .secondary)
                }
            }
            
            HStack(spacing: 16) {
                Label(formatEventDate(event.startDate), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let location = event.location {
                    Label(location, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: onAddToCalendar) {
                    Label("Add", systemImage: "calendar.badge.plus")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(guideColor)
                .controlSize(.small)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func formatEventDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, h:mm a"
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

private struct LocationRow: View {
    let location: GuideLocation
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: location.icon ?? location.category?.icon ?? "mappin")
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let address = location.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                openInMaps(location)
            } label: {
                Image(systemName: "arrow.triangle.turn.up.right.diamond")
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func openInMaps(_ location: GuideLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        mapItem.openInMaps()
    }
}

private struct FAQRow: View {
    let faq: GuideFAQ
    let isExpanded: Bool
    let guideColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: isExpanded ? 12 : 0) {
                HStack {
                    Text(faq.question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                
                if isExpanded {
                    Text(faq.answer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

private struct LinkRow: View {
    let link: GuideLink
    let guideColor: Color
    
    var body: some View {
        if let url = URL(string: link.url) {
            Link(destination: url) {
                HStack(spacing: 12) {
                    Image(systemName: link.icon ?? "link")
                        .font(.title3)
                        .foregroundStyle(guideColor)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(link.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        if let description = link.description {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
    }
}

private struct ContactRow: View {
    let contact: GuideContact
    let guideColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let role = contact.role {
                        Text(role)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                if let phone = contact.phone, let url = URL(string: "tel:\(phone)") {
                    Link(destination: url) {
                        Label(phone, systemImage: "phone.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(guideColor)
                    .controlSize(.small)
                }
                
                if let email = contact.email, let url = URL(string: "mailto:\(email)") {
                    Link(destination: url) {
                        Label("Email", systemImage: "envelope.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(guideColor)
                    .controlSize(.small)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

private struct UpdateRow: View {
    let update: GuideUpdate
    
    private var color: Color {
        switch update.type {
        case .info: return .blue
        case .change: return .orange
        case .urgent: return .red
        case .cancellation: return .gray
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: update.type.icon)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(update.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(update.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(formatTimestamp(update.timestamp))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, yyyy"
            return displayFormatter.string(from: date)
        }
        return timestamp
    }
}



#Preview {
    NavigationStack {
        GuideDetailView(
            guide: Guide(
                id: "preview",
                title: "Wolfpack Welcome Week",
                department: "Student Affairs",
                description: "Your complete guide to Welcome Week!",
                headerImageUrl: "https://live.staticflickr.com/65535/52520075268_8e6b3e0b6e_k.jpg",
                icon: "party.popper.fill",
                color: "red",
                visibility: .all,
                featured: true,
                alert: GuideAlert(type: .new, message: "Starts Aug 14!"),
                sections: [
                    GuideSection(id: "s1", title: "What to Bring", order: 1, content: "Pack light! Essentials: phone, student ID, water bottle.")
                ],
                events: [
                    GuideEvent(id: "e1", title: "Opening Ceremony", description: "Welcome from leadership", category: .orientation, startDate: "2025-08-14T10:00:00", endDate: "2025-08-14T11:30:00", location: "Reynolds Coliseum", locationId: nil, isRequired: true)
                ],
                locations: [
                    GuideLocation(id: "l1", name: "Reynolds Coliseum", description: "Historic arena", latitude: 35.787, longitude: -78.6698, address: "2411 Dunn Ave", category: .venue, icon: nil)
                ],
                todos: [
                    GuideTodo(id: "t1", title: "Pick up Wolfpack One Card", description: "Required for dining and events", dueDate: "Aug 14", priority: .high, category: "Before Arrival", linkedUrl: nil),
                    GuideTodo(id: "t2", title: "Download TransLoc app", description: nil, dueDate: nil, priority: .medium, category: "Before Arrival", linkedUrl: nil)
                ],
                faqs: [
                    GuideFAQ(id: "f1", question: "What should I wear?", answer: "Wear red and white to show Wolfpack spirit!", category: nil)
                ],
                contacts: [
                    GuideContact(id: "c1", name: "New Student Programs", role: "Welcome Week", phone: "919-515-1234", email: "newstudents@ncsu.edu")
                ],
                links: [
                    GuideLink(id: "l1", title: "Welcome Week Schedule", url: "https://newstudents.ncsu.edu", icon: "calendar", description: "Full day-by-day schedule")
                ],
                updates: nil
            )
        )
    }
    .environment(UserSettings())
}

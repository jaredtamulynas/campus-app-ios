//
//  FirebaseService.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/5/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

// MARK: - Firebase Service

/// Centralized Firebase service for Realtime Database and Firestore operations
enum FirebaseService {
    
    // MARK: - Database References
    
    static let firestore = Firestore.firestore()
    static let realtime = Database.database().reference()
    
    // MARK: - Authentication
    
    /// Sign in anonymously for users who don't need accounts
    static func signInAnonymously() async throws -> User {
        let result = try await Auth.auth().signInAnonymously()
        return result.user
    }
    
    /// Get current authenticated user
    static var currentUser: User? {
        Auth.auth().currentUser
    }
    
    // MARK: - Realtime Database Observers
    
    /// Observe a realtime database path and decode to a Codable type
    static func observe<T: Decodable>(
        path: String,
        onUpdate: @escaping (T) -> Void,
        onError: @escaping (Error) -> Void
    ) -> DatabaseHandle {
        realtime.child(path).observe(.value) { snapshot in
            guard let value = snapshot.value else {
                onError(FirebaseError.noData(path: path))
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let decoded = try JSONDecoder().decode(T.self, from: data)
                onUpdate(decoded)
            } catch {
                onError(FirebaseError.decodingFailed(path: path, underlying: error))
            }
        } withCancel: { error in
            onError(error)
        }
    }
    
    /// Observe a realtime database path with manual parsing
    static func observeRaw(
        path: String,
        onUpdate: @escaping ([String: Any]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> DatabaseHandle {
        realtime.child(path).observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                onError(FirebaseError.noData(path: path))
                return
            }
            onUpdate(value)
        } withCancel: { error in
            onError(error)
        }
    }
    
    /// Remove a realtime database observer
    static func removeObserver(_ handle: DatabaseHandle, path: String) {
        realtime.child(path).removeObserver(withHandle: handle)
    }
    
    // MARK: - Firestore Operations
    
    /// Fetch a single document and decode to a Codable type
    static func fetchDocument<T: Decodable>(
        collection: String,
        documentId: String
    ) async throws -> T {
        let snapshot = try await firestore.collection(collection).document(documentId).getDocument()
        
        guard let data = snapshot.data() else {
            throw FirebaseError.documentNotFound(collection: collection, documentId: documentId)
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
    
    /// Fetch all documents in a collection
    static func fetchCollection<T: Decodable>(
        collection: String
    ) async throws -> [T] {
        let snapshot = try await firestore.collection(collection).getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: document.data()) else {
                return nil
            }
            return try? JSONDecoder().decode(T.self, from: jsonData)
        }
    }
    
    /// Listen to a Firestore document for real-time updates
    static func listenToDocument<T: Decodable>(
        collection: String,
        documentId: String,
        onUpdate: @escaping (T) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        firestore.collection(collection).document(documentId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    onError(FirebaseError.documentNotFound(collection: collection, documentId: documentId))
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let decoded = try JSONDecoder().decode(T.self, from: jsonData)
                    onUpdate(decoded)
                } catch {
                    onError(FirebaseError.decodingFailed(path: "\(collection)/\(documentId)", underlying: error))
                }
            }
    }
}

// MARK: - Firebase Errors

enum FirebaseError: LocalizedError {
    case noData(path: String)
    case documentNotFound(collection: String, documentId: String)
    case decodingFailed(path: String, underlying: Error)
    case authenticationRequired
    
    var errorDescription: String? {
        switch self {
        case .noData(let path):
            return "No data found at path: \(path)"
        case .documentNotFound(let collection, let documentId):
            return "Document not found: \(collection)/\(documentId)"
        case .decodingFailed(let path, let underlying):
            return "Failed to decode data at \(path): \(underlying.localizedDescription)"
        case .authenticationRequired:
            return "Authentication required"
        }
    }
}


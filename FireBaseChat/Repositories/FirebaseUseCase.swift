//
//  FirebaseRepository.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 08..
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import class RxSwift.PublishSubject

enum FirebaseFilter {
    case isLessThan(fieldName: String, value: Any)
    case isLessThanOrEqual(fieldName: String, value: Any)
    case isEqual(fieldName: String, value: Any)
    case isGreaterThan(fieldName: String, value: Any)
    case isGreaterThanOrEqual(fieldName: String, value: Any)
    case isNotEqual(fieldName: String, value: Any)
    case arrayContains(fieldName: String, value: Any)
    case arrayContainsAny(fieldName: String, value: [Any])
    case isIn(fieldName: String, value: [Any])
    case notIn(fieldName: String, value: [Any])
}

protocol FirebaseUseCase {
    associatedtype Data: Codable
    
    var collectionName: String { get }
    var db: Firestore { get }
    
    func add(data: Data)
    func listenChanges(dataSubject: PublishSubject<[Data]>, orderBy field: String?, descending: Bool, where filter: FirebaseFilter?, limit: Int?)
}

extension FirebaseUseCase {
    var db: Firestore { Firestore.firestore() }
    
    func add(data: Data) {
        do {
            try db.collection(collectionName).document().setData(from: data)
        } catch let error {
            print("Error writing \(collectionName) to Firestore: \(error)")
        }
    }
    
    func listenChanges(dataSubject: PublishSubject<[Data]>, orderBy field: String? = nil, descending: Bool = false, where filter: FirebaseFilter?, limit: Int? = nil) {
        var query: Query = db.collection(collectionName)
        
        if let field = field {
            query = query.order(by: field, descending: descending)
        }
        
        if let filter = filter {
            switch filter {
            case let .isLessThan(fieldName, value):
                query = query.whereField(fieldName, isLessThan: value)
            case let .isLessThanOrEqual(fieldName, value):
                query = query.whereField(fieldName, isLessThanOrEqualTo: value)
            case let .isEqual(fieldName, value):
                query = query.whereField(fieldName, isEqualTo: value)
            case let .isGreaterThan(fieldName, value):
                query = query.whereField(fieldName, isGreaterThan: value)
            case let .isGreaterThanOrEqual(fieldName, value):
                query = query.whereField(fieldName, isGreaterThanOrEqualTo: value)
            case let .isNotEqual(fieldName, value):
                query = query.whereField(fieldName, isNotEqualTo: value)
            case let .arrayContains(fieldName, value):
                query = query.whereField(fieldName, arrayContains: value)
            case let .arrayContainsAny(fieldName, value):
                query = query.whereField(fieldName, arrayContainsAny: value)
            case let .isIn(fieldName, value):
                query = query.whereField(fieldName, in: value)
            case let .notIn(fieldName, value):
                query = query.whereField(fieldName, notIn: value)
            }
        }
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        _listenChanges(query: query, dataSubject: dataSubject)
    }
    
    private func _listenChanges(query: Query, dataSubject: PublishSubject<[Data]>) {
        query.addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    fatalError("There was an issue while retrieving data \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    let datas = documents.compactMap { document -> Data? in
                        try? document.data(as: Data.self)
                    }
                    dataSubject.onNext(datas)
                }
            }
    }
}

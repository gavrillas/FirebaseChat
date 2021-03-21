//
//  UserRepository.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 09..
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import class RxSwift.BehaviorSubject
import class RxSwift.PublishSubject

enum AuthResult {
    case success
    case error(message: String)
}

protocol UserUseCase {
    var currentUser: BehaviorSubject<User?> { get }
    
    func register(email: String, password: String, result: PublishSubject<AuthResult>)
    func logIn(email: String, password: String, result: PublishSubject<AuthResult>)
    func logOut()
    func update(user: User) -> Bool
    func searchUsers(email: String, result: BehaviorSubject<[User]>)
}

struct UserRepository: UserUseCase, FirebaseUseCase {
    typealias Data = User
    let collectionName = "users"
    
    var currentUser = BehaviorSubject<User?>(value: nil)
    
    func register(email: String, password: String, result: PublishSubject<AuthResult>) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                result.onNext(.error(message: error.localizedDescription))
            } else {
                result.onNext(.success)
                let user = User(email: email, nickname: nil, age: nil, picture: nil)
                add(data: user)
                _findByEmail(email: email, user: currentUser)
            }
        }
    }
    
    func logIn(email: String, password: String, result: PublishSubject<AuthResult>) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                result.onNext(.error(message: error.localizedDescription))
            } else {
                result.onNext(.success)
                _findByEmail(email: email, user: currentUser)
            }
        }
    }
    
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            currentUser.onNext(nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    private func _findByEmail(email: String, user: BehaviorSubject<User?>) {
        db.collection(collectionName)
            .whereField("email", isEqualTo: email)
            .getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else { return }
                let datas = documents.map { document in
                    try? document.data(as: User.self)
                }
                user.onNext(datas.first ?? nil)
            }
    }
    
    func searchUsers(email: String, result: BehaviorSubject<[User]>) {
        db.collection(collectionName)
            .order(by: "email")
            .start(at: [email])
            .end(at: [(email + "\u{f8ff}")])
            .getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else { return }
                let datas = documents.compactMap { document in
                    try? document.data(as: User.self)
                }
                result.onNext(datas)
            }
    }
    
    func update(user: User) -> Bool {
        guard let id = user.id else { return false }
        do {
            try db.collection(collectionName).document(id).setData(from: user)
            currentUser.onNext(user)
            return true
        }
        catch {
            print(error)
            return false
        }
    }
}

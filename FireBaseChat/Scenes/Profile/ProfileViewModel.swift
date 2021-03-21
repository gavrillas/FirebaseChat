//
//  ProfileViewModel.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 10..
//

import RxSwift
import RxSwiftExt
import struct RxCocoa.Driver
import Firebase
import class RxCocoa.BehaviorRelay

struct ProfileViewModel {
    
    struct Input {
        let logOut: Observable<Void>
        let edit: Observable<Bool>
        let nickname: Observable<String?>
        let age: Observable<Int?>
        let saveChanges: Observable<Bool>
        let cancelChanges: Observable<Bool>
    }
    
    struct Output {
        let user: Driver<User?>
        let editing: Driver<Bool>
        let logOut: Driver<Void>
        let saved: Driver<Bool>
    }
    
    private let _userUseCase: UserUseCase
    private let storage = Firebase.Storage.storage()
    
    init(userUseCase: UserUseCase) {
        _userUseCase = userUseCase
    }
    
    public func transform(input: Input) -> Output {
        let user = _userUseCase.currentUser.asDriver(onErrorJustReturn: nil)
        
        let editing = Observable.merge(input.edit,
                                       input.saveChanges,
                                       input.cancelChanges)
            .asDriver(onErrorJustReturn: false)
        
        let updatedUser = Observable.combineLatest(input.nickname,
                                               input.age,
                                               _userUseCase.currentUser.unwrap())
            .map { nickname, age, savedUser in
                User(id: savedUser.id,
                     email: savedUser.email,
                     nickname: nickname,
                     age: age,
                     picture: nil)
            }
        
        let saved = input.saveChanges
            .withLatestFrom(updatedUser)
            .map { user in
                _userUseCase.update(user: user)
            }.asDriver(onErrorJustReturn: false)
        
        let logOut = input.logOut.map {
            self._userUseCase.logOut()
        }.asDriver(onErrorJustReturn: ())
        
        return Output(user: user,
                      editing: editing,
                      logOut: logOut,
                      saved: saved)
    }
}

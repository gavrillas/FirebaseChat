//
//  LogInViewModel.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 06..
//

import Firebase
import RxSwift
import struct RxCocoa.Driver

struct LogInViewModel {
    struct Input {
        let buttonTrigger: Observable<Void>
        let email: Observable<String>
        let password: Observable<String>
    }
    
    struct Output{
        let login: Driver<Bool>
        let result: Driver<AuthResult>
        let user: Driver<User?>
    }
    
    private let _isNewUser: Bool
    private let _result = PublishSubject<AuthResult>()
    private let _userUseCase: UserUseCase
    
    init(isNewUser: Bool, userUseCase: UserUseCase) {
        _isNewUser = isNewUser
        _userUseCase = userUseCase
    }
    
    public func transform(input: Input) -> Output {
        let login = input.buttonTrigger.withLatestFrom(
                Observable.combineLatest(input.email,
                                         input.password))
            .map { email, password in
                if !email.isEmpty && !password.isEmpty {
                    if _isNewUser {
                        _userUseCase.register(email: email, password: password, result: _result)
                    } else {
                        _userUseCase.logIn(email: email, password: password, result: _result)
                    }
                } else {
                    self._result.onNext(.error(message:  "Email and/or password is missing"))
                }
                return !email.isEmpty && !password.isEmpty
            }.asDriver(onErrorJustReturn: false)
        
        let result = _result
            .asDriver(onErrorJustReturn: .error(message: "Something bad happened"))
        
        let user = _userUseCase.currentUser
            .asDriver(onErrorJustReturn: nil)
        
        return Output(login: login,
                      result: result,
                      user: user)
    }
}

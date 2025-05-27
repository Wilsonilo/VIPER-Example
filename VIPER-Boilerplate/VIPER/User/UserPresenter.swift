//
//  UserPresenter.swift
//  VIPER-Boilerplate
//
//  Created by Wilson Munoz on 23/05/25.
//

/// Object
/// Protocol
/// Reference to `Interactor`, `Router`, `View`
/// Has function to notify the view when

protocol AnyUserPresenter:AnyObject {
    
    var interactor:AnyUserInteractor? { get set }
    var router:AnyUserRouter? { get set }
    var view:AnyUserView? { get set }
    
    init(
        interactor: AnyUserInteractor?,
        router: AnyUserRouter?,
        view: AnyUserView?
    )
    
    func interactorDidFetchUsers(with result:Result<[UserEntity], Error>)

}

extension AnyUserPresenter {
    func interactorDidFetchUsers(with result:Result<[UserEntity], Error>) {
        switch result {
        case .success(let users):
            view?.update(with: users)
        case .failure(let error):
            view?.weGotErrorFetchingUsers(with: error)
        }
    }
}


class UserPresenter:AnyUserPresenter {
    
    var interactor:AnyUserInteractor?
    weak var router:AnyUserRouter?
    weak var view:AnyUserView?
    
    required init(
        interactor: AnyUserInteractor?,
        router: AnyUserRouter?,
        view: AnyUserView?
    ) {
        
        self.interactor = interactor
        self.router     = router
        self.view       = view
        
    }
}

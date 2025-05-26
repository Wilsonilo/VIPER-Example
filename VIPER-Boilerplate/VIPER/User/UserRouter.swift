//
//  UserRouter.swift
//  VIPER-Boilerplate
//
//  Created by Wilson Munoz on 23/05/25.
//

import UIKit

/// Start point, it is was delivers / reduces for our "module", in this case User
/// Object
/// Also follows protocol
/// Should have reference to the `View`
typealias EntryView = AnyUserView & UIViewController
protocol AnyUserRouter: AnyObject {
    var view:EntryView? { get set }
    static func start()->AnyUserRouter
}

class UserRouter:AnyUserRouter {
   var view: EntryView?

    /// Delivers a router that has inside all of the inits to the other parts
    /// VIP
    static func start() -> any AnyUserRouter {
        let router                       = UserRouter()
        let view:AnyUserView             = UserViewController()
        let interactor:AnyUserInteractor = UserInteractor()
        let presenter:AnyUserPresenter   = UserPresenter(
            interactor: interactor,
            router: router,
            view: view
        )
        
        /// Link 
        router.view                      = view as? EntryView
        interactor.presenter             = presenter
        view.presenter                   = presenter

        return router
    }
}

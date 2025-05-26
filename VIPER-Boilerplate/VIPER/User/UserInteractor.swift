//
//  UserInteractor.swift
//  VIPER-Boilerplate
//
//  Created by Wilson Munoz on 23/05/25.
//

import Foundation

/// Responsable for the business logic / example fetch data.
/// Should have a reference to the `Presenter`
/// so when the business logic finished we notify presenter
/// Uses a Protocol
/// Object
/// https:///jsonplaceholder.typicode.com/users

protocol AnyUserInteractor: AnyObject {
    var presenter:AnyUserPresenter? { get set }
    
    /// We don't have completion here because we want to tell the presenter
    /// that we have fetched the information and deliver that information
    /// to the presenter, the presenter then will inform the view
    func getUsers()->Void
}


enum UserInteractorError:Error {
    case failedFetching
    case invalidURL
}

class UserInteractor: AnyUserInteractor {
    var presenter: (any AnyUserPresenter)?
    private let urlSession: URLSession
    private let endpoint: String
    
    init(
        presenter: AnyUserPresenter? = nil,
        urlSession: URLSession = .shared,
        endpoint: String = "https://jsonplaceholder.typicode.com/users"
    ) {
        self.presenter = presenter
        self.urlSession = urlSession
        self.endpoint = endpoint
    }
    
    func getUsers() {
        guard let url = URL(string: endpoint) else {
            presenter?.interactorDidFetchUsers(with: .failure(UserInteractorError.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                self?.presenter?.interactorDidFetchUsers(with: .failure(UserInteractorError.failedFetching))
                return
            }
            
            do {
                let entities = try JSONDecoder().decode([UserEntity].self, from: data)
                self?.presenter?.interactorDidFetchUsers(with: .success(entities))
            } catch {
                self?.presenter?.interactorDidFetchUsers(with: .failure(error))
            }
        }
        task.resume()
    }
}

//
//  VIPER_UserTests.swift
//  VIPER-BoilerplateTests
//
//  Created by Wilson Munoz on 23/05/25.
//

import XCTest
@testable import VIPER_Boilerplate

/// Just simple tests, I need to clean this later, some unused code.
final class VIPER_UserTests: XCTestCase {

    // MARK: - View Tests
        
    func test_viewInit_givenNewInstance_thenHasEmptyErrorsAndUpdates() {
        let sut   = makeAnyUserViewSpySUT()
        XCTAssert(sut.capturedErrors.isEmpty)
        XCTAssert(sut.capturedUpdates.isEmpty)
    }
    
    func test_viewUpdate_givenUsers_thenCapturesUsersCorrectly() {
        let sut   = makeAnyUserViewSpySUT()
        let users = [makeAnyUserEntitySpySUT(entityName: "Jasmine")]
        
        sut.update(with: users)
        
        XCTAssertEqual(sut.capturedUpdates.count, 1)
        XCTAssertEqual(sut.capturedUpdates.first?.count, 1)
        XCTAssertEqual(sut.capturedUpdates.first?.first?.name, "Jasmine")
    }
    
    func test_viewError_givenError_thenCapturesError(){
        let sut   = makeAnyUserViewSpySUT()
       let error  = anyError()
       
       sut.weGotErrorFetchingUsers(with: error)
       
       XCTAssertEqual(sut.capturedErrors.count, 1)
       XCTAssertEqual(sut.capturedErrors.first as? NSError, error)
   }
    
    // MARK: - Interactor Tests

    /// Test success passing mock data
    func test_interactor_getUsers_success_notifiesPresenterWithUsers(){
        let (interactor, presenterSpy, mockURLSession) = makeAnyUserInteractorWithPresenter()
        
        /// Create the data
        guard let mockData = """
               [{"name": "John Doe"}, {"name": "Jane Smith"}]
               """.data(using: .utf8) else {
            XCTFail("Invalid mock data")
            return
        }
        
        /// Inject the data, response and no error
        mockURLSession.data     = mockData
        mockURLSession.response = HTTPURLResponse()
        mockURLSession.error    = nil
        
        /// Make the request
        /// Because we passing the mockURLSession, the data task will deliver our
        /// mock data, no error and the httpurl response
        interactor.getUsers()
        
        /// Check we have at least a result from the call
        XCTAssertEqual(presenterSpy.capturedResults.count, 1)
        
        
        /// Unwrap our captured result
        guard let firstResult =  presenterSpy.capturedResults.first else  {
            XCTFail("We should have at least one result.")
            return
        }
        
        /// Check we have success
        switch firstResult {
        case .success(let users):
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, "John Doe")
            XCTAssertEqual(users[1].name, "Jane Smith")
        case .failure:
            XCTFail("Expected success but got failure")
        }


    }
    
    /// Test we get our error
    func test_interactor_getUsers_networkError_notifiesPresenterWithError(){
        
        let (interactor, presenterSpy, mockURLSession) = makeAnyUserInteractorWithPresenter()
        
        /// Inject error, deliver no data
        mockURLSession.data = nil
        mockURLSession.error = anyError()
        
        /// Make the request
        /// Because we passing the mockURLSession, the data task will deliver our
        /// mock data, no error and the httpurl response
        interactor.getUsers()
        
        /// Check we have at least a result from the call
        XCTAssertEqual(presenterSpy.capturedResults.count, 1)
        
        /// Unwrap our captured result
        guard let firstResult =  presenterSpy.capturedResults.first else  {
            XCTFail("We should have at least one result.")
            return
        }
        
        /// Check we get our error
        switch firstResult {
        case .success(let success):
            XCTFail("We should have got error but got \(success)")
        case .failure(let error):
            XCTAssert(error is UserInteractorError)
            XCTAssertEqual(error as? UserInteractorError, .failedFetching)
        }
        
    }
    
    /// Test against decoding
    func test_interactor_getUsers_invalidJSON_notifiesPresenterWithError() {
        
        let (interactor, presenterSpy, mockURLSession) = makeAnyUserInteractorWithPresenter()
        
        /// Create the data
        guard let mockData = "invalid json".data(using: .utf8) else {
            XCTFail("Invalid mock data")
            return
        }
        
        /// Inject invalid data and check we get a decoding error.
        mockURLSession.data     = mockData
        mockURLSession.response = HTTPURLResponse()
        mockURLSession.error    = nil
        
        /// Make the request
        /// Because we passing the mockURLSession, the data task will deliver our
        /// mock data, no error and the httpurl response
        interactor.getUsers()
        
        /// Check we have at least a result from the call
        XCTAssertEqual(presenterSpy.capturedResults.count, 1)
        
        /// Unwrap our captured result
        guard let firstResult =  presenterSpy.capturedResults.first else  {
            XCTFail("We should have at least one result.")
            return
        }
        
        /// Check we get our error
        switch firstResult {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssert(error is DecodingError)
        }
    }
    
    // MARK: - Presenter Tests-
    
    func test_presenter_successResult_updatesView() {
        let viewSpy = AnyUserViewSpy()
        let presenter = UserPresenter(interactor: nil, router: nil, view: viewSpy)
        let users = [UserEntity(name: "Test User")]
        
        presenter.interactorDidFetchUsers(with: .success(users))
        
        XCTAssertEqual(viewSpy.capturedUpdates.count, 1)
        XCTAssertEqual(viewSpy.capturedUpdates.first?.count, 1)
        XCTAssertEqual(viewSpy.capturedUpdates.first?.first?.name, "Test User")
    }
    
    func test_presenter_failureResult_notifiesViewOfError() {
        let viewSpy = AnyUserViewSpy()
        let presenter = UserPresenter(interactor: nil, router: nil, view: viewSpy)
        let error = anyError()
        
        presenter.interactorDidFetchUsers(with: .failure(error))
        
        XCTAssertEqual(viewSpy.capturedErrors.count, 1)
        XCTAssertEqual(viewSpy.capturedErrors.first as? NSError, error)
    }

    // MARK: - Router -

    /// Router has nothing when init
    func test_router_init_hasNoInits(){
        let sut = UserRouter()
        XCTAssertNil(sut.view)
    }
    
    /// Router has a view when starts
    func test_router_init_hasViewOnStart(){
        let sut = UserRouter.start()
        XCTAssertNotNil(sut.view)
    }
    
    // MARK: - Helpers -
    private func anyError()->NSError {
        NSError(domain: "", code: 0)
    }
    
    private func makeAnyUserViewSpySUT()->AnyUserViewSpy {
        AnyUserViewSpy()
    }
    
    private func makeAnyUserInteractorSpySUT(endpoint:String = "https://jsonplaceholder.typicode.com/users")->(AnyUserInteractorSpy, MockURLSession) {
        let mockURLSession   = MockURLSession()
        return (AnyUserInteractorSpy(
            presenter: nil,
            urlSession: mockURLSession,
            endpoint: endpoint
        ), mockURLSession)
    }
    
    private func makeAnyUserPresenterSpySUT()->AnyUserPresenterSpy {
        AnyUserPresenterSpy()
    }
    
    private func makeAnyUserEntitySpySUT(entityName:String = "John")->AnyUserEntity {
        UserEntity(name: entityName)
    }
    
    private func makeAnyUserRouterSpySUT()->AnyUserRouterSpy {
        AnyUserRouterSpy()
    }
    
    private func makeAnyUserInteractorWithPresenter(endpoint:String = "https://jsonplaceholder.typicode.com/users")->(AnyUserInteractorSpy, AnyUserPresenterSpy, MockURLSession){
        let (interactorSpy, mockURLSession)       = makeAnyUserInteractorSpySUT(endpoint: endpoint)
        let presenterSpy        = AnyUserPresenterSpy()
        interactorSpy.presenter = presenterSpy
        return(interactorSpy, presenterSpy, mockURLSession)
    }
    
    

    
    // MARK: - Private SPY Classes -
    /// V is for Vendetta, I mean for View
    private class AnyUserViewSpy: AnyUserView {
        var presenter: (any AnyUserPresenter)?
        var capturedErrors = [Error]()
        var capturedUpdates = [[AnyUserEntity]]()
        
        func update(with users: [AnyUserEntity]) {
            capturedUpdates.append(users)
        }
        
        func weGotErrorFetchingUsers(with error: Error) {
            capturedErrors.append(error)
        }
    }
    
    /// I is for Interactor.
    private class AnyUserInteractorSpy: AnyUserInteractor {
        var urlSession: URLSessionProtocol
        var endpoint: String
        var presenter: (any AnyUserPresenter)?
        required init(
            presenter: (any AnyUserPresenter)? = nil,
            urlSession: URLSessionProtocol  = URLSession.withStandardConfiguration(),
            endpoint: String = "https://jsonplaceholder.typicode.com/users"
        ) {
            self.presenter  = presenter
            self.urlSession = urlSession
            self.endpoint   = endpoint
        }
    }
    
    /// P is for Presenter
    private class AnyUserPresenterSpy: AnyUserPresenter {
        var interactor: (any AnyUserInteractor)?
        var router: (any AnyUserRouter)?
        var view: (any AnyUserView)?
        var capturedResults = [Result<[UserEntity], Error>]()
        
        required init(
            interactor: (any AnyUserInteractor)? = nil,
            router: (any AnyUserRouter)? = nil,
            view: (any AnyUserView)? = nil
        ) {
            self.interactor = interactor
            self.router = router
            self.view = view
        }
        
        func interactorDidFetchUsers(with result: Result<[UserEntity], Error>) {
            capturedResults.append(result)
        }
    }
    
    /// We don't do E for entity, is just an struct
    
    /// R is for Router
    private class AnyUserRouterSpy: AnyUserRouter {
        var view: (any EntryView)?
        
        static func start() -> any AnyUserRouter {
            let router = AnyUserRouterSpy()
            let view: AnyUserView = AnyUserViewSpy()
            
            let interactor: AnyUserInteractor = AnyUserInteractorSpy()
            let presenter: AnyUserPresenter = AnyUserPresenterSpy(
                interactor: interactor,
                router: router,
                view: view
            )
            
            router.view = view as? EntryView
            interactor.presenter = presenter
            view.presenter = presenter
            
            return router
        }
    }
    
    // MARK: - Mock Classes -

    /// Mock a URL Session Data task that we can inject errors, responses and data.
    class MockURLSession: URLSessionProtocol {
    
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> any URLSessionDataTaskProtocol {
            return MockURLSessionDataTask {
                completionHandler(self.data, self.response, self.error)
            }
        }
    }

    ///In our mock, we need to simulate a network call without making a real network request.
    ///So we init we a closure, capture it and return it with resume.
    class MockURLSessionDataTask: URLSessionDataTaskProtocol {
        private let closure: () -> Void
        
        init(closure: @escaping () -> Void) {
            self.closure = closure
        }
        
        func resume() {
            closure()
        }
    }
    
    
}

//
//  RXPostListViewControllerTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 03/03/2019.
//  Copyright © 2019 GMJT. All rights reserved.
//

import UIKit
import XCTest
import RxSwift
import RxTest
import RxCocoa
import RxBlocking

@testable import Demo

class PostListViewControllerTests: XCTestCase {
    
    var sut: PostListViewController!
    let testViewModel: PostViewModel = {
       let viewModel = PostViewModel()
        viewModel.data = Observable.just(ModelStubs.posts).asDriver(onErrorJustReturn: [])
        return viewModel
    }()
    
    private func createPostListViewController() -> PostListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostListViewController") as! PostListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    override func setUp() {
        sut = createPostListViewController()
       UIApplication.shared.keyWindow?.rootViewController = sut
    }
    
    private func setViewModel(_ viewModel: PostViewModel) {
        sut.viewModel = viewModel
        sut.loadViewIfNeeded()
    }
    
    func testViewModelAlertEvent_DisplaysAlert() {
        setViewModel(PostViewModel())
        sut.viewModel.alerts.onNext(Alert(title: "Test", message: "Alert"))
        
        let alertController: UIAlertController? = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(alertController)
    }
    
    func testViewModelData_BoundToTableView() {
        setViewModel(testViewModel)
        let cell = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PostCell
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.titleLabel.text, ModelStubs.posts[0].title)
}
    
    func testSelectingRow_SeguesToCorrespondingDetailViewController() {
        setViewModel(testViewModel)
        sut.tableView.delegate!.tableView!(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        guard let detailViewController = sut.presentedViewController?.contents as? PostDetailViewController else {
            return XCTFail()
        }
        XCTAssertEqual(detailViewController.post, ModelStubs.posts[0])
    }
}



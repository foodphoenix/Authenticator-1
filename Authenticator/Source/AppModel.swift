//
//  AppModel.swift
//  Authenticator
//
//  Copyright (c) 2015 Authenticator authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

class AppModel {
    /*private*/ lazy var tokenList: TokenList = {
        TokenList(actionHandler: self)
    }()

    private var modalState: ModalState {
        didSet {
            print(modalState)
            switch modalState {
            case .None:
                dismissViewController()

            case .EntryScanner:
                let scannerViewController = TokenScannerViewController(actionHandler: self)
                presentViewController(scannerViewController)

            case .EntryForm(let form):
                let formController = TokenFormViewController(form: form)
                presentViewController(formController)

            case .EditForm(let form):
                let editController = TokenFormViewController(form: form)
                presentViewController(editController)
            }

        }
    }

    private enum ModalState {
        case None
        case EntryScanner
        case EntryForm(TokenEntryForm)
        case EditForm(TokenEditForm)
    }

    let window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
        modalState = .None
    }

    var viewModel: AppViewModel {
        return AppViewModel(
            tokenList: tokenList
        )
    }
}

extension AppModel: ActionHandler {
    func handleAction(action: AppAction) {
        switch action {
        case .BeginTokenEntry:
            if QRScanner.deviceCanScan {
                modalState = .EntryScanner
            } else {
                let form = TokenEntryForm(actionHandler: self)
                modalState = .EntryForm(form)
            }

        case .SaveNewToken(let token):
            tokenList.addToken(token)
            modalState = .None

        case .CancelTokenEntry:
            modalState = .None

        case .BeginTokenEdit(let persistentToken):
            let form = TokenEditForm(persistentToken: persistentToken, actionHandler: self)
            modalState = .EditForm(form)

        case let .SaveChanges(token, persistentToken):
            tokenList.saveToken(token, toPersistentToken: persistentToken)
            modalState = .None

        case .CancelTokenEdit:
            modalState = .None
        }
    }

    private func presentViewController(viewController: UIViewController) {
        let navController = OpaqueNavigationController(rootViewController: viewController)
        window?.rootViewController?
            .presentViewController(navController, animated: true, completion: nil)
    }

    private func dismissViewController() {
        window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

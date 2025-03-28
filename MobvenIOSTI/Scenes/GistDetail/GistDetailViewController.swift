//
//  GistDetailViewController.swift
//  MobvenIOSTI
//
//  Created by Burak Yılmaz on 9.09.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import UIKit
import SDWebImage

protocol GistDetailDisplayLogic: class {
    func displayGistDetail(viewModel: GistDetail.FetchDetail.ViewModel)
    func displayFavoriteUpdate(viewModel: GistDetail.UpdateFavorite.ViewModel)
}

final class GistDetailViewController: UIViewController {
    
    var interactor: GistDetailBusinessLogic?
    var router: (GistDetailRoutingLogic & GistDetailDataPassing)?
    var parentNavigationController: UINavigationController?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = GistDetailInteractor()
        let presenter = GistDetailPresenter()
        let router = GistDetailRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlButton.titleLabel?.numberOfLines = 0
        urlButton.titleLabel?.lineBreakMode = .byCharWrapping
        interactor?.fetchGistDetail(request: GistDetail.FetchDetail.Request())
        interactor?.updateFavorite(request: GistDetail.UpdateFavorite.Request(toggle: false))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        router?.updateFavoriteRouting()
    }
    
    @IBAction func selectURL() {
        let controller: SFSafariViewController = storyboard!.instantiateViewController()
        controller.targetUrl = urlButton.titleLabel?.text ?? ""
        parentNavigationController?.pushViewController(controller, animated: true)
    }
}

extension GistDetailViewController: GistDetailDisplayLogic {
    
    func displayGistDetail(viewModel: GistDetail.FetchDetail.ViewModel) {
        imageView.sd_setImage(with: URL(string: viewModel.imageURL))
        idLabel.text = viewModel.id
        urlButton.setTitle(viewModel.url, for: .normal)
        dateLabel.text = viewModel.date
        descriptionLabel.text = viewModel.description
        commentsLabel.text = viewModel.comments
    }
    
    func displayFavoriteUpdate(viewModel: GistDetail.UpdateFavorite.ViewModel) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: viewModel.image, style: .plain,
            target: self, action: #selector(toggleFavorite)
        )
    }
    
    @objc func toggleFavorite() {
        interactor?.updateFavorite(request: GistDetail.UpdateFavorite.Request(toggle: true))
    }
    
}

protocol GistDetailFavoriteDelegate {
    func gistDetailFavoriteUpdatedGist(_ gist: Gist)
}

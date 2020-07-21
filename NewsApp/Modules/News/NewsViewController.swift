//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/23/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class NewsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newsTableView: UITableView! {
        didSet {
            newsTableView.register(UINib(nibName: "NewCell", bundle: nil), forCellReuseIdentifier: "NewCell")
            newsTableView.register(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
            newsTableView.delegate = self
            newsTableView.dataSource = self
            newsTableView.reloadData()
        }
    }
    
    // MARK: Properties
    let searchBar = UISearchBar()
    var viewMode: ViewMode = .search
    let disposeBag = DisposeBag()
    var sectionViewModel: SectionsViewModelProtocol?
    var searchViewModel: SearchViewModelProtocol?
    
    // MARK: UIViewController Events
    override func viewDidLoad() {
        super.viewDidLoad()
        switch viewMode {
            case .search:
                setupSearchBar()
                searchViewModel = SearchViewModel()
                bind(to: searchViewModel!)
            case .artsStories:
                navigationItem.title = SectionValues.art
                sectionViewModel = SectionsViewModel(section: .artsStories)
                bind(to: sectionViewModel!)
            case .sportsStories:
                navigationItem.title = SectionValues.sports
                sectionViewModel = SectionsViewModel(section: .sportsStories)
                bind(to: sectionViewModel!)
            case .scienceStories:
                navigationItem.title = SectionValues.science
                sectionViewModel = SectionsViewModel(section: .scienceStories)
                bind(to: sectionViewModel!)
        }
    }
    
    // MARK: Binding with SearchViewModel
    private func bind(to viewModel: SearchViewModelProtocol) {
        // Articles
        viewModel.articles
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.newsTableView.reloadData() })
            .disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading
            .asDriver()
            .drive(onNext: { [weak self] loading in
                guard let `self` = self else { return }
                self.activityIndicator.isHidden = !loading
                if self.activityIndicator.isHidden == false {
                    self.activityIndicator.startAnimating()
                }  })
            .disposed(by: disposeBag)
        
        // Error
        viewModel.error
            .asDriver(onErrorJustReturn: "Error")
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                self.showErrorAlert(title: "Error", message: error) })
            .disposed(by: disposeBag)
    }
    
    // MARK: Binding with SectionsViewModel
    private func bind(to viewModel: SectionsViewModelProtocol) {
        // Stroies
        viewModel.stories
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.newsTableView.reloadData() })
            .disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading
            .asDriver()
            .drive(onNext: { [weak self] loading in
                guard let `self` = self else { return }
                self.activityIndicator.isHidden = !loading
                if self.activityIndicator.isHidden == false {
                    self.activityIndicator.startAnimating()
                }  })
            .disposed(by: disposeBag)
        
        // Error
        viewModel.error
            .asDriver(onErrorJustReturn: "Error")
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                self.showErrorAlert(title: "Error", message: error) })
            .disposed(by: disposeBag)
    }
    
    
    private func setupSearchBar() {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.tintColor = .black
        searchBar.searchTextField.becomeFirstResponder()
        searchBar.placeholder = "Search articale"
        searchBar.tintColor = .black
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        navigationItem.titleView = searchBar
    }
    

}

// MARK: UITableViewDelegate, UITableViewDataSource
extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if viewMode == .search {
                return searchViewModel?.articles.value.count ?? 0
            } else {
                return sectionViewModel?.stories.value.count ?? 0
            }
        } else if section == 1, searchViewModel?.isLoadingMore ?? false == true {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard var cell = tableView.dequeueReusableCell(withIdentifier: "NewCell", for: indexPath) as? NewCell else {
                return UITableViewCell()
            }
            setupNewCell(cell: &cell, index: indexPath.row, viewMode: viewMode)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as? LoadingCell else {
                return UITableViewCell()
            }
            cell.activityIndicator.startAnimating()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        guard let webViewVC = R.storyboard.main.webView() else {return}
        if viewMode == .search, let articles = searchViewModel?.articles.value,
            let stringURL = articles[indexPath.row].web_url {
            webViewVC.stringURL = stringURL
        } else if let stories = sectionViewModel?.stories.value {
            webViewVC.stringURL = stories[indexPath.row].url
        }
        navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            if !(searchViewModel?.isLoadingMore ?? true), !(searchViewModel?.articles.value.isEmpty ?? true) {
                searchViewModel?.loadMoreActicles()
                newsTableView.reloadSections(IndexSet(integer: 1), with: .none)
            }
        }
    }
    
    private func setupNewCell(cell: inout NewCell, index: Int, viewMode: ViewMode) {
        if viewMode == .search, let articles = searchViewModel?.articles.value {
            let article: Article = articles[index]
            cell.picture.kf.indicatorType = .activity
            cell.picture.kf.setImage(with: article.imageURL, placeholder: R.image.placeholder1(), options: [.cacheOriginalImage])
            cell.title.text = article.headline?.main
            cell.des.text = article.abstract
            cell.organization.text = article.source
        } else if let stories = sectionViewModel?.stories.value {
            let story: TopArticle = stories[index]
            cell.picture.kf.indicatorType = .activity
            cell.picture.kf.setImage(with: story.imageURL, placeholder: R.image.placeholder1(), options: [.cacheOriginalImage])
            cell.title.text = story.title
            cell.des.text = story.abstract
            cell.organization.text = story.org_facet.first
        }
    }
}

// MARK: UISearchBarDelegate
extension NewsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            searchViewModel?.searchActicles(q: text)
        }
        searchBar.endEditing(true)
    }
}

// MARK: enum ViewMode for display articals by search or stories by topics
enum ViewMode {
    case search
    case artsStories
    case sportsStories
    case scienceStories
}

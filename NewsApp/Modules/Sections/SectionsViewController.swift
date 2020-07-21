//
//  SectionViewController.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/24/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift


class SectionsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topStoriesCollectionView: UICollectionView! {
        didSet {
            topStoriesCollectionView.delegate = self
            topStoriesCollectionView.dataSource = self
            topStoriesCollectionView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var sectionsTableView: UITableView!
    
    // MARK: Properties
    private let searchBar = UISearchBar()
    private let refreshControl = UIRefreshControl()
    private let disposeBag = DisposeBag()
    private let viewModel: SectionsViewModelProtocol = SectionsViewModel(section: .homeStories) // Inital viewModel with home stories

    // MARK: UIViewController Events
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.bind(to: self.viewModel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.refreshControl?.endRefreshing()
        activityIndicator.stopAnimating()
    }
    
    // MARK: Data binding
    private func bind(to viewModel: SectionsViewModelProtocol) {
        // Stroies
        viewModel.stories
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.topStoriesCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading
            .asDriver()
            .drive(onNext: { [weak self] loading in
                guard let `self` = self else { return }
                if loading == true {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }})
            .disposed(by: disposeBag)
        
        // Refreshing
        viewModel.isRefreshing
            .asDriver()
            .filter {$0 == false}
            .drive(onNext: { [weak self] loading in
                guard let `self` = self else { return }
                self.scrollView.refreshControl?.endRefreshing()
                })
            .disposed(by: disposeBag)
        
        // Error
        viewModel.error
            .asDriver(onErrorJustReturn: "Error")
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                self.showErrorAlert(title: "Error", message: error) })
            .disposed(by: disposeBag)
    }
    

    
    private func setupUI() {
        searchBar.delegate = self
        searchBar.placeholder = "Search articale"
        searchBar.tintColor = .black
        navigationItem.titleView = searchBar
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action:
                                           #selector(handleRefreshControl),
                                           for: .valueChanged)
    }
    
    // MARK: Actions
    @objc func handleRefreshControl() {
        viewModel.refreshStories(section: .homeStories)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource of sections
extension SectionsViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath)  as? SectionCell else {
                return UITableViewCell()
            }
            switch indexPath.row {
            case 0:
                cell.title.text = SectionValues.art
                cell.picture.image = R.image.arts()
            case 1:
                cell.title.text = SectionValues.sports
                cell.picture.image = R.image.sports()
            case 2:
                cell.title.text = SectionValues.science
                cell.picture.image = R.image.science()
            default:
                break
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return SectionValues.count
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.cellForRow(at: indexPath)?.selectionStyle = .none
            guard let newsVC = R.storyboard.main.newsViewController() else {return}
            switch indexPath.row {
            case 0: newsVC.viewMode = .artsStories
            case 1: newsVC.viewMode = .sportsStories
            case 2: newsVC.viewMode = .scienceStories
            default:
                break
            }
            navigationController?.pushViewController(newsVC, animated: true)
        }
    }

// MARK: UICollectionViewDelegate, UICollectionViewDataSource of stories
extension SectionsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.stories.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCollectionCell", for: indexPath) as? NewCollectionCell else {  return UICollectionViewCell()  }
        setupNewCollectionCell(cell: &cell, index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let stringURL = self.viewModel.stories.value[indexPath.row].url
        guard let webViewVC = R.storyboard.main.webView() else {return}
        webViewVC.stringURL = stringURL
        
        navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    private func setupNewCollectionCell(cell: inout NewCollectionCell, index: Int) {
        let story: TopArticle = self.viewModel.stories.value[index]
        cell.picture.kf.indicatorType = .activity
        cell.picture.kf.setImage(with: story.imageURL, placeholder: R.image.placeholder1(), options: [.cacheOriginalImage])
        cell.title.text = story.title
        cell.organization.text = story.org_facet.first
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension SectionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 310, height: 280)
    }
}


// MARK: UISearchBarDelegate for search a news
extension SectionsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard let newsVC = R.storyboard.main.newsViewController() else {return}
        newsVC.viewMode = .search
        searchBar.endEditing(true)
        navigationController?.pushViewController(newsVC, animated: false)
    }
}

// MARK: Extension UIViewController
extension UIViewController {
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}

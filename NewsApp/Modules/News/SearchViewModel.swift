//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/23/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol SearchViewModelProtocol {
    
    var articles: BehaviorRelay<[Article]> {  get set }
    var isLoading: BehaviorRelay<Bool> {  get set }
    var isLoadingMore: Bool {  get set }
    var error: PublishRelay<String> {  get set }
    
    func searchActicles(q: String)
    func loadMoreActicles()
    func clearAllModel()
}

final class SearchViewModel: SearchViewModelProtocol {
    
    var articles: BehaviorRelay<[Article]>
    var isLoading: BehaviorRelay<Bool>
    var isLoadingMore: Bool
    var error: PublishRelay<String>
    
    
    private let newsService = NewsService()
    private var disposeBag = DisposeBag()
    
    private var loadedPages: Int?
    private var totalHits: Int? // Total articles by query
    private var currentQuery: String?
    
    init() {
        self.articles = BehaviorRelay<[Article]>(value: [])
        self.isLoading = BehaviorRelay<Bool>(value: false)
        self.isLoadingMore = false
        self.error = PublishRelay<String>()
    }
    
    // MARK: Loading articles by new query
    func searchActicles(q: String) {
        self.clearAllModel()
        self.isLoading.accept(true)
        newsService.searchArticles(q: q).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else { return }
            if response.status ?? "" == "OK", let articles = response.response?.docs {
                let offset = (response.response?.meta?.offset) ?? 0
                let currenctPage = Int(offset / 10)
                self.loadedPages = currenctPage
                self.currentQuery = q
                self.totalHits = response.response?.meta?.hits ?? 0
                self.articles.accept(articles)
            } else {
                self.error.accept("Incorrect data")
            }
            self.isLoading.accept(false)
        }, onError: { [weak self] (error) in
            guard let `self` = self else { return }
            self.error.accept(error.localizedDescription)
            self.isLoading.accept(false)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Loading more articles by pages
    func loadMoreActicles() {
        if let q = currentQuery, let page = loadedPages, page < 100, page * 10 < totalHits! {
            self.isLoadingMore = true
            newsService.searchArticles(q: q, page: page+1).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                if response.status ?? "" == "OK", let articles = response.response?.docs {
                    let offset = (response.response?.meta?.offset) ?? 0
                    let currenctPage = Int(offset / 10)
                    self.loadedPages = currenctPage
                    self.currentQuery = q
                    let value = self.articles.value + articles
                    self.articles.accept(value)
                } else {
                    self.error.accept("Incorrect data")
                }
                self.isLoadingMore = false
            }, onError: { [weak self] (error) in
                guard let `self` = self else { return }
                self.error.accept(error.localizedDescription)
                self.isLoadingMore = false
            }).disposed(by: disposeBag)
        }
    }
    
    // MARK: Clear viewModel observables for new searching
    func clearAllModel() {
        self.articles.accept([])
        self.isLoading.accept(false)
        self.isLoadingMore = false
        self.loadedPages = nil
        self.currentQuery = nil
        self.totalHits = nil
    }
    
}


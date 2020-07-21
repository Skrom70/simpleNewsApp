//
//  SectionsViewModel.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/24/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SectionsViewModelProtocol {
    var stories: BehaviorRelay<[TopArticle]> { get set }
    var isLoading: BehaviorRelay<Bool> { get set }
    var isRefreshing: BehaviorRelay<Bool> { get set }
    var error: PublishRelay<String> { get set }
    
    func fetchStories(section: StoriesAPI)
    func refreshStories(section: StoriesAPI)
}


final class SectionsViewModel: SectionsViewModelProtocol {
    
    
    var stories: BehaviorRelay<[TopArticle]>
    var isLoading: BehaviorRelay<Bool>
    var isRefreshing: BehaviorRelay<Bool>
    var error: PublishRelay<String>
    
    private var disposeBag: DisposeBag
    private let newsService: NewsService = NewsService()
    private let realmStoryDataManager = RealmStoryDataManager<TopArticle>()
    
    
    
    init(section: StoriesAPI) {
        self.disposeBag = DisposeBag()
        self.stories = BehaviorRelay<[TopArticle]>(value: [])
        self.isLoading = BehaviorRelay<Bool>(value: false)
        self.isRefreshing = BehaviorRelay<Bool>(value: false)
        self.error = PublishRelay<String>()
        self.fetchStories(section: section)
    }
    
    // MARK: Fetching and caching data stories by selected topic
    func fetchStories(section: StoriesAPI) {
        let marker = section.rawValue
        let cachedStories = realmStoryDataManager.find(marker: marker)
        stories.accept(cachedStories)
        self.isLoading.accept(true)
        newsService.fetchStories(section: section).subscribe(onNext: { [weak self] (topStories) in
            guard let `self` = self else { return }
            self.isLoading.accept(false)
            if let stories = topStories.results, topStories.status ?? "" == "OK" {
                self.stories.accept(stories)
                self.realmStoryDataManager.resave(marker: marker, stories)
            } else {
                self.error.accept("Incorrect data")
            }
        }, onError: { [weak self] error in
            guard let `self` = self else { return }
            self.isLoading.accept(false)
            self.error.accept(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Refresh stories
    func refreshStories(section: StoriesAPI) {
        let marker = section.rawValue
        self.isRefreshing.accept(true)
        newsService.fetchStories(section: section).subscribe(onNext: { [weak self] (topStories) in
            guard let `self` = self else { return }
            self.isRefreshing.accept(false)
            if let stories = topStories.results, topStories.status ?? "" == "OK" {
                self.stories.accept(stories)
                self.realmStoryDataManager.resave(marker: marker, stories)
            } else {
                self.error.accept("Incorrect data")
            }
        }, onError: { [weak self] error in
            guard let `self` = self else { return }
            self.isRefreshing.accept(false)
            self.error.accept(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    

}

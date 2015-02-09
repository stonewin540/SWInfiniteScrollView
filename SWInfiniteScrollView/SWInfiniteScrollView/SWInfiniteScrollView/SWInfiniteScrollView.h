//
//  SWInfiniteScrollView.h
//  SWInfiniteScrollView
//
//  Created by stone win on 2/7/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWInfiniteScrollView;
@class SWInfiniteScrollPageView;
@protocol SWInfiniteScrollViewDataSource <NSObject>

- (NSInteger)numberOfPagesInScrollView:(SWInfiniteScrollView *)scrollView;

@end
@protocol SWInfiniteScrollViewDelegate <NSObject, UIScrollViewDelegate>

- (void)scrollView:(SWInfiniteScrollView *)scrollView willDisplayPageView:(SWInfiniteScrollPageView *)pageView atIndex:(NSInteger)index;

@end

@interface SWInfiniteScrollPageView : UIView

@end

@interface SWInfiniteScrollView : UIScrollView

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, weak) id<SWInfiniteScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<SWInfiniteScrollViewDelegate> delegate;

@end

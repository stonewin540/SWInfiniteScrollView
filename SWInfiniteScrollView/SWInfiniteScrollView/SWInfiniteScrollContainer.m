//
//  SWInfiniteScrollContainer.m
//  SWInfiniteScrollView
//
//  Created by stone win on 2/10/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "SWInfiniteScrollContainer.h"
#import "SWInfiniteScrollView.h"

@interface SWInfiniteScrollContainerWrapperView : UIView
@end
@implementation SWInfiniteScrollContainerWrapperView
@end

@interface SWInfiniteScrollContainer () <SWInfiniteScrollViewDataSource, SWInfiniteScrollViewDelegate>

@property (nonatomic, strong) SWInfiniteScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) SWInfiniteScrollContainerWrapperView *bottomWrapperView;

@end

@implementation SWInfiniteScrollContainer

- (void)setImages:(NSArray *)images {
    if ([_images isEqualToArray:images])
    {
        return;
    }
    _images = images;
    [self setNeedsLayout];
    [self.scrollView reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        _scrollView = [[SWInfiniteScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        _bottomWrapperView = [[SWInfiniteScrollContainerWrapperView alloc] init];
        _bottomWrapperView.backgroundColor = [UIColor colorWithWhite:1 alpha:.3f];
        [self addSubview:_bottomWrapperView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.numberOfLines = 1;
        [_bottomWrapperView addSubview:_titleLabel];
        
        _pageControl = [[UIPageControl alloc] init];
        [_bottomWrapperView addSubview:_pageControl];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bottomWrapperViewFrame, remainder;
    CGRectDivide(self.bounds, &bottomWrapperViewFrame, &remainder, 20, CGRectMaxYEdge);
    self.bottomWrapperView.frame = bottomWrapperViewFrame;
    
    CGRect pageControlFrame = CGRectZero;
    {
        CGSize size = [self.pageControl sizeForNumberOfPages:self.images.count];
        pageControlFrame.size.width = ceilf(size.width);
        pageControlFrame.size.height = CGRectGetHeight(bottomWrapperViewFrame);
        pageControlFrame.origin.x = CGRectGetWidth(bottomWrapperViewFrame) - pageControlFrame.size.width;
    }
    self.pageControl.frame = pageControlFrame;
    
    CGRect titleLabelFrame = CGRectZero;
    {
        titleLabelFrame.size.width = CGRectGetWidth(bottomWrapperViewFrame) - CGRectGetWidth(pageControlFrame);
        titleLabelFrame.size.height = CGRectGetHeight(bottomWrapperViewFrame);
    }
    self.titleLabel.frame = titleLabelFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - ScrollView DataSource

- (NSInteger)numberOfPagesInScrollView:(SWInfiniteScrollView *)scrollView {
    return self.images.count;
}

- (void)scrollView:(SWInfiniteScrollView *)scrollView willDisplayPageView:(SWInfiniteScrollPageView *)pageView atIndex:(NSInteger)index {
    static const NSInteger kTagImageView = 15021001;
    UIImageView *imageView = (UIImageView *)[pageView viewWithTag:kTagImageView];
    if (!imageView)
    {
        imageView = [[UIImageView alloc] initWithFrame:pageView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [pageView addSubview:imageView];
    }
    
    UIImage *image = self.images[index];
    CGSize imageSize = image.size;
    CGFloat ratio = imageSize.width / imageSize.height;
    if (ratio < .6f)
    {
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
    }
    
    imageView.image = image;
    imageView.backgroundColor = [UIColor colorWithRed:((arc4random() % 255) / 255.f) green:((arc4random() % 255) / 255.f) blue:((arc4random() % 255) / 255.f) alpha:1];
    self.titleLabel.text = [NSString stringWithFormat:@"pageIndex: %d", scrollView.currentPageIndex];
    self.pageControl.currentPage = scrollView.currentPageIndex;
}

@end

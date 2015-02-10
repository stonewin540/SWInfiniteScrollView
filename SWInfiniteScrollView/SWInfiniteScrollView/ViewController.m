//
//  ViewController.m
//  SWInfiniteScrollView
//
//  Created by stone win on 2/7/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "ViewController.h"
#import "SWInfiniteScrollView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController () <SWInfiniteScrollViewDataSource, SWInfiniteScrollViewDelegate>

@property (nonatomic, strong) SWInfiniteScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, assign) NSInteger numberOfPages;

@end

@implementation ViewController

#pragma mark - Action

- (void)pagesGenerator {
    self.numberOfPages = arc4random() % 7;
    self.pageControl.numberOfPages = self.numberOfPages;
    [self.scrollView reloadData];
}

- (void)generateButtonTapped:(UIButton *)sender {
    [self pagesGenerator];
}

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSStringFromClass([self class]);
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[SWInfiniteScrollView alloc] initWithFrame:CGRectMake(0, 64, 320, 180)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _scrollView.dataSource = self;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    CGRect slice, remainder;
    CGRectDivide(_scrollView.frame, &slice, &remainder, 20, CGRectMaxYEdge);
    _pageControl = [[UIPageControl alloc] initWithFrame:slice];
    _pageControl.backgroundColor = [UIColor colorWithWhite:0 alpha:.3f];
    [self.view addSubview:_pageControl];
    
    CGRect generateButtonFrame = CGRectMake(0, CGRectGetMaxY(_pageControl.frame) + 20, CGRectGetWidth(self.view.bounds), 50);
    UIButton *generateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    generateButton.frame = generateButtonFrame;
    generateButton.titleLabel.font = [UIFont systemFontOfSize:18];
    generateButton.layer.cornerRadius = CGRectGetMidY(generateButton.bounds);
    generateButton.layer.masksToBounds = YES;
    generateButton.layer.borderColor = generateButton.titleLabel.textColor.CGColor;
    generateButton.layer.borderWidth = .5f;
    [generateButton setTitle:@"random pages" forState:UIControlStateNormal];
    [generateButton addTarget:self action:@selector(generateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:generateButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self pagesGenerator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SWInfiniteScrollView DataSource

- (NSInteger)numberOfPagesInScrollView:(SWInfiniteScrollView *)scrollView {
    return self.numberOfPages;
}

#pragma mark - SWInfiniteScrollView Delegate

- (void)scrollView:(SWInfiniteScrollView *)scrollView willDisplayPageView:(SWInfiniteScrollPageView *)pageView atIndex:(NSInteger)index {
    static const NSInteger kTagLabel = 15020901;
    UIColor *backgroundColors[] = {
        [UIColor redColor],
        [UIColor greenColor],
        [UIColor blueColor],
    };
    
    UILabel *label = (UILabel *)[pageView viewWithTag:kTagLabel];
    if (!label)
    {
        label = [[UILabel alloc] initWithFrame:pageView.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.font = [UIFont systemFontOfSize:36];
        label.tag = kTagLabel;
        [pageView addSubview:label];
    }
    
    label.backgroundColor = backgroundColors[index % 3];
    label.text = [NSString stringWithFormat:@"pageIndex: %d", index];
    
    self.pageControl.currentPage = scrollView.currentPageIndex;
}

@end

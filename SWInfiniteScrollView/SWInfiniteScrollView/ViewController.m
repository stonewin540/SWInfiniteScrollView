//
//  ViewController.m
//  SWInfiniteScrollView
//
//  Created by stone win on 2/7/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "ViewController.h"
#import "SWInfiniteScrollView.h"

@interface ViewController () <SWInfiniteScrollViewDataSource, SWInfiniteScrollViewDelegate>

@property (nonatomic, strong) SWInfiniteScrollView *scrollView;

@end

@implementation ViewController

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self.scrollView selector:@selector(reloadData) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SWInfiniteScrollView DataSource

- (NSInteger)numberOfPagesInScrollView:(SWInfiniteScrollView *)scrollView {
    NSInteger numberOfPages = (arc4random() % 6) + 1;
    return numberOfPages;
}

#pragma mark - SWInfiniteScrollView Delegate

- (void)scrollView:(SWInfiniteScrollView *)scrollView willDisplayPageView:(SWInfiniteScrollPageView *)pageView atIndex:(NSInteger)index {
    static const NSInteger kTagLabel = 15020901;
    UILabel *label = (UILabel *)[pageView viewWithTag:kTagLabel];
    if (!label)
    {
        UIColor *backgroundColors[] = {
            [UIColor redColor],
            [UIColor greenColor],
            [UIColor blueColor],
        };
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(pageView.bounds), 36)];
        label.backgroundColor = backgroundColors[index % 3];
        label.font = [UIFont systemFontOfSize:18];
        label.tag = kTagLabel;
        [pageView addSubview:label];
    }
    
    label.text = [NSString stringWithFormat:@"pageIndex: %d", index];
}

@end

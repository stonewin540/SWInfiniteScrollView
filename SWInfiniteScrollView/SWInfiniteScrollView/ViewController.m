//
//  ViewController.m
//  SWInfiniteScrollView
//
//  Created by stone win on 2/7/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SWInfiniteScrollContainer.h"

@interface ViewController ()

@property (nonatomic, strong) SWInfiniteScrollContainer *scrollContainer;

@property (nonatomic, assign) NSInteger numberOfPages;

@end

@implementation ViewController

#pragma mark - Action

- (void)pagesGenerator {
//    self.numberOfPages = arc4random() % 7;
//    self.pageControl.numberOfPages = self.numberOfPages;
//    [self.scrollView reloadData];
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
    
    _scrollContainer = [[SWInfiniteScrollContainer alloc] initWithFrame:CGRectMake(0, 64, 320, 180)];
    _scrollContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_scrollContainer];
    
//    CGRect generateButtonFrame = CGRectMake(0, CGRectGetMaxY(_pageControl.frame) + 20, CGRectGetWidth(self.view.bounds), 50);
//    UIButton *generateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    generateButton.frame = generateButtonFrame;
//    generateButton.titleLabel.font = [UIFont systemFontOfSize:18];
//    generateButton.layer.cornerRadius = CGRectGetMidY(generateButton.bounds);
//    generateButton.layer.masksToBounds = YES;
//    generateButton.layer.borderColor = generateButton.titleLabel.textColor.CGColor;
//    generateButton.layer.borderWidth = .5f;
//    [generateButton setTitle:@"random pages" forState:UIControlStateNormal];
//    [generateButton addTarget:self action:@selector(generateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:generateButton];
}

- (NSArray *)scrollImages {
    static const int count = 10;
    
    NSMutableArray *scrollImages = [NSMutableArray array];
    for (int i = 0; i < count; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"scrollImage%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image)
        {
            [scrollImages addObject:image];
        }
    }
    return [scrollImages copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self pagesGenerator];
    self.scrollContainer.images = [self scrollImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - SWInfiniteScrollView DataSource
//
//- (NSInteger)numberOfPagesInScrollView:(SWInfiniteScrollView *)scrollView {
//    return self.numberOfPages;
//}
//
//#pragma mark - SWInfiniteScrollView Delegate
//
//- (void)scrollView:(SWInfiniteScrollView *)scrollView willDisplayPageView:(SWInfiniteScrollPageView *)pageView atIndex:(NSInteger)index {
//    static const NSInteger kTagLabel = 15020901;
//    UIColor *backgroundColors[] = {
//        [UIColor redColor],
//        [UIColor greenColor],
//        [UIColor blueColor],
//    };
//    
//    UILabel *label = (UILabel *)[pageView viewWithTag:kTagLabel];
//    if (!label)
//    {
//        label = [[UILabel alloc] initWithFrame:pageView.bounds];
//        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        label.font = [UIFont systemFontOfSize:36];
//        label.tag = kTagLabel;
//        [pageView addSubview:label];
//    }
//    
//    label.backgroundColor = backgroundColors[index % 3];
//    label.text = [NSString stringWithFormat:@"pageIndex: %d", index];
//    
//    self.pageControl.currentPage = scrollView.currentPageIndex;
//}

@end

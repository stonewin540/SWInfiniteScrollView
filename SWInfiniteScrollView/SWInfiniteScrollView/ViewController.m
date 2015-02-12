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
    NSInteger pageIndex = arc4random() % self.numberOfPages;
    [self.scrollContainer scrollToPageIndex:pageIndex];
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
    
    CGRect generateButtonFrame = CGRectMake(0, CGRectGetMaxY(_scrollContainer.frame) + 20, CGRectGetWidth(self.view.bounds), 50);
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

- (NSArray *)scrollImages {
    static const int count = 10;
    self.numberOfPages = count;
    
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

@end

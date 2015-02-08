//
//  ViewController.m
//  SWInfiniteScrollView
//
//  Created by stone win on 2/7/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "ViewController.h"
#import "SWInfiniteScrollView.h"

@interface ViewController ()

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
    _scrollView.numberOfPages = 3;
    [self.view addSubview:_scrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  SWInfiniteScrollView.m
//  SWInfiniteScrollView
//
//  Created by stone win on 2/7/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "SWInfiniteScrollView.h"

@interface SWInfiniteScrollViewWrapperView : UIView
@end
@implementation SWInfiniteScrollViewWrapperView
@end
@interface SWInfiniteScrollViewItemView : UIView
@end
@implementation SWInfiniteScrollViewItemView
@end

//typedef NS_ENUM(NSInteger, ItemViewPosition) {
//    ItemViewPositionLeft = -1,
//    ItemViewPositionMiddle = 0,
//    ItemViewPositionRight = 1,
//    Left,
//    Middle,
//    Right,
//};
typedef NS_ENUM(NSInteger, PositionOffset) {
    PositionOffsetLeft = -1,
    PositionOffsetMiddle = 0,
    PositionOffsetRight = 1,
};

/**
 无论传入的page有多少页，只有三个item交替展示不同的page
 */
static const NSInteger kMaxNumberOfItems = 3;

@interface SWInfiniteScrollView ()

// UI
@property (nonatomic, strong) SWInfiniteScrollViewWrapperView *itemViewsWrapperView;
// data
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, assign) NSInteger currentPageIndex;

@end

@implementation SWInfiniteScrollView

- (void)addSubitemView:(SWInfiniteScrollViewItemView *)itemView {
    [self.itemViews addObject:itemView];
    [self.itemViewsWrapperView addSubview:itemView];
}

- (void)reloadData {
    for (int i = 0; i < kMaxNumberOfItems; i++)
    {
        SWInfiniteScrollViewItemView *itemView = [[SWInfiniteScrollViewItemView alloc] init];
        itemView.backgroundColor = [UIColor colorWithRed:((arc4random() % 255) / 255.f) green:((arc4random() % 255) / 255.f) blue:((arc4random() % 255) / 255.f) alpha:1];
        [self addSubitemView:itemView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:itemView.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.text = [@(i) stringValue];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:72];
        [itemView addSubview:label];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        _itemViews = [[NSMutableArray alloc] init];
        _currentPageIndex = NSNotFound;
        
        _itemViewsWrapperView = [[SWInfiniteScrollViewWrapperView alloc] init];
        _itemViewsWrapperView.backgroundColor = [UIColor clearColor];
        [self addSubview:_itemViewsWrapperView];
    }
    return self;
}

- (CGPoint)centerOffset {
    CGFloat x = 1 * CGRectGetWidth(self.bounds);
    return CGPointMake(x, 0);
}

- (NSInteger)indexWithOffset:(NSInteger)offset fromIndex:(NSInteger)fromIndex max:(NSInteger)max {
    // Complicated stuff with negative modulo
    NSInteger index = offset;
    while (index < 0) {
        index += max;
    }
    index = (max + fromIndex + index) % max;
    return index;
}

- (void)moveItemViewWithPositionOffset:(PositionOffset)positionOffset pageIndex:(NSInteger)pageIndex {
    NSInteger itemIndex = [self indexWithOffset:0 fromIndex:pageIndex + 1 max:kMaxNumberOfItems];
    SWInfiniteScrollViewItemView *itemView = self.itemViews[itemIndex];
    CGFloat x = (positionOffset + 1) * CGRectGetWidth(self.bounds);
    CGRect itemViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    itemViewFrame = CGRectOffset(itemViewFrame, x, 0);
    itemView.frame = itemViewFrame;
}

- (void)rearrangeItemsWithCenterPageIndex:(NSInteger)pageIndex {
    if (self.currentPageIndex == pageIndex)
    {
        return;
    }
    self.currentPageIndex = pageIndex;
    
    [self moveItemViewWithPositionOffset:PositionOffsetMiddle pageIndex:self.currentPageIndex];
    self.contentOffset = [self centerOffset];
    NSInteger leftIndex = [self indexWithOffset:PositionOffsetLeft fromIndex:self.currentPageIndex max:self.numberOfPages];
    NSInteger rightIndex = [self indexWithOffset:PositionOffsetRight fromIndex:self.currentPageIndex max:self.numberOfPages];
    [self moveItemViewWithPositionOffset:PositionOffsetLeft pageIndex:leftIndex];
    [self moveItemViewWithPositionOffset:PositionOffsetRight pageIndex:rightIndex];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize contentSize = CGSizeMake(kMaxNumberOfItems * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    if (!CGSizeEqualToSize(self.contentSize, contentSize))
    {
        self.contentSize = contentSize;
        self.contentOffset = [self centerOffset];
        
        [self reloadData];
        [self rearrangeItemsWithCenterPageIndex:0];
    }
    
    BOOL forward = (self.contentOffset.x >= (2 * CGRectGetWidth(self.bounds)));
    BOOL backrward = (self.contentOffset.x <= (0 * CGRectGetWidth(self.bounds)));
    NSInteger currentPageIndex = self.currentPageIndex;
    if (forward)
    {
        currentPageIndex = [self indexWithOffset:PositionOffsetRight fromIndex:currentPageIndex max:self.numberOfPages];
    }
    else if (backrward)
    {
        currentPageIndex = [self indexWithOffset:PositionOffsetLeft fromIndex:currentPageIndex max:self.numberOfPages];
    }
    [self rearrangeItemsWithCenterPageIndex:currentPageIndex];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

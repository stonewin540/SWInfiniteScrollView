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

typedef NS_ENUM(NSInteger, PositionOffset) {
    PositionOffsetLeft = -1,
    PositionOffsetMiddle = 0,
    PositionOffsetRight = 1,
};

@implementation NSMutableArray (SWInfiniteScrollView)

/**
 循环排序的方法
 @prama delta 负数，从前向后循环；正数，从后向前循环
 @description
    例如：0，1，2 delta＝－1 1，2，0
         0，1，2 delta＝1   2，0，1
 */
- (void)rotatedItemsWithDelta:(NSInteger)delta {
    NSInteger absDelta = ABS(delta);
    NSParameterAssert(absDelta < self.count);
    if (delta < 0)
    {
        NSArray *items = [self subarrayWithRange:NSMakeRange(0, absDelta)];
        [self removeObjectsInArray:items];
        [self addObjectsFromArray:items];
    }
    else if (delta > 0)
    {
        NSArray *items = [self subarrayWithRange:NSMakeRange(self.count - absDelta, absDelta)];
        [self removeObjectsInArray:items];
        [self insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, items.count)]];
    }
}

@end

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
@property (nonatomic, strong) NSMutableArray *itemIndexs;

@end

@implementation SWInfiniteScrollView

- (void)addSubitemView:(SWInfiniteScrollViewItemView *)itemView {
    [self.itemViews addObject:itemView];
    [self.itemViewsWrapperView addSubview:itemView];
}

- (void)reloadData {
    [self.itemIndexs removeAllObjects];
    for (int i = 0; i < kMaxNumberOfItems; i++)
    {
        [self.itemIndexs addObject:@(i)];
        
        SWInfiniteScrollViewItemView *itemView = [[SWInfiniteScrollViewItemView alloc] init];
        itemView.backgroundColor = [UIColor colorWithRed:((arc4random() % 255) / 255.f) green:((arc4random() % 255) / 255.f) blue:((arc4random() % 255) / 255.f) alpha:1];
        [self addSubitemView:itemView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:itemView.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"itemIndex: %d", i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:36];
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
        _itemIndexs = [[NSMutableArray alloc] init];
        
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

- (NSInteger)pageIndexWithOffset:(PositionOffset)positionOffset fromIndex:(NSInteger)fromIndex {
    NSInteger pageIndex = [self indexWithOffset:positionOffset fromIndex:fromIndex max:self.numberOfPages];
    return pageIndex;
}

- (void)moveItemViewWithPositionOffset:(PositionOffset)positionOffset index:(NSInteger)itemIndex {
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
    
    NSInteger middleItemIndex = [self.itemIndexs[1] integerValue];
    NSInteger leftItemIndex = [self.itemIndexs[0] integerValue];
    NSInteger rightItemIndex = [self.itemIndexs[2] integerValue];
    [self moveItemViewWithPositionOffset:PositionOffsetMiddle index:middleItemIndex];
    [self moveItemViewWithPositionOffset:PositionOffsetLeft index:leftItemIndex];
    [self moveItemViewWithPositionOffset:PositionOffsetRight index:rightItemIndex];
    self.contentOffset = [self centerOffset];
    NSInteger leftPageIndex = [self pageIndexWithOffset:PositionOffsetLeft fromIndex:self.currentPageIndex];
    NSInteger rightPageIndex = [self pageIndexWithOffset:PositionOffsetRight fromIndex:self.currentPageIndex];
    NSLog(@"itemIndex: %d %d %d; pageIndex: %d %d %d", leftItemIndex, middleItemIndex, rightItemIndex, leftPageIndex, self.currentPageIndex, rightPageIndex);
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
        currentPageIndex = [self pageIndexWithOffset:PositionOffsetRight fromIndex:currentPageIndex];
        [self.itemIndexs rotatedItemsWithDelta:PositionOffsetLeft];
    }
    else if (backrward)
    {
        currentPageIndex = [self pageIndexWithOffset:PositionOffsetLeft fromIndex:currentPageIndex];
        [self.itemIndexs rotatedItemsWithDelta:PositionOffsetRight];
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

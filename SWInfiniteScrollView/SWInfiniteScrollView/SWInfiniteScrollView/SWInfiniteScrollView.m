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
- (SWInfiniteScrollPageView *)pageView {
    UIView *pageView = nil;
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[SWInfiniteScrollPageView class]])
        {
            pageView = subview;
            break;
        }
    }
    return (SWInfiniteScrollPageView *)pageView;
}
@end

@implementation SWInfiniteScrollPageView
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
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *itemIndexs;
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSInteger requestedScrollToPageIndex;

@end

@implementation SWInfiniteScrollView

- (void)addSubitemView:(SWInfiniteScrollViewItemView *)itemView {
    [self.itemViews addObject:itemView];
    [self.itemViewsWrapperView addSubview:itemView];
}

- (CGPoint)centerOffset {
    CGFloat x = 1 * CGRectGetWidth(self.bounds);
    return CGPointMake(x, 0);
}

- (void)reloadData {
    self.numberOfPages = 0;
    if (self.dataSource)
    {
        self.numberOfPages = [self.dataSource numberOfPagesInScrollView:self];
    }
    
    if (0 == self.numberOfPages)
    {
        [self.pageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.pageViews removeAllObjects];
        self.currentPageIndex = 0;
    }
    else
    {
        for (SWInfiniteScrollViewItemView *itemView in self.itemViews)
        {
            SWInfiniteScrollPageView *pageView = [itemView pageView];
            if (!pageView)
            {
                Class pageViewClass = [SWInfiniteScrollPageView class];
                if (self.dataSource)
                {
                    pageViewClass = [self.dataSource classOfPageViewInScrollView:self];
                    NSParameterAssert([pageViewClass isSubclassOfClass:[SWInfiniteScrollPageView class]]);
                }
                pageView = [[pageViewClass alloc] initWithFrame:itemView.bounds];
                pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [itemView addSubview:pageView];
                [self.pageViews addObject:pageView];
            }
        }
    }
    
    self.scrollEnabled = (self.numberOfPages > 1);
    self.contentSize = CGSizeMake(kMaxNumberOfItems * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.contentOffset = [self centerOffset];
    
    NSInteger pageIndex = self.currentPageIndex;
    if (NSNotFound == pageIndex)
    {
        pageIndex = 0;
    }
    else if (self.currentPageIndex >= self.numberOfPages)
    {
        pageIndex = self.numberOfPages - 1;
    }
    // 暂时不能判断pageIndex != self.currentPageIndex才rearrange
    // 如果原来numberOfPages＝2，停留在第0页，两边应该是第1页
    // 现在numberOfPages＝3，还停留在第0页，明显两边应该分别是第2页和第1页，如果不rearrange，两边是不会加载的
    if (pageIndex >= 0)
    {// numberOfPages等于0的时候，pageIndex等于－1
        [self rearrangeItemViewsWithMiddlePageIndex:pageIndex];
    }
}

- (void)initItemViews {
    for (int i = 0; i < kMaxNumberOfItems; i++)
    {
        [self.itemIndexs addObject:@(i)];
        
        SWInfiniteScrollViewItemView *itemView = [[SWInfiniteScrollViewItemView alloc] init];
        itemView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:((arc4random() % 255) / 255.f) green:((arc4random() % 255) / 255.f) blue:((arc4random() % 255) / 255.f) alpha:1];
        [self addSubitemView:itemView];
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
        _pageViews = [[NSMutableArray alloc] init];
        _currentPageIndex = NSNotFound;
        _itemIndexs = [[NSMutableArray alloc] init];
        _requestedScrollToPageIndex = NSNotFound;
        
        _itemViewsWrapperView = [[SWInfiniteScrollViewWrapperView alloc] init];
        _itemViewsWrapperView.backgroundColor = [UIColor clearColor];
        [self addSubview:_itemViewsWrapperView];
        
        [self initItemViews];
    }
    return self;
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

- (void)rearrangeItemViewsWithMiddlePageIndex:(NSInteger)pageIndex {
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
    
    if (self.delegate)
    {
        // middle
        SWInfiniteScrollViewItemView *itemView = self.itemViews[middleItemIndex];
        SWInfiniteScrollPageView *pageView = itemView.subviews.lastObject;
        [self.delegate scrollView:self willDisplayPageView:pageView atIndex:self.currentPageIndex];
        // left
        itemView = self.itemViews[leftItemIndex];
        pageView = itemView.subviews.lastObject;
        [self.delegate scrollView:self willDisplayPageView:pageView atIndex:leftPageIndex];
        // right
        itemView = self.itemViews[rightItemIndex];
        pageView = itemView.subviews.lastObject;
        [self.delegate scrollView:self willDisplayPageView:pageView atIndex:rightPageIndex];
    }
}

- (void)rearrangeItemViewsIfNeededWithMiddlePageIndex:(NSInteger)pageIndex {
    if (0 == self.numberOfPages)
    {
        return;
    }
    if (self.currentPageIndex == pageIndex)
    {
        return;
    }
    [self rearrangeItemViewsWithMiddlePageIndex:pageIndex];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(self.contentSize, CGSizeZero))
    {
        [self reloadData];
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
    [self rearrangeItemViewsIfNeededWithMiddlePageIndex:currentPageIndex];
    
    if ((NSNotFound != self.requestedScrollToPageIndex) && (self.requestedScrollToPageIndex != self.currentPageIndex))
    {
        [self scrollPageIndexToVisible:self.requestedScrollToPageIndex animated:YES];
        self.requestedScrollToPageIndex = NSNotFound;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)scrollPageIndexToVisible:(NSInteger)pageIndex animated:(BOOL)animated {
    self.requestedScrollToPageIndex = pageIndex;
    if (animated)
    {
        CGPoint contentOffset = [self centerOffset];
        NSInteger diff = pageIndex - self.currentPageIndex;
        contentOffset.x += diff * CGRectGetWidth(self.bounds);
        [self setContentOffset:contentOffset animated:YES];
    }
    else
    {
        [self rearrangeItemViewsIfNeededWithMiddlePageIndex:pageIndex];
    }
}

@end

//
//  LXCycleScrollView.m
//  LXCycleScrollViewDemo
//
//  Created by heyong on 2019/4/25.
//  Copyright © 2019年 liuxing. All rights reserved.
//

#import "LXCycleScrollView.h"
#import <UIImageView+WebCache.h>

@interface LXCycleScrollView() <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    NSTimer * _timer;
}

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *imagePathsGroup;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) NSInteger itemMultiple;
@property (nonatomic, assign, readonly) NSInteger realCurrentIndex;
@property (nonatomic, assign, getter=isStop) BOOL stop;
@end

@implementation LXCycleScrollView

- (void)dealloc
{
    [self stop];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<LXCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage
{
    LXCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.delegate = delegate;
    cycleScrollView.placeholderImage = placeholderImage;
    
    return cycleScrollView;
}


- (void)initView {
    self.itemCount = 0;
    self.itemMultiple = 1000;
    self.scrollIntervalTime = 3;
    self.autoScroll = YES;
    self.cycle = YES;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.bannerImageViewContentMode = UIViewContentModeScaleToFill;

    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.flowLayout.itemSize = self.bounds.size;
    self.collectionView.frame = self.bounds;
    [self restoreOffset];
}

#pragma mark - func

- (void)upadteItemCount {
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        self.itemCount = [self.dataSource numberOfItemsInCycleView:self];
    }
    if (self.images.count > 0) {
        self.itemCount = self.images.count;
    }
    if (self.titles.count > 0) {
        self.itemCount = self.titles.count;
    }
}

- (void)autoScroll {
    [self upadteItemCount];
    if (self.itemCount <= 1) {
        self.cycle = NO;
    }
    
    if (self.isAutoScroll && self.itemCount > 1) {
        [self resetTimer];
    }
    
    if ([self.delegate respondsToSelector:@selector(cycleView:scrollToIndex:)]) {
        [self.delegate cycleView:self scrollToIndex:self.currentIndex];
    }
}

- (void)resetTimer {
    if (_timer) {
        [self pause];
        _timer = nil;
    }
    _timer = [NSTimer timerWithTimeInterval:self.scrollIntervalTime target:self selector:@selector(scrollToNext) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    [self start];
}

- (void)start {
    if (_timer) {
        _stop = NO;
        _timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.scrollIntervalTime];
    }
}

- (void)pause {
    if (_timer) {
        _stop = YES;
        _timer.fireDate = [NSDate distantFuture];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollToNext) object:nil];
    }
}

- (void)stop {
    [self pause];
    [_timer invalidate];
    _timer = nil;
}

- (void)reloadData {
    [self.collectionView reloadData];
    [self layoutSubviews];
    
    [self autoScroll];
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)scrollToNext {
    NSInteger index = self.realCurrentIndex;
    if (self.isBackwardScroll) {
        index --;
    } else {
        index ++;
    }
    if (!self.isCycle) {
        if (index >= self.itemCount) {
            index = 0;
        }
    }
    [self scrollToRealIndex:index animation:YES];
}

- (void)restoreOffset {
    if (self.isCycle == false || self.itemCount < 2) {
        return;
    }
    
    NSInteger totalCount = self.itemCount * self.itemMultiple;
    
    if (self.realCurrentIndex == totalCount - 1) {//最后一个
        NSInteger index = (NSInteger)(((CGFloat)(totalCount + 0.1)) * 0.5) + (self.itemCount - 1);
        [self scrollToRealIndex:index animation:NO];
    } else if (self.realCurrentIndex == 0) {//第一个
        NSInteger index = (NSInteger)(((CGFloat)(totalCount) + 0.1) * 0.5);
        [self scrollToRealIndex:index animation:NO];
    }
}

- (void)scrollToIndex:(NSInteger)index {
    if (index < 0 || index >= self.itemCount) {
        return;
    }
    [self scrollToRealIndex:(self.realCurrentIndex + (index - self.currentIndex)) animation:YES];
}

- (void)scrollToRealIndex:(NSInteger)index {
    if (self.itemCount < 1) {
        return;
    }
    [self scrollToRealIndex:index animation:YES];
}

- (void)scrollToRealIndex:(NSInteger)index animation:(BOOL)animation {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animation];
}

#pragma mark - setter

- (void)setImages:(NSArray *)images {
    _titles = nil;
    _images = images;
    NSMutableArray *temp = [NSMutableArray new];
    [_images enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]){
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        if (urlString) {
            [temp addObject:urlString];
        }else if ([obj isKindOfClass:[UIImage class]]){
            [temp addObject:obj];
        }
    }];
    self.imagePathsGroup = [temp copy];
}

- (void)setTitles:(NSArray *)titles {
    _images = nil;
    _titles = titles;
}


-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    [_timer invalidate];
    _timer = nil;
    if (self.autoScroll) {
        [self resetTimer];
    }
}

- (void)setScrollIntervalTime:(CGFloat)scrollIntervalTime {
    _scrollIntervalTime = scrollIntervalTime;
    [self setAutoScroll:self.isAutoScroll];
}


- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    self.flowLayout.scrollDirection = scrollDirection;
}


- (void)setCycle:(BOOL)cycle {
    _cycle = cycle;
    self.collectionView.bounces = !cycle;
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    _placeholderImage = placeholderImage;
}


#pragma mark - getter

- (NSInteger)currentIndex {
    NSInteger index = self.realCurrentIndex % self.itemCount;
    
    if (index < 0) {
        index = 0;
    }
    
    if (index > self.itemCount - 1) {
        index = self.itemCount - 1;
    }
    return index;
}

- (NSInteger)realCurrentIndex {
    if (self.collectionView.frame.size.width == 0) {
        return 0;
    }
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        return (NSInteger)((self.collectionView.contentOffset.x + self.flowLayout.itemSize.width * 0.5)/self.flowLayout.itemSize.width);
    } else {
        return (NSInteger)((self.collectionView.contentOffset.y + self.flowLayout.itemSize.height * 0.5)/self.flowLayout.itemSize.height);
    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self upadteItemCount];
    
    if (self.itemCount < 2) {
        return self.itemCount;
    }
    
    if (self.isCycle) {
        return self.itemCount * self.itemMultiple;
    }
    
    return self.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(cycleView:cellForItem:)]) {
        return [self.dataSource cycleView:self cellForItem:indexPath.row];
    }
    if (self.images) {
        LXCycleScrollViewImageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LXCycleScrollViewImageCell" forIndexPath:indexPath];
        long itemIndex = indexPath.item % self.imagePathsGroup.count;
        
        NSString *imagePath = self.imagePathsGroup[itemIndex];
        
        if ([imagePath isKindOfClass:[NSString class]]) {
            if ([imagePath hasPrefix:@"http"]) {
                [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
            } else {
                cell.imageView.image = [UIImage imageNamed:imagePath];
            }
        } else if ([imagePath isKindOfClass:[UIImage class]]) {
            cell.imageView.image = (UIImage *)imagePath;
        }
        if (self.bannerImageViewContentMode) {
            cell.imageView.contentMode = self.bannerImageViewContentMode;
        }
        return cell;
    } else {
        LXCycleScrollViewTextCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LXCycleScrollViewTextCell" forIndexPath:indexPath];
        cell.titleLabel.text = self.titles[indexPath.item % self.imagePathsGroup.count];
        
        return cell;
    }
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectItemAtIndex:)]) {
        [self.delegate cycleView:self didSelectItemAtIndex:self.currentIndex];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isAutoScroll) {
        [self pause];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.isAutoScroll) {
        if (self.isStop) {
            [self start];
        }
    }
    [self restoreOffset];
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectItemAtIndex:)]) {
        [self.delegate cycleView:self didSelectItemAtIndex:self.currentIndex];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self restoreOffset];
    if ([self.delegate respondsToSelector:@selector(cycleView:scrollToIndex:)]) {
        [self.delegate cycleView:self scrollToIndex:self.currentIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(cycleView:didScrollToIndex:)]) {
        [self.delegate cycleView:self didScrollToIndex:self.currentIndex];
    }
}

#pragma mark - lazy

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.clipsToBounds = true;
        [_collectionView registerClass:[LXCycleScrollViewImageCell class] forCellWithReuseIdentifier:@"LXCycleScrollViewImageCell"];
        [_collectionView registerClass:[LXCycleScrollViewTextCell class] forCellWithReuseIdentifier:@"LXCycleScrollViewTextCell"];
    }
    return _collectionView;
}

@end

@implementation LXCycleScrollViewImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCell];
    }
    return self;
}

- (void)initCell {
    [self.contentView addSubview:self.imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

@end

@implementation LXCycleScrollViewTextCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCell];
    }
    return self;
}

- (void)initCell {
    [self.contentView addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.contentView.bounds;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}


@end

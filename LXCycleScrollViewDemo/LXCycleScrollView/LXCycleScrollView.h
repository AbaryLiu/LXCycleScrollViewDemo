//
//  LXCycleScrollView.h
//  LXCycleScrollViewDemo
//
//  Created by heyong on 2019/4/25.
//  Copyright © 2019年 liuxing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LXCycleScrollView;

@protocol LXCycleScrollViewDelegate <NSObject>

@optional
- (void)cycleView:(LXCycleScrollView *)cycleView didSelectItemAtIndex:(NSInteger)index;
- (void)cycleView:(LXCycleScrollView *)cycleView scrollToIndex:(NSInteger)index;
- (void)cycleView:(LXCycleScrollView *)cycleView didScrollToIndex:(NSInteger)index;
@end

@protocol LXCycleScrollViewDataSource <NSObject>

- (NSInteger)numberOfItemsInCycleView:(LXCycleScrollView *)cycleView;
- (UICollectionViewCell *)cycleView:(LXCycleScrollView *)cycleView cellForItem:(NSInteger)item;

@end

@interface LXCycleScrollView : UIView

@property (nonatomic, weak) id<LXCycleScrollViewDelegate> delegate;
@property (nonatomic, weak) id<LXCycleScrollViewDataSource> dataSource;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, assign, getter=isBackwardScroll) BOOL backwardScroll;//是否反向转动 默认NO
@property (nonatomic, assign, getter=isCycle) BOOL cycle;//是否循环 默认YES
@property (nonatomic, assign, getter=isAutoScroll) BOOL autoScroll;//是否自动滚动
@property (nonatomic, assign) CGFloat scrollIntervalTime;//滚动间隔时间 默认3秒

@property (nonatomic, strong) NSArray *images;//图片数组（UIImage/NSUrl/NSString）

@property (nonatomic, strong) NSArray *titles;//文字数组（NSString）

@property (nonatomic, assign, readonly) NSInteger currentIndex;

/** 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill */
@property (nonatomic, assign) UIViewContentMode bannerImageViewContentMode;
/** 占位图，用于网络未加载到图片时 */
@property (nonatomic, strong) UIImage *placeholderImage;

- (void)reloadData;
- (void)scrollToIndex:(NSInteger)index;
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;


/** 初始轮播图（推荐使用） */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<LXCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage;

@end

@interface LXCycleScrollViewImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@interface LXCycleScrollViewTextCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END

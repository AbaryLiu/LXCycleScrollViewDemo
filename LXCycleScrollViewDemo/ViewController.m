//
//  ViewController.m
//  LXCycleScrollViewDemo
//
//  Created by heyong on 2019/4/25.
//  Copyright © 2019年 liuxing. All rights reserved.
//

#import "ViewController.h"
#import "LXCycleScrollView.h"


@interface ViewController ()<LXCycleScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LXCycleScrollView * cycleScrollView = [LXCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200) delegate:self placeholderImage:nil];
    cycleScrollView.autoScroll = YES;
    cycleScrollView.scrollIntervalTime = 1.f;
    cycleScrollView.images = @[[UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"],[UIImage imageNamed:@"4"]];
    [self.view addSubview:cycleScrollView];
    
}

#pragma mark - LXCycleScrollViewDelegate/LXCycleScrollViewDataSource

- (void)cycleView:(LXCycleScrollView *)cycleView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"点击了第几个");
}

- (void)cycleView:(LXCycleScrollView *)cycleView scrollToIndex:(NSInteger)index {
    NSLog(@"滚动到第几个");
}


//- (NSInteger)numberOfItemsInCycleView:(LXCycleScrollView *)cycleView {
//    return 2;
//}
//
//- (UICollectionViewCell *)cycleView:(LXCycleScrollView *)cycleView cellForItem:(NSInteger)item {
//    LXCycleScrollViewImageCell * cell = [[LXCycleScrollViewImageCell alloc] init];
//    return cell;
//}
@end

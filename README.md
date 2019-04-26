# LXCycleScrollViewDemo
一个可直接使用，也可以高度自定一个的轮播图，也可作为引导页面使用</br>
![image](https://github.com/AbaryLiu/LXCycleScrollViewDemo/blob/master/2019-04-26%2009-40-42.2019-04-26%2009_41_10.gif)

###简单使用
```
    LXCycleScrollView * cycleScrollView = [LXCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200) delegate:self placeholderImage:nil];
    cycleScrollView.autoScroll = YES;
    cycleScrollView.scrollIntervalTime = 1.f;
    cycleScrollView.images = @[[UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"],[UIImage imageNamed:@"4"]];
    [self.view addSubview:cycleScrollView];
```

```
- (void)cycleView:(LXCycleScrollView *)cycleView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"点击了第几个");
}
```
### 根据自己需要需要自定义的就直接和tableView类似
1、实现dataSource代理
```
cycleScrollView.dataSource = self;
```
2、实现数据源方法
```
//返回个数
- (NSInteger)numberOfItemsInCycleView:(LXCycleScrollView *)cycleView {
    return 2;
}

//自定义cell
-(UICollectionViewCell *)cycleView:(LXCycleScrollView *)cycleView cellForItem:(NSInteger)item {
    return [UICollectionViewCell new];
}
```

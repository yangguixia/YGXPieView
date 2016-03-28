//
//  JFPieView.h
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFPieShaperLayer.h"

@class JFPieView;
@class JFPieLayerItem;


@protocol JFPieViewDataSource <NSObject>

@required
- (NSUInteger)numberOfSlicesInJFPieView:(JFPieView*)pieView;

- (JFPieLayerItem*)pieView:(JFPieView *)pieChart dataItemAtIndex:(NSUInteger)index;


@end

@protocol JFPieViewDelegate <NSObject>

@optional

- (void)pieView:(JFPieView *)pieChart  willSelectIndex:(NSUInteger)index;

- (void)pieView:(JFPieView *)pieChart didSelectIndex:(NSUInteger)index;

@end

@interface JFPieView : UIView

@property(nonatomic, assign) id<JFPieViewDataSource> dataSource;

@property(nonatomic,assign) id<JFPieViewDelegate>  delegate;


// Start angle
@property (nonatomic) float startAngle;

// Length of circle, from 0 to M_PI*2
// Default M_PI*2.
@property (nonatomic) float length;

@property(nonatomic, assign) CGPoint pieCenter;

@property (nonatomic) float radius;
@property (nonatomic) float holeRadius;

@property(nonatomic, assign) CGFloat outsideWidth;
@property(nonatomic, strong) UIColor* outSideColor;

@property(nonatomic, assign) BOOL hasOutSideLayer;

@property (nonatomic) BOOL presentWithAnimation;
@property (nonatomic) JFPieChartAnimationOptions animationOptions;
@property (nonatomic) float animationDuration;

@property (nonatomic,assign) CGFloat standardPoint;

@property(nonatomic,assign)NSInteger selectedSliceIndex;

- (void)reloadData;

- (void)autoRotationToIndex:(NSInteger)toIndex;

@end

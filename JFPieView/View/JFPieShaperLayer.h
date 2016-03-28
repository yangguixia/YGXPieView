//
//  JFPieShaperLayer.h
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_OPTIONS(NSUInteger, JFPieChartAnimationOptions) {
    JFPieChartAnimationFanAll                     = 1 <<  0, // default
    JFPieChartAnimationGrowth                     = 1 <<  1,
    JFPieChartAnimationGrowthAll                  = 1 <<  2,
    JFPieChartAnimationGrowthBack                 = 1 <<  3,
    JFPieChartAnimationGrowthBackAll              = 1 <<  4,
    JFPieChartAnimationFan                        = 1 <<  5,
    
    JFPieChartAnimationTimingEaseInOut            = 1 << 16,
    JFPieChartAnimationTimingEaseIn               = 2 << 16,
    JFPieChartAnimationTimingEaseOut              = 3 << 16,
    JFPieChartAnimationTimingLinear               = 4 << 16, // default
};

typedef NS_ENUM(NSUInteger, JFLabelsPosition) {
    JFLabelsPositionNone        = 0, // default is no labels
    JFLabelsPositionOnChart     = 1,
    JFLabelsPositionOutChart    = 2,
    JFLabelsPositionCustom      = 3,
};

@class JFPiePath;
@class JFPieLayerItem;

@interface JFPieShaperLayer : CAShapeLayer

@property (nonatomic, assign) CGFloat   value;
@property (nonatomic, assign) CGFloat   percentage;


// Default is NO
@property (nonatomic, assign) BOOL accent;

// Default is 0.1 (i.e. 10%) of innerRadius
@property (nonatomic) float accentPrecent;

@property (nonatomic) float innerRadius;
@property (nonatomic) float outerRadius;

/*
 Actual angle of segment
 */
@property (nonatomic, readonly) float angle;

/*
 Start angle for segment
 */
@property (nonatomic, readonly) float startAngle;

@property (nonatomic) JFPieChartAnimationOptions animationOptions;
@property (nonatomic) float animationDuration;

@property (nonatomic, copy) void (^endAnimationBlock)(void);

- (JFPiePath*) he_JFPiePath;

- (JFPieLayerItem*)he_JFPieLayerItem;

- (void) pieceAngle:(float)angle start:(float)startAngle;

- (void) _animate;
- (void) setAnimationOptions:(JFPieChartAnimationOptions)options;
- (void) setAnimationDuration:(float)duration;

- (void)animateChangesInnerRadius:(CGFloat)innerRadius;

@end

//
//  JFPiePath.h
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class JFPieShaperLayer;
@class JFPieLayerItem;

@interface JFPiePath : UIBezierPath

@property(nonatomic,strong) UIColor* strokeColor;
@property(nonatomic,strong) UIColor *fillColor;

@property(nonatomic,assign)CGFloat strokeStart;

@property(nonatomic,assign)CGFloat strokeEnd;

- (JFPieShaperLayer *) JFPieShaperLayer;

- (JFPieLayerItem*)JFPieLayerItem;

@end

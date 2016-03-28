//
//  JFPieLayerItem.h
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTGraphicsConverter.h"

@class JFPieShaperLayer;

@interface JFPieLayerItem : NSObject

@property(nonatomic,assign)CGFloat lineWidth;
@property (nonatomic, strong) UIColor *strokeColor;

@property(nonatomic,strong)UIColor *fillColor;

@property(nonatomic,strong) NSString *fillRule;

@property(nonatomic) CGFloat miterLimit;

@property(nonatomic,strong) NSString *lineCap;

@property(nonatomic,strong) NSString *lineJoin;

@property(nonatomic,strong) NSArray *lineDashPattern;

@property(nonatomic,assign) CGFloat lineDashPhase;

@property(nonatomic,assign)CGFloat strokeStart;

@property(nonatomic,assign)CGFloat strokeEnd;

//
@property(nonatomic,assign)CGFloat sliceValue;

@property(nonatomic,assign)BOOL accent;

-(JFPieShaperLayer*)JFPieShaperLayer;

-(JFPieShaperLayer*)JFPieOuterShaperLayer;

@end

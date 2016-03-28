//
//  JFPiePath.m
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import "JFPiePath.h"
#import "JFPieShaperLayer.h"

#import "JFPieLayerItem.h"

@implementation JFPiePath

-(JFPieShaperLayer*)JFPieShaperLayer{
    
    JFPieShaperLayer* layer = [JFPieShaperLayer layer];
    
    layer.path = [self CGPath];
    
    layer.fillColor = self.fillColor.CGColor;
    
    layer.strokeColor = self.strokeColor.CGColor;
    
    layer.lineWidth = self.lineWidth;
    layer.miterLimit = self.miterLimit;
    
    layer.lineCap = [DTGraphicsConverter lineCapFromCGLineCap:self.lineCapStyle];
    layer.lineJoin = [DTGraphicsConverter lineJoinFromCGLineJoin:self.lineJoinStyle];
    
    layer.fillRule = self.usesEvenOddFillRule ? kCAFillRuleEvenOdd : kCAFillRuleNonZero;
    
    NSInteger count;
    [self getLineDash:NULL count:&count phase:NULL];
    CGFloat pattern[count], phase;
    [self getLineDash:pattern count:NULL phase:&phase];
    
    NSMutableArray *lineDashPattern = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        [lineDashPattern addObject:@(pattern[i])];
    }
    
    layer.lineDashPattern = [lineDashPattern copy];
    layer.lineDashPhase = phase;
    
    layer.strokeStart = self.strokeStart;
    
    layer.strokeEnd = self.strokeEnd;
    
    return layer;
    
}

-(JFPieLayerItem*)JFPieLayerItem{
    
    JFPieLayerItem* item = [[JFPieLayerItem alloc] init];
    
    item.fillColor = self.fillColor;
    
    item.strokeColor = self.strokeColor;
    
    item.lineWidth = self.lineWidth;
    item.miterLimit = self.miterLimit;
    
    item.lineCap = [DTGraphicsConverter lineCapFromCGLineCap:self.lineCapStyle];
    item.lineJoin = [DTGraphicsConverter lineJoinFromCGLineJoin:self.lineJoinStyle];
    
    item.fillRule = self.usesEvenOddFillRule ? kCAFillRuleEvenOdd : kCAFillRuleNonZero;
    
    NSInteger count;
    [self getLineDash:NULL count:&count phase:NULL];
    CGFloat pattern[count], phase;
    [self getLineDash:pattern count:NULL phase:&phase];
    
    NSMutableArray *lineDashPattern = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        [lineDashPattern addObject:@(pattern[i])];
    }
    
    item.lineDashPattern = [lineDashPattern copy];
    item.lineDashPhase = phase;
    
    item.strokeStart = self.strokeStart;
    
    item.strokeEnd = self.strokeEnd;
    
    return item;

    
}

@end

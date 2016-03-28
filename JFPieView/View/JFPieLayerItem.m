//
//  JFPieLayerItem.m
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import "JFPieLayerItem.h"
#import "JFPieShaperLayer.h"

@implementation JFPieLayerItem

-(JFPieShaperLayer*)JFPieShaperLayer{
    
    JFPieShaperLayer* layer = [[JFPieShaperLayer alloc] init];
    
    layer.fillColor = self.fillColor.CGColor;
    
    layer.strokeColor = self.strokeColor.CGColor;
    
    layer.lineWidth = self.lineWidth;
    layer.miterLimit = self.miterLimit;
    
    layer.lineCap = self.lineCap;
    layer.lineJoin = self.lineJoin;
    
    layer.fillRule = self.fillRule;
    

    layer.lineDashPattern = [self.lineDashPattern copy];
    layer.lineDashPhase = self.lineDashPhase;
    
    if(self.accent){
        [layer setAccentPrecent:0.1];
    }
    
    return layer;
}

-(JFPieShaperLayer*)JFPieOuterShaperLayer{
    
    JFPieShaperLayer* shaperLayer = [self JFPieShaperLayer];
    shaperLayer.fillColor = CGColorCreateCopyWithAlpha(shaperLayer.fillColor, 0.2);
    return shaperLayer;
    
}

@end

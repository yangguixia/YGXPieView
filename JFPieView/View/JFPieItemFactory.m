//
//  JFPieItemFactory.m
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import "JFPieItemFactory.h"
#import "JFPieLayerItem.h"

@implementation JFPieItemFactory

+(JFPieLayerItem*)defaultItem{
    
    JFPieLayerItem* item = [[JFPieLayerItem alloc] init];
    
    item.lineWidth = 1.0;
    //item.strokeColor = [UIColor redColor];
    
    item.fillColor = [UIColor blueColor];
    item.fillRule =  kCAFillRuleNonZero;
    
 //   item.miterLimit =
    
    item.sliceValue = 100;
    
    return item;
}

@end

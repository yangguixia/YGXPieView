//
//  JFPieShaperLayer.m
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import "JFPieShaperLayer.h"
#import "JFPieLayerItem.h"
#import "JFPiePath.h"
#import "JFPieShaperLayer.h"
#import "JFPieView.h"

@interface JFPieShaperLayer (){
    float temp_innerRadius;
    float temp_outerRadius;
    JFPieChartAnimationOptions preAnimationOptions;
}

@property (nonatomic) CGPoint accentVector;

@property (nonatomic) float endAngle;

@property (nonatomic) float accentValue;

@property (nonatomic) CGAffineTransform currentMatrix;

@end

@implementation JFPieShaperLayer

@synthesize value = _value;
@synthesize percentage = _percentage;

- (id)init{
    self = [super init];
    if(self){
        self.accent = NO;
        self.accentPrecent = 0.0;
        
        self.innerRadius = 0;
        self.endAnimationBlock = nil;
    }
    return self;
}

- (void) setAccentPrecent:(float)accentPrecent {
    _accentPrecent = accentPrecent;
    _accent = YES;
    [self update];
}

- (void) update {
    [self pieceAngle:_angle start:_startAngle];
}

- (void) pieceAngle:(float)angle start:(float)startAngle {
    _angle = angle;
    _endAngle = angle;
    _startAngle = startAngle;
    
    CGSize size = self.frame.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return;
    }
    
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    if (_innerRadius == 0) {
        _innerRadius = size.width/2;
    }
    
    self.accentValue = _innerRadius*_accentPrecent;
    
    // calculate vector of moving
    
    float calcAngle = angle+startAngle*2;
    int mod_x = 1;
    int mod_y = 1;
    
    if (calcAngle/2 > M_PI+M_PI_2) {
        mod_x = 1;
        mod_y = -1;
    } else if (calcAngle/2 > M_PI) {
        mod_x = -1;
        mod_y = -1;
    } else if (calcAngle/2 > M_PI_2) {
        mod_x = -1;
        mod_y = 1;
    }
    
    float x = center.x + _innerRadius*cos(calcAngle/2);
    float y = center.y + _innerRadius*sin(calcAngle/2);
    
    _accentVector = CGPointMake(center.x-x, center.y-y);
    _accentVector.x = fabs(_accentVector.x)*mod_x /_innerRadius;
    _accentVector.y = fabs(_accentVector.y)*mod_y /_innerRadius;
    
    
    if (_accent) {
        CGAffineTransform matrix = CGAffineTransformIdentity;
        matrix = CGAffineTransformMakeTranslation(center.x, center.y);
        //matrix = CGAffineTransformTranslate(matrix, _accentVector.x*_accentValue, _accentVector.y*_accentValue);
        matrix = CGAffineTransformTranslate(matrix,-center.x,-center.x);
        _currentMatrix = matrix;
        
    }
    
    if (startAngle > -.01 && angle > -.01) {
        _endAngle = startAngle+angle;
        [self __angle:_angle];
    }
}

- (void) __angle:(float)angle {
    _angle = angle;
    CGPathRef path = [self refreshPath];
    self.path = path;
    CGPathRelease(path);
}

- (void) __innerRadius:(float)radius {
    _innerRadius = radius;
    CGPathRef path = [self refreshPath];
    self.path = path;
    CGPathRelease(path);
}

- (void) __outerRadius:(float)radius {
    _outerRadius = radius;
    CGPathRef path = [self refreshPath];
    self.path = path;
    CGPathRelease(path);
}

- (void) setPath:(CGPathRef)path {
    [super setPath:path];
    
}


- (CGMutablePathRef) refreshPath {
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRelativeArc(path, &_currentMatrix, center.x, center.y, _innerRadius, _startAngle, _angle);
    CGPathAddRelativeArc(path, &_currentMatrix, center.x, center.y, _outerRadius, _startAngle+_angle , -_angle);
    CGPathCloseSubpath(path);
    return path;
}

- (void) setAnimationOptions:(JFPieChartAnimationOptions)options{
    preAnimationOptions = options;
    _animationOptions = options;
}

- (void) setAnimationDuration:(float)duration{
    
}

- (void) _animate {
    if (_animationOptions & JFPieChartAnimationFan || _animationOptions & JFPieChartAnimationFanAll) {
        [self createArcAnimationForKey:@"endAngle"
                             fromValue:[NSNumber numberWithFloat:0]
                               toValue:[NSNumber numberWithFloat:_angle]
                              delegate:self];
        [self __angle:0];
    }
    if (_animationOptions & JFPieChartAnimationGrowthBack || _animationOptions & JFPieChartAnimationGrowthBackAll) {
        temp_outerRadius = _outerRadius;
        [self createArcAnimationForKey:@"outerRadius"
                             fromValue:[NSNumber numberWithFloat:_innerRadius]
                               toValue:[NSNumber numberWithFloat:_outerRadius]
                              delegate:self];
        [self __outerRadius:_innerRadius];
    }
    
    if (_animationOptions & JFPieChartAnimationGrowth || _animationOptions & JFPieChartAnimationGrowthAll) {
        temp_innerRadius = _innerRadius;
        [self createArcAnimationForKey:@"innerRadius"
                             fromValue:[NSNumber numberWithFloat:_outerRadius]
                               toValue:[NSNumber numberWithFloat:_innerRadius]
                              delegate:self];
        [self __innerRadius:_outerRadius];
    }
    
    // Create a transaction just to disable implicit animations
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self setHidden:NO];
    [CATransaction commit];
}

- (void) createArcAnimationForKey:(NSString *)key fromValue:(NSNumber *)from toValue:(NSNumber *)to delegate:(id)delegate {
    CABasicAnimation *arcAnimation = [CABasicAnimation animationWithKeyPath:key];
    [arcAnimation setFromValue:from];
    [arcAnimation setToValue:to];
    if (_animationOptions & JFPieChartAnimationFanAll) {
        arcAnimation.duration = _animationDuration/((M_PI*2)/_angle);
    } else if (_animationOptions & JFPieChartAnimationGrowth || _animationOptions & JFPieChartAnimationGrowthBack) {
        arcAnimation.duration = _animationDuration/(float)[[self.superlayer sublayers] count];
    } else if (_animationOptions & JFPieChartAnimationGrowthAll || _animationOptions & JFPieChartAnimationGrowthBackAll) {
        arcAnimation.duration = _animationDuration;
    } else if (_animationOptions & JFPieChartAnimationFan) {
        arcAnimation.duration = _animationDuration;
    }
    
    [arcAnimation setDelegate:delegate];
    
    if (_animationOptions & JFPieChartAnimationTimingEaseIn) {
        [arcAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    } else if (_animationOptions & JFPieChartAnimationTimingEaseOut) {
        [arcAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    } else if (_animationOptions & JFPieChartAnimationTimingEaseInOut) {
        [arcAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    } else {
        [arcAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    }
    
    [self addAnimation:arcAnimation forKey:key];
    [self setValue:to forKey:key];
}

+ (BOOL) needsDisplayForKey:(NSString*)key {
    if ([key isEqualToString:@"endAngle"] || [key isEqualToString:@"startAngle"] || [key isEqualToString:@"innerRadius"]|| [key isEqualToString:@"outerRadius"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (void) drawInContext:(CGContextRef)ctx {
    
    CAAnimation *arcAnimation = [self animationForKey:@"endAngle"];
    if (arcAnimation) {
        _angle = _endAngle;
        JFPieShaperLayer *p = arcAnimation.delegate;
        [p __angle:_endAngle];
    }
    
    arcAnimation = [self animationForKey:@"innerRadius"];
    if (arcAnimation) {
        JFPieShaperLayer *p = arcAnimation.delegate;
        [p __innerRadius:_innerRadius];
    }
    
    arcAnimation = [self animationForKey:@"outerRadius"];
    if (arcAnimation) {
        JFPieShaperLayer *p = arcAnimation.delegate;
        [p __outerRadius:_outerRadius];
    }
}



- (void) animationDidStart:(CAAnimation *)anim { }

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([((CABasicAnimation*)anim).keyPath isEqualToString:@"endAngle"]) {
        [self __angle:_endAngle];
    }
    if ([((CABasicAnimation*)anim).keyPath isEqualToString:@"innerRadius"] && flag) {
        [self __innerRadius:temp_innerRadius];
        self.animationOptions = preAnimationOptions;
    }
    if ([((CABasicAnimation*)anim).keyPath isEqualToString:@"outerRadius"] && flag) {
        [self __outerRadius:temp_outerRadius];
    }
    
    if (_endAnimationBlock != nil) {
        _endAnimationBlock();
        _endAnimationBlock = nil;
    }
}

- (JFPiePath*) he_JFPiePath{
    
    JFPiePath * path = (JFPiePath *)[JFPiePath bezierPathWithCGPath:self.path];
    
    path.lineWidth = self.lineWidth;
    path.miterLimit = self.miterLimit;
    
    path.lineCapStyle = [DTGraphicsConverter lineCapFromCALineCap:self.lineCap];
    path.lineJoinStyle = [DTGraphicsConverter lineJoinFromCALineJoin:self.lineJoin];
    
    path.usesEvenOddFillRule = (self.fillRule == kCAFillRuleEvenOdd);
    
    CGFloat phase = self.lineDashPhase;
    NSInteger count = self.lineDashPattern.count;
    CGFloat pattern[count];
    for (NSUInteger i = 0; i < count; i++) {
        pattern[i] = [[self.lineDashPattern objectAtIndex:i] floatValue];
    }
    [path setLineDash:pattern count:count phase:phase];
    
    
    path.strokeColor = [UIColor colorWithCGColor:self.strokeColor];
    
    path.fillColor = [UIColor colorWithCGColor:self.fillColor];
    
    path.strokeStart = self.strokeStart;
    
    path.strokeEnd = self.strokeEnd;
    
    return path;
}

- (JFPieLayerItem*)he_JFPieLayerItem{
    JFPieLayerItem* item = [[JFPieLayerItem alloc] init];
    
    item.fillColor = [UIColor colorWithCGColor:self.fillColor];
    
    item.strokeColor = [UIColor colorWithCGColor:self.strokeColor];
    
    item.lineWidth = self.lineWidth;
    item.miterLimit = self.miterLimit;
    
    item.lineCap = self.lineCap;
    item.lineJoin = self.lineJoin;
    
    item.fillRule = self.fillRule;
    
    item.lineDashPattern = [self.lineDashPattern copy];
    item.lineDashPhase = self.lineDashPhase;
    
    item.strokeStart = self.strokeStart;
    
    item.strokeEnd = self.strokeEnd;
    
    return item;
    

}

- (BOOL) containsPoint:(CGPoint)point {
    return CGPathContainsPoint(self.path, NULL, point, false);
}

- (void)animateChangesInnerRadius:(CGFloat)innerRadius{
    
    preAnimationOptions = _animationOptions;
    
    [self __innerRadius:_innerRadius];
    _animationOptions = JFPieChartAnimationGrowth;
    CGFloat preInnerRadius = _innerRadius;
    
    _innerRadius = innerRadius;
    temp_innerRadius = _innerRadius;
    [self createArcAnimationForKey:@"innerRadius"
                         fromValue:[NSNumber numberWithFloat:preInnerRadius]
                           toValue:[NSNumber numberWithFloat:_innerRadius]
                          delegate:self];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self setHidden:NO];
    [CATransaction commit];
}


@end

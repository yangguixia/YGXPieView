//
//  JFPieView.m
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import "JFPieView.h"
#import "JFPieShaperLayer.h"
#import "JFPieLayerItem.h"
#import "AYRotationGestureRecognizer.h"

#define kOuterSideMark   @"outSideLayer"

@interface JFPieView ()

@property(nonatomic,strong)UIView* pieView;

@property(nonatomic,strong)AYRotationGestureRecognizer* rotationRecognizer;

@property (nonatomic, assign) CGFloat rotation;

@end

@implementation JFPieView

@synthesize startAngle = _startAngle;
@synthesize pieCenter = _pieCenter;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor blueColor];
        
        _selectedSliceIndex = -1;
        
        self.hasOutSideLayer = YES;
        
        self.standardPoint = M_PI/2*3;
        
        self.startAngle = 0;
        self.length = M_PI*2;
        self.holeRadius = 0;
        
        _animationOptions = JFPieChartAnimationFanAll | JFPieChartAnimationTimingLinear;
        
        self.pieView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2 - MIN(frame.size.width, frame.size.height)/2, CGRectGetHeight(frame)/2 - MIN(frame.size.width, frame.size.height)/2, MIN(frame.size.width, frame.size.height), MIN(frame.size.width, frame.size.height))];
        
        self.pieView.backgroundColor = [UIColor blackColor];
        self.pieView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        self.pieView.layer.cornerRadius = CGRectGetHeight(self.pieView.frame)/2;
        
        [self addSubview:self.pieView];
        
        self.outsideWidth = 5;
        self.outSideColor = [UIColor grayColor];

        self.radius = MIN(frame.size.width/2, frame.size.height/2) - self.outsideWidth;
        _pieCenter = CGPointMake(_pieView.frame.size.width/2, _pieView.frame.size.height/2);
        
        [self setupTagGustrueRecognizer];
        [self setupRotationGustrueRecognizer];
        
        [self addDirectLayer];
    }
    return self;
}

- (void)addDirectLayer{
    CALayer* layer = [CALayer layer];
    //layer.backgroundColor = [UIColor redColor].CGColor;
   
    layer.contents =  (id)[[UIImage imageNamed:@"指向"] CGImage];
    layer.position = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    layer.bounds = CGRectMake(0, 0, 50, 60);
    [self.layer addSublayer:layer];
    
}

- (void)setupRotationGustrueRecognizer{
    self.rotationRecognizer = [[AYRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationRecognized:)];
    __weak __typeof(self)weakSelf = self;
    self.rotationRecognizer.endRotation = ^(){
        NSLog(@"旋转结束");
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf toStandardPoint];
        });
        
    };
                               
    [self.pieView addGestureRecognizer:self.rotationRecognizer];
}

- (void)rotationRecognized:(AYRotationGestureRecognizer *)gesture{
    CGFloat velocity = [gesture velocity];
    if (velocity != 0) {
        [self drawVelocityAnimation:velocity
                  timeSinceLastStep:0
                          clockwise:gesture.velocityIsClockwise];
    }
    [self rotateWithRadians:gesture.rotationInRadians];
    
}

- (void)drawVelocityAnimation:(CGFloat)velocity
            timeSinceLastStep:(NSUInteger)timeSinceLastStep
                    clockwise:(BOOL)isClockwise {
    if (velocity < 0.01) {
        return;
    }
    long long startTime = [self currentTimeInMilliseconds];
    if (timeSinceLastStep == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger step = (NSUInteger)([self currentTimeInMilliseconds] - startTime);
            [self drawVelocityAnimation:velocity
                      timeSinceLastStep:step
                              clockwise:isClockwise];
        });
    } else {
        [self rotateWithRadians:(velocity * timeSinceLastStep * (isClockwise ? 1 : -1)) * M_PI / 180];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger step = (NSUInteger)([self currentTimeInMilliseconds] - startTime);
            [self drawVelocityAnimation:velocity * 0.95
                      timeSinceLastStep:step
                              clockwise:isClockwise];
        });
    }
}

- (long long)currentTimeInMilliseconds {
    return (long long)floor([[NSDate date] timeIntervalSince1970] * 1000.0);
}

- (void)rotateWithRadians:(CGFloat)angleRadians {
    CGFloat angleInDegrees = angleRadians * 180 / M_PI;
    _rotation += angleInDegrees;
    _rotation = fmodf(_rotation, 360);
    //NSLog(@"rotation:%f",angleRadians);
    [self reloadData];
}

- (void)setupTagGustrueRecognizer{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.pieView addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer*)tap
{
    if(tap.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint pos = [tap locationInView:tap.view];
    
    NSInteger index = 0;
    
    for(CALayer* layer in self.pieView.layer.sublayers){
        if(![layer isKindOfClass:[JFPieShaperLayer class]]){
            continue;
        }
        
        JFPieShaperLayer* tappedLayer = (JFPieShaperLayer*)layer;
        
        NSString* outSideLayerMark = [tappedLayer valueForKeyPath:kOuterSideMark];
        if([outSideLayerMark isEqualToString:@"0"]){
            continue;
        }
        
        if ([tappedLayer containsPoint:pos]) {
//            _selectedSliceIndex = index;
//            [self animateChanges];
            self.selectedSliceIndex = index;
            break;
        }
        
        index++;
    }
    
}

- (void)animateChanges{
    
    
    [self autoRotationToIndex:_selectedSliceIndex];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger index = 0;
        for(CALayer* layer in self.pieView.layer.sublayers){
            if(![layer isKindOfClass:[JFPieShaperLayer class]]){
                continue;
            }
            
            JFPieShaperLayer* tappedLayer = (JFPieShaperLayer*)layer;
            
            NSString* outSideLayerMark = [tappedLayer valueForKeyPath:kOuterSideMark];
            if([outSideLayerMark isEqualToString:@"0"]){
                continue;
            }
            
            if (index == self.selectedSliceIndex) {
                
                if(tappedLayer.innerRadius >= CGRectGetWidth(self.pieView.frame)/2){
                    [tappedLayer animateChangesInnerRadius:tappedLayer.innerRadius - self.outsideWidth];
                }else{
                    [tappedLayer animateChangesInnerRadius:tappedLayer.innerRadius + self.outsideWidth];
                }
                
            }else{
                [tappedLayer animateChangesInnerRadius:self.radius];
            }
            
            index++;
        }
        
    });
}

- (void)setOutsideWidth:(CGFloat)outsideWidth{
    _outsideWidth = outsideWidth;
    
    self.radius = MIN(self.pieView.frame.size.width/2, self.pieView.frame.size.height/2) - self.outsideWidth;
    
    [self reloadData];
    
}

- (void)setOutSideColor:(UIColor *)outSideColor{
    
    self.pieView.layer.backgroundColor = [outSideColor CGColor];
    
}

- (void)reloadData{
    
    if(self.dataSource == nil){
        return;
        
    }
    // Clean old layers
    NSArray *arraySublayers = [NSArray arrayWithArray:self.pieView.layer.sublayers];
    for (CALayer *l in arraySublayers) {
        [l removeFromSuperlayer];
    }
    arraySublayers = nil;
    
    // init temp variables
    CGRect rect = CGRectMake(0, 0, self.pieView.frame.size.width, self.pieView.frame.size.height);
    double fullValue = 0;
    
    NSInteger count = [self.dataSource numberOfSlicesInJFPieView:self];
    
    for(NSInteger itemIndex = 0;itemIndex < count;itemIndex++){
        JFPieLayerItem* item = [self.dataSource pieView:self dataItemAtIndex:itemIndex];
        
        if(item){
            fullValue += fabsf(item.sliceValue);
        }
    }
    
    
    CGFloat onePrecent = fullValue*0.01;
    CGFloat onePrecentOfChart = _length*0.01;
    double start = _startAngle;
    
    if (_rotation > 0) {
        start += (-360 + _rotation) * M_PI / 180;
    } else {
        start += _rotation * M_PI / 180;
    }
    
    while (start > M_PI*2) {
        start  -= M_PI*2;
    }
    
    if(start < 0){
        start += M_PI*2;
    }
    
    for(NSInteger itemIndex = 0;itemIndex<count;itemIndex++){
        JFPieLayerItem* item = [self.dataSource pieView:self dataItemAtIndex:itemIndex];
        
        if(item == nil){
            continue;
        }
        
        CGFloat pieceValuePrecents = fabs(item.sliceValue)/onePrecent;
        CGFloat pieceChartValue = onePrecentOfChart*pieceValuePrecents;
        
        if (pieceChartValue == 0) {
            continue;
        }
        
        if(self.hasOutSideLayer){
            JFPieShaperLayer* outSideLayer = [item JFPieOuterShaperLayer];
            //[outSideLayer setValue:@"0" forKey:@"outSideLayer"];
            [outSideLayer setValue:@"0" forKeyPath:kOuterSideMark];
            [outSideLayer setFrame:rect];
            [outSideLayer setValue:pieceValuePrecents];
            [outSideLayer setInnerRadius:self.radius+self.outsideWidth];
            [outSideLayer setOuterRadius:self.radius];
            [outSideLayer pieceAngle:pieceChartValue start:start];
            if (_presentWithAnimation) {
                [outSideLayer setHidden:YES];
            }
            [outSideLayer setAnimationDuration:_animationDuration];
            [outSideLayer setAnimationOptions:_animationOptions];
            
            [self.pieView.layer addSublayer:outSideLayer];
        }
        
        JFPieShaperLayer* piece = [item JFPieShaperLayer];
        
        [piece setFrame:rect];
        
        [piece setValue:pieceValuePrecents];
        
        [piece setInnerRadius:_radius];
        [piece setOuterRadius:_holeRadius];
        
        [piece pieceAngle:pieceChartValue start:start];
        
        if (_presentWithAnimation) {
            [piece setHidden:YES];
        }
        [piece setAnimationDuration:_animationDuration];
        [piece setAnimationOptions:_animationOptions];
        
        [self.pieView.layer addSublayer:piece];
        
        start += pieceChartValue;
    }
}


- (void)rotateToRadians:(CGFloat)angleRadians {
    CGFloat angleInDegrees = angleRadians * 180 / M_PI;
    _rotation = angleInDegrees;
    _rotation = fmodf(_rotation, 360);
    [self reloadData];
}

- (void)autoRotationToIndex:(NSInteger)toIndex{

    NSInteger serchIndex = 0;
    
    float preAngleCount = 0;
    
    for(CALayer* layer in self.pieView.layer.sublayers){
        if(![layer isKindOfClass:[JFPieShaperLayer class]]){
            continue;
        }
        
        JFPieShaperLayer* tappedLayer = (JFPieShaperLayer*)layer;
        
        NSString* outSideLayerMark = [tappedLayer valueForKeyPath:kOuterSideMark];
        if([outSideLayerMark isEqualToString:@"0"]){
            continue;
        }
        
        if (serchIndex == self.selectedSliceIndex) {
            
            //根据当前的layer 计算出将当前layer正向的话    画整个饼图的真实位置
            float startAngle = [tappedLayer startAngle];
            float angle = [tappedLayer angle];
            float resultStartAngle = startAngle;
            resultStartAngle = self.standardPoint - angle/2 - preAngleCount;
            [self rotateToRadians:resultStartAngle];
            break;
        }
        preAngleCount += [tappedLayer angle];
        serchIndex++;
    }
}

- (CGFloat)distanceBetween:(CGPoint)first and:(CGPoint)second {
    CGFloat xDist = (second.x - first.x);
    CGFloat yDist = (second.y - first.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (CGFloat)angleBetweenFirstPoint:(CGPoint)first
                      secondPoint:(CGPoint)secondPoint
                           center:(CGPoint)center {
    return atan2f(first.y - center.y, first.x - center.x) -
    atan2f(secondPoint.y - center.y, secondPoint.x - center.x);
}

- (void)toStandardPoint{
    
    NSInteger index = 0;
    
    NSInteger selectIndex = index;
    
    float x = cosf(_standardPoint) * [self distanceBetween:_pieCenter and:CGPointMake(_pieCenter.x +15, _pieCenter.y)] + _pieCenter.x;
    float y = sinf(_standardPoint) * [self distanceBetween:_pieCenter and:CGPointMake(_pieCenter.x +15, _pieCenter.y)] + _pieCenter.y;

    CGPoint point = CGPointMake(x, y);
    
    for(CALayer* layer in self.pieView.layer.sublayers){
        if(![layer isKindOfClass:[JFPieShaperLayer class]]){
            continue;
        }
        
        JFPieShaperLayer* tappedLayer = (JFPieShaperLayer*)layer;
        
        NSString* outSideLayerMark = [tappedLayer valueForKeyPath:kOuterSideMark];
        if([outSideLayerMark isEqualToString:@"0"]){
            continue;
        }
        
        if([tappedLayer containsPoint:point]){
            selectIndex = index;
            break;
        }
        
        index++;
        
    }
    self.selectedSliceIndex = selectIndex;
//    _selectedSliceIndex = selectIndex;
//    [self animateChanges];
}

- (void)setSelectedSliceIndex:(NSInteger)selectedSliceIndex{
    
    _selectedSliceIndex = selectedSliceIndex;
    if(self.delegate && [self.delegate respondsToSelector:@selector(pieView:willSelectIndex:)]){
        [self.delegate pieView:self willSelectIndex:_selectedSliceIndex];
    }
    
    [self animateChanges];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(pieView:didSelectIndex:)]){
            [self.delegate pieView:self didSelectIndex:_selectedSliceIndex];
        }
    });
}

@end

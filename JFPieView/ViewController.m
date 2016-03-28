//
//  ViewController.m
//  JFPieView
//
//  Created by 秦山 on 15-5-17.
//  Copyright (c) 2015年 dfhe. All rights reserved.
//

#import "ViewController.h"

#import "JFPieView.h"
#import "JFPieLayerItem.h"
#import "JFPieItemFactory.h"

@interface ViewController ()<JFPieViewDataSource,JFPieViewDelegate>

@property(nonatomic,strong)JFPieView* pieView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.pieView = [[JFPieView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.view.frame) - 40, CGRectGetHeight(self.view.frame))];
    self.pieView.dataSource = self;
    self.pieView.delegate = self;
    
    [self.view addSubview:self.pieView];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.pieView reloadData];
    self.pieView.selectedSliceIndex = 0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfSlicesInJFPieView:(JFPieView*)pieView{
    return 3;
}

- (JFPieLayerItem*)pieView:(JFPieView *)pieChart dataItemAtIndex:(NSUInteger)index{
    
    JFPieLayerItem* item = [JFPieItemFactory defaultItem];
    
    switch (index) {
        case 0:{
            item.sliceValue = 60;
            item.fillColor = [UIColor redColor];
            break;
        }
            
        case 1:{
            item.sliceValue = 10;
            item.fillColor = [UIColor orangeColor];
            break;
        }
            
        case 2:{
            item.sliceValue = 30;
            item.fillColor = [UIColor greenColor];
            break;
        }
        case 3:{
            item.sliceValue = 30;
            item.fillColor = [UIColor blackColor];
            break;
        }
        default:
            break;
    }
    return item;
}


- (void)pieView:(JFPieView *)pieChart  willSelectIndex:(NSUInteger)index{
    NSLog(@"将要进入饼状%lu",(unsigned long)index);
}

- (void)pieView:(JFPieView *)pieChart didSelectIndex:(NSUInteger)index{
    NSLog(@"进入饼状%lu",(unsigned long)index);
}

@end

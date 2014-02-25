//
//  ViewController.m
//  ConfigurableAnimation
//
//  Created by huji on 9/6/13.
//  Copyright (c) 2013 BaiduLBSMapClient. All rights reserved.
//

#import "ViewController.h"
#import "ConfigurableGuideView.h"

@interface ViewController ()

@end

@implementation ViewController{
    ConfigurableGuideView *guideview;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    guideview =[[ConfigurableGuideView alloc] initWithFrame:self.view.bounds plistName:@"animation"];
    [self.view addSubview:guideview];
    [self.view sendSubviewToBack:guideview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

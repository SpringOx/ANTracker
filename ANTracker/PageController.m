//
//  PageController.m
//  ANTracker
//
//  Created by SpringOx on 14/11/8.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "PageController.h"
#import "ANConstants.h"

@interface PageController ()

@end

@implementation PageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 页面的进入统计例子，springox(20141108)
    [ANTrackServer trackPageBegin:NSStringFromClass([self class])];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 页面的退出统计例子，springox(20141108)
    [ANTrackServer trackPageEnd:NSStringFromClass([self class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didPressReturnButtonAction:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

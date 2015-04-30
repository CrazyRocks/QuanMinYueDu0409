//
//  LYAudioController.m
//  TheReading
//
//  Created by grenlight on 12/22/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import "LYAudioController.h"

@interface LYAudioController ()

@end

@implementation LYAudioController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)comeback:(id)sender
{
    if (self.returnToPreController) {
        self.returnToPreController();
    }
    else
        [super comeback:sender];
}


@end

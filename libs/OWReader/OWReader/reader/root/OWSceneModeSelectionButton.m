//
//  OWSceneModeSelectionButton.m
//  OWReader
//
//  Created by grenlight on 15/1/25.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "OWSceneModeSelectionButton.h"
#import <OWKit/OWColor.h>

@interface OWSceneModeSelectionButton()
{
    CALayer *cycleLayer;
}

@end

@implementation OWSceneModeSelectionButton

- (void)setSceneName:(NSString *)sceneName
{
    _sceneName = sceneName;
    self.backgroundColor = [UIColor clearColor];
    if (!cycleLayer) {
        UIView *layerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        layerView.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
        cycleLayer = layerView.layer;
        [self.layer addSublayer:cycleLayer];
    }
    cycleLayer.backgroundColor = [OWColor colorWithHexString:[NSString stringWithFormat:@"#%@", _sceneName]].CGColor;
    cycleLayer.borderColor = [OWColor colorWithHexString:@"#eeffffff"].CGColor;
    cycleLayer.cornerRadius = 10;

    self.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        cycleLayer.borderWidth = 2;
    }
    else {
        cycleLayer.borderWidth = 0;
    }
}

@end

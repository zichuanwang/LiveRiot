//
//  CRTabBar.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-11.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "CRTabBar.h"

@interface CRTabBar ()

@property (nonatomic, strong) CALayer *colorLayer;

@end

@implementation CRTabBar

static CGFloat const kDefaultColorLayerOpacity = 0.8f;

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    
    if (self.colorLayer == nil) {
        self.colorLayer = [CALayer layer];
        self.colorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer addSublayer:self.colorLayer];
    }
    
    self.colorLayer.backgroundColor = barTintColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.colorLayer != nil) {
        self.colorLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        [self.layer insertSublayer:self.colorLayer atIndex:1];
    }
}

@end

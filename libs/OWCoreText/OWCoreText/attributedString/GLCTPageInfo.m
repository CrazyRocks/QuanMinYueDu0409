//
//  GLCTPageInfo.m
//  GLFunction
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "GLCTPageInfo.h"

@implementation GLCTPageInfo
@synthesize lines, location, lenght, pageNumber, description, isBookmark, imagePath;
@synthesize catIndex;


-(void)dealloc{
    
//    NSLog(@"GLCTPageInfo dealloc %i, %i, %i  image:%@",pageNumber,location,lenght,imagePath);
    lines = nil;

}
@end

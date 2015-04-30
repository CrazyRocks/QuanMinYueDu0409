//
//  MagSearchResultControllerViewController.h
//  PublicLibrary
//
//  Created by grenlight on 13-12-7.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <OWKit/OWKit.h> 

@class LYSearchManager, OWActivityIndicatorView;
@interface MagSearchResultController : OWCommonTableViewController<UITextFieldDelegate>
{
    NSString *searchKey;
    LYSearchManager *searchManager;
    AFHTTPRequestOperation  *currentRequest;
    
    //搜索第一个关键字符时得到的结果，后面的搜索直接由它过滤得出
    NSArray     *originalData;
    //正在从服务器端搜索中
    BOOL        isInWebSearching;
    //是否要过滤搜索结果?如果远程搜索时，关键字长度发生了变化（没有重新输入关键字），则要在远程结果返回时进行过滤
    BOOL        needFilterResult;
    
    CADisplayLink *displayLink;
    IBOutlet UITextField    *searchField;
    
    IBOutlet UIButton   *searchButton;
    
    UIStyleObject       *listStyle;
    
    NSMutableArray      *searchKeys;
    
    NSNumber    *searchCount;

}
//0: 杂志， 1：图书
@property (nonatomic, assign) NSInteger searchType;

-(void)beginSearch:(NSString *)keywords;

@end

//
//  LYBarcodeResultViewController.h
//  LYBookStore
//
//  Created by grenlight on 14-3-26.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWKit.h>

#define BOOK_DETAIL_HTML    @"<!doctype html>\
<html lang=\"zh-CN\">\
<head><meta charset=\"utf-8\" />\
<style>\
html{margin:0px; padding:0px; background-color:#f9f8f8;}\
figure{margin:0px; padding:0px;}\
img{width:298px; height:auto; margin-left:0px }\
p{margin:0px 0px 2px 0px; padding:0px;}\
div{margin:0px; padding:0px;}\
</style>\
</head>\
\
<body style=\"text-align:justify;margin:0px; padding:0px \
background-color:#f9f8f8; word-wrap:break-word;\">\
<div style='background-color:#f9f8f8; width:100%'>\
%@\
</div>\
<div style='float:clear;'></div>\
<div style='padding:10px 15px 40px 15px;line-height:24px;font-size:14px;font-family:FZLTXHK--GBK1-0; color:#252525;width:100%;float:left'>\
<p style='font-size:14px;color:black'>导言</p>\
%@\
</div>\
</body></html>"

@class LYEpubDownloadButton;

@interface LYBookDetailController : XibAdaptToScreenController
{
    IBOutlet UIWebView   *webView;
    IBOutlet UIButton    *messageBT;
    IBOutlet OWBundleButton   *backButton;
    
    IBOutlet UIView     *headerView;
    
    IBOutlet LYEpubDownloadButton   *downloadButton;
}

@property (nonatomic, strong) NSString *bookGUID;
@property (nonatomic, strong) NSDictionary *contentInfo;

@end

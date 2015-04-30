//
//  ArticleDetailController.h
//  GoodSui
//
//  Created by 龙源 on 13-7-25.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleViewController.h"

#define HTML_CONTENT    @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\
<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"zh-CN\">\
<head>\
<meta charset=\"gbk\" />\
<style>\
html{margin:0px; padding:0px; }\
figure{margin:0px; padding:0px;}\
img{width:%fpx; height:auto; margin:0px; }\
p,div{margin:0px 0px 10px 0px; padding:0px; text-indent:2em;}\
</style>\
</head>\
\
<body style=\"text-align:left; padding:12px 12px 30px 12px; overflow:hidden; \
background-color:#F6F5EF; color:#000000; font-color:#000000; font-family:'FZLTXHK--GBK1-0'\">\
\
<header style='margin-top:60px;margin-bottom:20px'>\
<h3 style='font-size:20px;padding:0px;margin:0px'>%@</h3>\
<h5 style='padding:0px;margin:0px;margint-top:-5px;font-size:12px;color:#666666'>%@</h5>\
</header>\
\
%@\
<div style=\"margin-top:20px;color:#252525;font-size:%fpx;line-height:%fpx\" >%@</div>\
\
<script>\
var imgs = document.getElementsByTagName('img');\
for (var i=0;i<imgs.length; i++) {\
    imgs[i].onclick=function(){\
        WebViewJavascriptBridge.callHandler('fullScreen',this.getAttribute('src'), function(){})\
    }\
}\
</script>\
</body></html>"


#import <LYService/LYService.h>
#import <OWKit/OWKit.h>


@interface ArticleDetailController : XibAdaptToScreenController<UIWebViewDelegate>
{
    __weak IBOutlet UIWebView   *webView;
    
    NSNumber    *articleID;
            
    LYArticleTableCellData          *currentArticle;
    ArticleDetailReaderStatus      currentState;
    
    //保持当前文章，用于调整字体时再次使用
    LYArticle                               *articleDetail;

    NSString           *headerHTML, *contentHTML;    

}
@property (nonatomic,assign) id<PageViewDelegate> delegate;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint contentOffset;

-(void)setPagePosition:(CGRect )rect ;
-(void)setArticle:(LYArticleTableCellData *)article;

//下载文章并呈现
-(void)loadArticle;

-(void)fontSizeChange;

-(NSString *)getArticleWebURL;

- (void)limitHorizontalScroll;

- (void)clearContent;

@end

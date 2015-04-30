

#import <Foundation/Foundation.h>




@class Catalogue;

typedef enum{
    gFontScale_Small,
    gFontScale_Normal,
    gFontScale_Large
    
}GLFontSize;

//在frames中存在的frame的索引范围
struct RenderedFrameRange{
    uint startPoint;
    uint endPoint;
};

@interface BSGlobalAttri : NSObject {
    
}

@property(nonatomic,retain)NSString *lyFont;//字体名称
@property(nonatomic,retain)NSString *cacheDirectory;

@property(nonatomic,retain)UIFont *catFont;//目录的字体

//图片Y轴上的边距,用于在CoreText视图中绘制合适位置的图片
@property(nonatomic)float imageEdgeY;

//全局字体大小
@property(nonatomic)GLFontSize fontScale;
//页面文字区尺寸
@property(nonatomic)CGRect textRect;
@property(nonatomic, assign)UIEdgeInsets textInsets;

//总页面数
@property(nonatomic)uint pageCount;
@property(nonatomic)uint currentPage;
//当前章节
@property(nonatomic,retain)Catalogue *currentCatalogue;
//保持在frames中存在的frame的索引范围,用于在翻页时计算何时加载下/上一章节
@property(nonatomic)struct RenderedFrameRange frameRange;


+(BSGlobalAttri *) sharedInstance;


@end

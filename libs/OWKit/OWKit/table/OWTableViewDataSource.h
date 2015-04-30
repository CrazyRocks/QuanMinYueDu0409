

#import <Foundation/Foundation.h>


typedef void (^TableViewCellConfigureBlock)(id cell, id item, NSIndexPath *indexPath);

@protocol OWTableViewDataSourceDelegate <NSObject>

@required
- (void)dataSourceDelete:(NSIndexPath *)indexPath;

@end

@interface OWTableViewDataSource : NSObject <UITableViewDataSource>
{
    
}
@property (nonatomic, assign) id<OWTableViewDataSourceDelegate> delegate;

@property (nonatomic, assign) BOOL isGroupStyle;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, strong) NSMutableArray *sections;

- (id)initWithItems:(NSArray *)anItems
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;


- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end

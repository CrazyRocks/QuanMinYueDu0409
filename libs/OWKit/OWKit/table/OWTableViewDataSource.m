
#import "OWTableViewDataSource.h"


@implementation OWTableViewDataSource

- (id)initWithItems:(NSArray *)anItems
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc] initWithArray:anItems];
        self.configureCellBlock = [aConfigureCellBlock copy];

        if (anItems && anItems.count > 0 &&
            ([self.items[0] isKindOfClass:[[@[@""] mutableCopy] class]] ||
             [self.items[0] isKindOfClass:[NSArray class]]||
             [self.items[0] isKindOfClass:[NSMutableArray class]]))
            self.isGroupStyle = YES;
        else
            self.isGroupStyle = NO;
        
    }
    return self;
}

- (void)dealloc
{
    [self.items removeAllObjects];
    self.items = nil;
    [self.sections removeAllObjects];
    self.sections = nil;
    
    self.configureCellBlock = nil;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isGroupStyle)
        return ((NSArray *)self.items[indexPath.section])[indexPath.row];
    else
        return self.items[indexPath.row];
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.items) {
        return 0;
    }
    
    if (self.isGroupStyle)
        return self.items.count;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.items || self.items.count == 0) {
        return 0;
    }
    
    if (self.isGroupStyle)
        return ((NSArray *)self.items[section]).count;
    else
        return self.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!self.items || self.items.count == 0) {
        return nil;
    }
    
    if (self.isGroupStyle)
        return self.sections[section];
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    //这个方法要6.0才支持
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item, indexPath);
    return cell;
}


@end

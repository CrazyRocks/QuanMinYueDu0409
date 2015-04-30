//
//  KWFBootItemData.m
//  OWReader
//
//  Created by gren light on 12-11-3.
//
//

#import "LYBookItemData.h"
#import "LYBookHelper.h"

@implementation LYBookItemData

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}



- (void)setName:(NSString *)name
{
    _name = name;
    self.bGUID = [LYBookHelper generateBookGUID:_name];
}

@end

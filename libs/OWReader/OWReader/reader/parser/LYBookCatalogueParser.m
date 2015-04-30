//
//  ConvertCategory.m
//  DragonSourceReader
//
//  Created by  on 11-12-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LYBookCatalogueParser.h"
//#import <libxml/xmlmemory.h>
//#import <libxml/tree.h>
//#import <libxml/parser.h>
#import <OWCoreText/HTMLParser.h>
#import <OWCoreText/HTMLNode.h>
#import "BSCoreDataDelegate.h"
#import "Catalogue.h"
#import "BSConfig.h"
#import "MyBooksManager.h"

@interface LYBookCatalogueParser()
{
    NSInteger code, depth ;
    NSInteger index;
    NSString *tagName;
}
-(void)parseNode:(HTMLNode *)node withNavParam:(NSInteger)navParam parentNav:(NSInteger)pv depth:(NSInteger)dp;
-(void)saveCatalogue:(NSInteger)cID whithName:(NSString *)name filePosition:(NSString *)pos nav:(NSInteger)navIndex depth:(NSInteger)dp ;
@end


@implementation LYBookCatalogueParser

static const BSCoreDataDelegate *cd ;

-(void)parse
{
    cd = [BSCoreDataDelegate sharedInstance];
    MyBook  *book = [MyBooksManager sharedInstance].currentReadBook;
    
    NSString *readmePath;
    NSFileManager *fmanager = [NSFileManager defaultManager];

    if (book.opsPath == nil || [book.opsPath isEqualToString:@""]) {
        readmePath = [[cd cacheDocumentsDirectory] stringByAppendingString:
                                [NSString stringWithFormat:@"/%@/OPS/toc.ncx", book.bookID]];
        
        if (![fmanager fileExistsAtPath:readmePath]) {
            readmePath = [[cd cacheDocumentsDirectory] stringByAppendingString:
                          [NSString stringWithFormat:@"/%@/OEBPS/toc.ncx", book.bookID]];
            if (![fmanager fileExistsAtPath:readmePath]) {
                readmePath = [[cd cacheDocumentsDirectory] stringByAppendingString:
                              [NSString stringWithFormat:@"/%@/OPS/fb.ncx", book.bookID]];
                if (![fmanager fileExistsAtPath:readmePath]) {
                    readmePath = [[cd cacheDocumentsDirectory] stringByAppendingString:
                                  [NSString stringWithFormat:@"/%@/OEBPS/fb.ncx", book.bookID]];
                    
                }
            }
        }
    }
    else {
        readmePath = [[cd cacheDocumentsDirectory] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@/%@/%@", book.bookID,book.opsPath, book.catPath]];
    }
    
    NSLog(@"readmePath ===== %@",readmePath);
    
//	NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
    NSString *html = [[MyBooksManager sharedInstance] decryptFile:readmePath];
    NSError *error;    
    HTMLParser *parser = [[HTMLParser alloc]initWithString:html error:&error ];
    HTMLNode *root = [[parser body] findChildWithTag:@"navmap"];
    index = 0;
    [self parseNode:root withNavParam:1000000 parentNav:0 depth:0  ];
}

-(void)parseNode:(HTMLNode *)node withNavParam:(NSInteger)navParam parentNav:(NSInteger)pv  depth:(NSInteger)dp
{
    NSArray *fcArray =[node children];
    NSInteger navIndex = 1;

    for (NSInteger i = 0; i<fcArray.count; i++) {
        HTMLNode *nd = fcArray[i];
        if([nd.tagName isEqualToString:@"navpoint"]){
            NSString *cName = [[nd findChildWithTag:@"navlabel"] allContents];
            cName = [cName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            HTMLNode *cnt = [nd findChildWithTag:@"content"];
            NSInteger currentNav = pv+navParam*(navIndex);
            NSString *filePath = [cnt getAttributeNamed:@"src"];
            filePath = [filePath componentsSeparatedByString:@"#" ][0];
            [self saveCatalogue:currentNav whithName:cName filePosition:filePath nav:index depth:dp];
            index ++;
            navIndex ++;
            [self parseNode:nd withNavParam:(navParam/100) parentNav:currentNav depth:(dp + 1)];
        }        
    }
    [cd.parentMOC performBlockAndWait:^{
        [cd.parentMOC save:NULL];
    }];
}

-(void)saveCatalogue:(NSInteger)cID whithName:(NSString *)name filePosition:(NSString *)pos nav:(NSInteger)navIndex depth:(NSInteger)dp
{
    [cd.parentMOC performBlockAndWait:^{
        Catalogue *c1 = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Catalogue" inManagedObjectContext:cd.parentMOC];
        c1.cName = name;
        c1.cID = @(cID);
        c1.depth = @(dp);
        c1.filePath = pos;
        c1.navIndex = @(navIndex);
        c1.children = 0;
        c1.bookID = [MyBooksManager sharedInstance].currentReadBook.bookID;
    }];
}
@end



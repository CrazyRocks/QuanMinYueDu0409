//
//  NSAttributedStringRunDelegates.h
//  CoreTextExtensions
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#endif

void embeddedObjectDeallocCallback(void *context);
CGFloat embeddedObjectGetAscentCallback(void *context);
CGFloat embeddedObjectGetDescentCallback(void *context);
CGFloat embeddedObjectGetWidthCallback(void *context);
CTRunDelegateRef createEmbeddedObjectRunDelegate(id obj);

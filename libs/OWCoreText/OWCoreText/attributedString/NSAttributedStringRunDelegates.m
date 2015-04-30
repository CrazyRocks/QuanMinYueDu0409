//
//  NSAttributedStringRunDelegates.m
//  CoreTextExtensions
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import "NSAttributedStringRunDelegates.h"
#import "OWTextAttachment.h"


void embeddedObjectDeallocCallback(void *context)
{
}

CGFloat embeddedObjectGetAscentCallback(void *context)
{
	if ([(__bridge id)context isKindOfClass:[OWTextAttachment class]])
	{
		return [(__bridge OWTextAttachment *)context ascentForLayout];
	}
	return 0;
}
CGFloat embeddedObjectGetDescentCallback(void *context)
{
	if ([(__bridge id)context isKindOfClass:[OWTextAttachment class]])
	{
		return [(__bridge OWTextAttachment *)context descentForLayout];
	}
	return 0;
}

CGFloat embeddedObjectGetWidthCallback(void * context)
{
	if ([(__bridge id)context isKindOfClass:[OWTextAttachment class]])
	{
		return [(__bridge OWTextAttachment *)context displaySize].width;
	}
	return 35;
}

CTRunDelegateRef createEmbeddedObjectRunDelegate(id obj)
{
	CTRunDelegateCallbacks callbacks;
	callbacks.version = kCTRunDelegateCurrentVersion;
	callbacks.dealloc = embeddedObjectDeallocCallback;
	callbacks.getAscent = embeddedObjectGetAscentCallback;
	callbacks.getDescent = embeddedObjectGetDescentCallback;
	callbacks.getWidth = embeddedObjectGetWidthCallback;
	return CTRunDelegateCreate(&callbacks, (__bridge void *)obj);
	return NULL;
}

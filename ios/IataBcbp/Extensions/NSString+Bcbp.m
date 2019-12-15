//
//  NSString+Bcbp.m
//  IataBcbp
//
//  Created by Martin Mroz on 8/16/18.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#include "iata_bcbp_ffi.h"

#import "NSString+Bcbp.h"

// Deallocates a string allocated by the Bcbp FFI library.
static void BcbpCStringDeallocatorDeallocate(void *ptr, void *info)
{
    BcbpDestroyString((char *)ptr);
}

// Not valid for allocation, a CFAllocatorRef build from this context
// is used to defer destruction of strings managed by the Bcbp FFI library.
// As a Rust library may not use the system allocator, all pointers returned from
// the FFI library must be destroyed therewith. To reduce allocations and avoid
// copying all strings into memory managed by the system allocator,
// the memory is used directly and destruction is deferred back to the library.
static CFAllocatorContext BcbpCStringDeallocatorContext = {
    .version = 0,
    .info = NULL,
    .retain = NULL,
    .release = NULL,
    .copyDescription = NULL,
    .allocate = NULL,
    .reallocate = NULL,
    .deallocate = BcbpCStringDeallocatorDeallocate,
    .preferredSize = NULL,
};

@implementation NSString (Bcbp)

+ (_Nullable instancetype)IB_stringWithBcbpManagedCStringNoCopy:(char *const _Nullable)bcbpCString;
{
    return [self IB_stringWithBcbpManagedCStringNoCopy:bcbpCString length:strlen(bcbpCString)];
}

+ (_Nullable instancetype)IB_stringWithBcbpManagedCStringNoCopy:(char *const _Nullable)bcbpCString length:(NSUInteger)length;
{
    if (bcbpCString == NULL) {
        return nil;
    }

    static CFAllocatorRef bcbpCStringDeallocator = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bcbpCStringDeallocator = CFAllocatorCreate(kCFAllocatorDefault, &BcbpCStringDeallocatorContext);
    });

    CFStringRef const managedString = CFStringCreateWithBytesNoCopy(
        kCFAllocatorDefault,
        (const UInt8 *)bcbpCString,
        length,
        kCFStringEncodingUTF8,
        false,
        bcbpCStringDeallocator
    );

    return CFBridgingRelease(managedString);
}

- (BOOL)isEntirelySpaces;
{
    static NSCharacterSet *spaceCharacterSetInverted = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spaceCharacterSetInverted = [NSCharacterSet characterSetWithCharactersInString:@" "].invertedSet;
    });
    return [self rangeOfCharacterFromSet:spaceCharacterSetInverted].location == NSNotFound;
}

- (BOOL)isEntirelyDecimalDigits;
{
    static NSCharacterSet *decimalDigitsCharacterSetInverted = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decimalDigitsCharacterSetInverted = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"].invertedSet;
    });
    return [self rangeOfCharacterFromSet:decimalDigitsCharacterSetInverted].location == NSNotFound;
}

@end

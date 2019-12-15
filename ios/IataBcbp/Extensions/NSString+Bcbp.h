//
//  NSString+Bcbp.h
//  IataBcbp
//
//  Created by Martin Mroz on 8/16/18.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Bcbp)

/**
 Creates an NSString wrapping the `Bcbp` owned and managed C string.
 Ownership of the pointer is transferred to the new instance of the receiver.
 No data is copied, and the contents is deallocated using the appropriate
 FFI method once no longer required.
 @return A new instance of the receiver taking ownership of the input, or nil if the input is nil.
 */
+ (_Nullable instancetype)IB_stringWithBcbpManagedCStringNoCopy:(char *const _Nullable)bcbpCString;

/**
 Creates an NSString wrapping the `Bcbp` owned and managed C string.
 Ownership of the pointer is transferred to the new instance of the receiver.
 No data is copied, and the contents is deallocated using the appropriate
 FFI method once no longer required.
 @param length The pre-determined length of the `bcbpCString` in bytes.
 @return A new instance of the receiver taking ownership of the input, or nil if the input is nil.
 */
+ (_Nullable instancetype)IB_stringWithBcbpManagedCStringNoCopy:(char *const _Nullable)bcbpCString length:(NSUInteger)length;

/**
 @return true if the receiver is comprised solely of ASCII spaces.
 */
@property (nonatomic, assign, readonly, getter=isEntirelySpaces) BOOL entirelySpaces;

/**
 @return true if the receiver is comprised solely of ASCII digits in the range 0 to 9.
 */
@property (nonatomic, assign, readonly, getter=isEntirelyDecimalDigits) BOOL entirelyDecimalDigits;

@end

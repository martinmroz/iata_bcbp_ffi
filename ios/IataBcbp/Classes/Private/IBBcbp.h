//
//  IBBcbp.h
//  IataBcbp
//
//  Created by Martin Mroz on 10/30/19.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "iata_bcbp_ffi.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Provides an Objective-C wrapper around the iata_bcbp_ffi API. A pass string can be parsed
 and fields extracted without specially manually managing memory or object lifecycle.
 Instances of this object can be treated as complete Objective-C value types.
 */
@interface IBBcbp : NSObject

/**
 @param passString An IATA BCBP type-M version 2-6 encoded, inclusive, boarding pass string.
 @return A new instance of the receiver by parsing the passString or nil.
 */
+ (_Nullable instancetype)bcbpWithString:(NSString *)passString;

/**
 @see +bcbpWithString:
 @see -initWithBcbp:
 */
+ (_Nullable instancetype)new NS_UNAVAILABLE;

/**
 @see +bcbpWithString:
 @see -initWithBcbp:
 */
- (_Nullable instancetype)init NS_UNAVAILABLE;

/**
 @param bcbp An un-owned instance of the underlying Bcbp object.
 @return A new instance of the receiver taking ownership of the `bcbp` parameter object.
 */
- (instancetype)initWithBcbp:(Bcbp *)bcbp;

/**
 The number of legs encoded in the boarding pass object.
 */
@property (nonatomic, assign, readonly) NSInteger numberOfLegs;

/**
 @return YES if the receiver is logically equal to `other``.
 */
- (BOOL)isEqualToBcbp:(IBBcbp *_Nullable)other;

/**
 Copies a field from the receiver associated with the top-level data section of the boarding pass.
 @param fieldId The top-level field to extract.
 @return A string representation of the field or `nil` if not available.
 */
- (NSString *_Nullable)fieldWithId:(BcbpFieldId)fieldId;

/**
 Copies a field from the receiver associated with the security data section of the boarding pass.
 @param fieldId The security data field to extract.
 @return A string representation of the field or `nil` if not available.
 */
- (NSString *_Nullable)securityFieldWithId:(BcbpSecurityFieldId)fieldId;

/**
 Copies a field from the receiver associated with a specific leg of the boarding pass.
 @param fieldId The flight leg field to extract.
 @param index The index of the leg in the range `(0 ..< numberOfLegs)`
 @return A string representation of the field or `nil` if not available.
 @see -[IBBcbp numberOfLegs]
 */
- (NSString *_Nullable)flightLeg:(NSInteger)index fieldWithId:(BcbpFlightLegFieldId)fieldId;

@end

NS_ASSUME_NONNULL_END

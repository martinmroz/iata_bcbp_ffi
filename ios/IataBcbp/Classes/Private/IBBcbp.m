/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import "IBBcbp.h"

#import "NSString+Bcbp.h"

@interface IBBcbp ()

// MARK: - Private Properties

/// The underlying boarding pass data object.
@property (nonatomic, assign) Bcbp *bcbp;

@end

@implementation IBBcbp

#pragma mark - Initialization

+ (_Nullable instancetype)bcbpWithString:(NSString *)passString;
{
    NSParameterAssert(passString != nil);

    Bcbp *const bcbp = BcbpCreateWithCString([passString cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!bcbp) {
        return nil;
    }

    return [[self alloc] initWithBcbp:bcbp];
}

- (instancetype)initWithBcbp:(Bcbp *)bcbp;
{
    NSParameterAssert(bcbp != nil);

    self = [super init];
    if (!self) {
        return nil;
    }

    _bcbp = bcbp;

    return self;
}

- (_Nullable instancetype)init;
{
    [NSException raise:NSInternalInconsistencyException
                format:@"%@ is not a supported initializer of %@",
                       NSStringFromSelector(_cmd),
                       NSStringFromClass(self.class)];

    return nil;
}

- (void)dealloc;
{
    BcbpDestroy(_bcbp);
    _bcbp = NULL;
}

// MARK: - NSObject

- (NSUInteger)hash;
{
    return BcbpHash(self.bcbp);
}

- (instancetype)copy;
{
    return self;
}

- (NSString *)debugDescription;
{
    return [NSString stringWithFormat:@"<%@:%p %@>",
        NSStringFromClass(self.class),
        (void *)self,
        [NSString IB_stringWithBcbpManagedCStringNoCopy:BcbpCopyDebugDesc(self.bcbp)]
    ];
}

- (BOOL)isEqual:(id _Nullable)object;
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IBBcbp class]]) {
        return NO;
    }
    
    return [self isEqualToBcbp:(IBBcbp *)object];
}

#pragma mark - Properties

- (NSInteger)numberOfLegs;
{
    return (NSInteger)BcbpGetNumberOfLegs(self.bcbp);
}

#pragma mark - Public Methods

- (BOOL)isEqualToBcbp:(IBBcbp *_Nullable)other;
{
    return BcbpIsEqual(self.bcbp, other.bcbp);
}

- (NSString *_Nullable)fieldWithId:(BcbpFieldId)fieldId;
{
    // Copy the field from the boarding pass.
    char * fieldCString = NULL;
    uintptr_t length = 0;
    bool success = BcbpCopyField(self.bcbp, fieldId, &fieldCString, &length);
    if (!success || length == 0) {
        return nil;
    } else {
        return [NSString IB_stringWithBcbpManagedCStringNoCopy:fieldCString length:length];
    }
}

- (NSString *_Nullable)securityFieldWithId:(BcbpSecurityFieldId)fieldId;
{
    // Copy the security field from the boarding pass.
    char * fieldCString = NULL;
    uintptr_t length = 0;
    bool success = BcbpCopySecurityField(self.bcbp, fieldId, &fieldCString, &length);
    if (!success || length == 0) {
        return nil;
    } else {
        return [NSString IB_stringWithBcbpManagedCStringNoCopy:fieldCString length:length];
    }
}

- (NSString *_Nullable)flightLeg:(NSInteger)index fieldWithId:(BcbpFlightLegFieldId)fieldId;
{
    if (index >= self.numberOfLegs) {
        return nil;
    }

    // Copy the security field from the boarding pass.
    char * fieldCString = NULL;
    uintptr_t length = 0;
    bool success = BcbpCopyFlightLegField(self.bcbp, (int)index, fieldId, &fieldCString, &length);
    if (!success || length == 0) {
        return nil;
    } else {
        return [NSString IB_stringWithBcbpManagedCStringNoCopy:fieldCString length:length];
    }
}

@end

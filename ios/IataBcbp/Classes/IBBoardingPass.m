//
//  IBBoardingPass.m
//  IataBcbp
//
//  Created by Martin Mroz on 8/16/18.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#import "IBBoardingPass.h"

#import "IBBcbp.h"
#import "IBBoardingPassSecurityData.h"
#import "IBBoardingPassSecurityData_Private.h"
#import "NSDate+Bcbp.h"

@interface IBBoardingPass ()

// MARK: - Private Properties

/// The underlying boarding pass data object.
@property (nonatomic, strong) IBBcbp *bcbp;

/// The reference to use when interpreting Julian date strings.
@property (nonatomic, strong, readwrite) NSDate *scannedAt;

// MARK: - Public Property Redeclarations

@property (nonatomic, copy, readwrite, nonnull) NSString *passengerName;
@property (nonatomic, assign, readwrite, nonnull) NSString *electronicTicketIndicatorValue;
@property (nonatomic, copy, readwrite, nullable) NSDate *dateOfIssueOfBoardingPass;

@end

@implementation IBBoardingPass

// MARK: - Class Methods

+ (_Nullable instancetype)boardingPassWithBcbpString:(NSString *_Nonnull)passString scannedAt:(NSDate *_Nonnull)date;
{
    NSParameterAssert(passString != nil);
    NSParameterAssert(date != nil);
    if (passString.length == 0 || date == nil) {
        return nil;
    }

    IBBcbp *const bcbp = [IBBcbp bcbpWithString:passString];
    if (!bcbp) {
        return nil;
    }

    return [[self alloc] initWithBcbp:bcbp scannedAt:date];
}

+ (_Nullable instancetype)boardingPassWithBcbpString:(NSString *_Nonnull)passString;
{
    NSParameterAssert(passString != nil);
    if (passString.length == 0) {
        return nil;
    }

    return [self boardingPassWithBcbpString:passString scannedAt:[NSDate date]];
}

// MARK: - Initialization

- (_Nullable instancetype)init;
{
    [NSException raise:NSInternalInconsistencyException
            format:@"%s is not a supported initializer", __PRETTY_FUNCTION__];

    return nil;
}

- (_Nullable instancetype)initWithBcbp:(IBBcbp *const _Nonnull)bcbp scannedAt:(NSDate *_Nonnull)date;
{
    NSParameterAssert(bcbp != NULL);
    NSParameterAssert(date != nil);
    if (bcbp == nil || date == nil) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _bcbp = bcbp;
    _scannedAt = date;
    _securityData = [IBBoardingPassSecurityData securityDataWithBcbp:bcbp];

    return self;
}

// MARK: - NSObject

- (NSUInteger)hash;
{
    return self.bcbp.hash;
}

- (instancetype)copy;
{
    return self;
}

- (NSString *)debugDescription;
{
    return [NSString stringWithFormat:@"<%@:%p pass = %@>",
        NSStringFromClass(self.class),
        (void *)self,
        self.bcbp.debugDescription
    ];
}

- (BOOL)isEqual:(id _Nullable)object;
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IBBoardingPass class]]) {
        return NO;
    }
    
    return [self isEqualToBoardingPass:(IBBoardingPass *)object];
}

// MARK: - Public Methods

- (BOOL)isEqualToBoardingPass:(IBBoardingPass *)boardingPass;
{
    NSParameterAssert(boardingPass != nil);
    if (boardingPass == nil) {
        return NO;
    }

    // Nethier the Bcbp instance nor the reference date can be NULL or nil respectively.
    BOOL const equalScannedAtDate = ([self.scannedAt compare:boardingPass.scannedAt] == NSOrderedSame);
    BOOL const equalBcbp = [self.bcbp isEqualToBcbp:boardingPass.bcbp];

    return (equalScannedAtDate && equalBcbp);
}

// MARK: - Properties

- (NSString *_Nonnull)passengerName;
{
    if (_passengerName != nil) {
        return _passengerName;
    } else {
        NSString *const value = [self.bcbp fieldWithId:BCBP_FIELD_ID_PASSENGER_NAME];
        self.passengerName = value;
        return value;
    }
}

- (unichar)electronicTicketIndicator;
{
    // This is a required field and therefore cannot be empty.
    if (_electronicTicketIndicatorValue == nil) {
        _electronicTicketIndicatorValue = [self.bcbp fieldWithId:BCBP_FIELD_ID_ELECTRONIC_TICKET_INDICATOR];
    }

    // An API error has led to the required electronic ticket indicator field being missing.
    NSAssert(_electronicTicketIndicatorValue.length == 1, @"Required field missing: electronic ticket indicator");
    if (_electronicTicketIndicatorValue.length != 1) {
        return ' ';
    }

    return [_electronicTicketIndicatorValue characterAtIndex:0];
}

- (NSDate *_Nullable)dateOfIssueOfBoardingPass;
{
    if (_dateOfIssueOfBoardingPass != nil) {
        return _dateOfIssueOfBoardingPass;
    } else {
        NSString *const julanRepresentation = [self.bcbp fieldWithId:BCBP_FIELD_ID_DATE_OF_ISSUE_OF_BOARDING_PASS];
        if (julanRepresentation.length == 0) {
            return nil;
        }

        NSDate *const date = [NSDate IB_dateWithFourDigitJulianString:julanRepresentation onOrBefore:self.scannedAt];
        self.dateOfIssueOfBoardingPass = date;
        return date;
    }
}

@end

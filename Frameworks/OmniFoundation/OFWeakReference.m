// Copyright 2012-2016 Omni Development, Inc. All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import <OmniFoundation/OFWeakReference.h>

#import <OmniFoundation/NSMutableArray-OFExtensions.h>

RCS_ID("$Id$")

NS_ASSUME_NONNULL_BEGIN

// Stuff from the old OFWeakRetain protocol
OBDEPRECATED_METHOD(-invalidateWeakRetains);
OBDEPRECATED_METHOD(-incrementWeakRetainCount);
OBDEPRECATED_METHOD(-decrementWeakRetainCount);
OBDEPRECATED_METHOD(-strongRetain);

// Helper from OFWeakRetainConcreteImplementation.h
OBDEPRECATED_METHOD(-_releaseFromWeakRetainHelper);

#if !OB_ARC
#error This file must be built with ARC enabled to support auto-zeroing weak references
#endif

@implementation OFWeakReference
{
    __weak id _weakObject;
    void *_nonretainedObjectPointer;
}

@synthesize object = _weakObject;

- initWithObject:(id)object;
{
    if (!(self = [super init]))
        return nil;
    
    _weakObject = object;
    _nonretainedObjectPointer = (__bridge void *)object;

    return self;
}

- (BOOL)referencesObject:(void *)objectPointer;
{
    if (_nonretainedObjectPointer != objectPointer) {
        return NO;
    }
    return _weakObject != nil; // In case it got deallocated and a new object created at the same address.
}

/// Adds a new OFWeakReference to object. It is an error to add the same object more than once. This will also remove any references to objects that have been deallocated.
+ (void)add:(id)object toReferences:(NSMutableArray <OFWeakReference *> *)references;
{
    OBPRECONDITION(references != nil);

#ifdef OMNI_ASSERTIONS_ON
    for (OFWeakReference *reference in references) {
        OBASSERT([reference referencesObject:(__bridge void *)object] == NO);
    }
#endif
    [self _pruneReferences:references];

    OFWeakReference *reference = [[OFWeakReference alloc] initWithObject:object];
    [references addObject:reference];
}

/// Removes a reference to an existing object. It is an error to attempt to remove an object that was not previously added. This will also remove any references to objects that have been deallocated.
+ (void)remove:(id)object fromReferences:(NSMutableArray <OFWeakReference *> *)references;
{
    OBPRECONDITION(references != nil);

#ifdef OMNI_ASSERTIONS_ON
    __block BOOL found = NO;
#endif

    [references removeObjectsSatisfyingPredicate:^BOOL(OFWeakReference *reference){
        _Nullable id existing = reference.object;

#ifdef OMNI_ASSERTIONS_ON
        found |= (object == existing);
#endif
        return (existing == object) || (existing == nil); // Clean up any deallocated references at the same time.
    }];

    OBASSERT(found, "Attempted to remove an observer that we not registered.");
}

/// Calls the given block once for each still-valid object in the reference array. Any invalid references will be removed.
+ (void)forEachReference:(NSMutableArray <OFWeakReference *> *)references perform:(void (^)(id))action;
{
    // Copying in case the action makes further modifications. Any newly added references will not be considered, and any removed references will still be acted on this time around.
    NSArray <OFWeakReference *> *copy = [references copy];

    for (OFWeakReference *reference in copy) {
        id object = reference.object;
        if (object == nil) {
            // Don't assume that the reference array is unmodified. We *could* probe the original index first if this N^2 approach ever shows up on a profile. Also, something else might have removed it (like a reentrant call to add/remove another reference).
            NSUInteger referenceIndex = [references indexOfObjectIdenticalTo:reference];
            if (referenceIndex != NSNotFound) {
                [references removeObject:object];
            }
        } else {
            action(object);
        }
    }
}

+ (void)_pruneReferences:(NSMutableArray <OFWeakReference *> *)references;
{
    [references removeObjectsSatisfyingPredicate:^BOOL(OFWeakReference *reference){
        return (reference.object == nil);
    }];
}

@end

NS_ASSUME_NONNULL_END

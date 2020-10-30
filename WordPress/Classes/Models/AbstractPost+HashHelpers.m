#import "AbstractPost+HashHelpers.h"
#import "Media+WPMediaAsset.h"
#import "WordPress-Swift.h"
@import WordPressKit;

@implementation AbstractPost (HashHelpers)

- (NSString *)calculateConfirmedChangesContentHash {
    // The list of the properties we're taking into account here broadly mirrors: https://github.com/wordpress-mobile/WordPress-FluxC-Android/blob/f9e7fbae2479ad71bd2d1c7039f6f2bbbcc9444d/fluxc/src/main/java/org/wordpress/android/fluxc/model/PostModel.java#L443-L473
    // Note that some of the properties aren't found on `AbstractPost`, but rather on `Post` and/or `Page` —
    // that's the purpose of the `-additionalContentHashes` extension point.

    NSArray<NSData *> *hashedContents = @[
                                          [SHAHasher hashForNSInteger:self.blog.dotComID.integerValue],
                                          [SHAHasher hashForNSInteger:self.postID.integerValue],
                                          [SHAHasher hashForString:self.postTitle],
                                          [SHAHasher hashForString:self.content],
                                          [SHAHasher hashForDouble:self.dateCreated.timeIntervalSinceReferenceDate],
                                          [SHAHasher hashForString:self.permaLink],
                                          [SHAHasher hashForString:self.mt_excerpt],
                                          [SHAHasher hashForString:self.status],
                                          [SHAHasher hashForString:self.password],
                                          [SHAHasher hashForString:self.author],
                                          [SHAHasher hashForNSInteger:self.authorID.integerValue],
                                          [SHAHasher hashForString:self.featuredImage.identifier],
                                          [SHAHasher hashForString:self.wp_slug]];


    NSArray<NSData *> *finalHashes = [hashedContents arrayByAddingObjectsFromArray:self.additionalContentHashes];

    // So, there are multiple ways of combining all those hashes. You need to be careful not to lose the entropy though.
    // Initially, I wanted to just XOR them together, which is totally reasonable thing to do!
    // ...however, things get tricky when you XOR things that might be similar/the same.
    // One important thing to keep in mind here is that a XOR a = 0;
    // e.g. imagine if `self.content` and `self.postTitle` would be both empty strings (most of our users probably don't
    // want to upload such posts, but stick with me for illustrations purposes).
    // If we were to then iterate over the list of hashes and xor them together, then at one point we'd
    // end up doing iteration where the result is 0, reducing the entropy.
    // Now, this _probably_ would be extremely rare and shouldn't _actually_ cause collisions, (
    // but better safe than sorry — tracking down those would be a nightmare.
    // What I'm doing here instead is just treating all the "partial" hashes as a dumb bag of bits,
    // combining them together and the final hash is SHA256 of _that_.
    // Hopefully that'll be enough.
    return [SHAHasher combineHashes:finalHashes];
}

- (NSArray<NSData *> *)additionalContentHashes {
    return @[];
}

@end

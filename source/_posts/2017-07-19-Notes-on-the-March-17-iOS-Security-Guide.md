---
layout: post
title: Notes on the March '17 Edition of the iOS Security Guide
date: 2017-07-19 06:24:59
tags: [Software, iOS]
excerpt: I recently read through the March 2017 iOS Security Guide and made a few notes - it's quite dense! I thought I would share these notes so other people can benefit from the time I put in too.
---
This post was originally prepared at and for the Pivotal Tracker Team in Denver, CO. [It appears on the Pivotal Tracker blog](https://pivotaltracker.com/blog/notes-on-march-2017-ios-security-guide/).

Additions and clarifications from external sources where noted.

### Encryption

When new files are created on device, they are automatically assigned a "Data Protection Class" that determines under what conditions the file may be read/written

They are:

- Available when unlocked (NSFileProtectionComplete)
  - Only allowed access when the device is unlocked


- Available on create and after open (NSFileProtectionCompleteUnlessOpen)
  - This one is difficult to explain simply. Check out the [docs](https://developer.apple.com/reference/foundation/nsfileprotectioncompleteunlessopen) for more info.
  - If file is created when device is locked
    - Can access file until it is closed
    - After file is closed, can't open again until unlock
  - If file is opened when device is unlocked
    - Can access file even if device is locked again


- Available after first unlock (NSFileProtectionCompleteUntilFirstUserAuthentication)
  - Is the default data protection class for all third party app files, unless otherwise specified


- Always available (NSFileProtectionNone)
  - Not encrypted with a passcode, but the device UID it sounds like.
  - So, you're unable to read the files if you don't have access to the device.



### Keychain

See [Keychain Services Programming Guide](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/02concepts/concepts.html#//apple_ref/doc/uid/TP30000897-CH204-CJBIBIBC)

The Keychain is implemented as a database stored on the file system.

There is only one keychain database. The `securityd` daemon manages access.

On macOS, every new user is assigned a keychain called `login.keychain`
On iOS, there is one keychain used by all applications

A keychain item has data (the stuff you want to keep secret), and metadata about the item.

Keychain items can be synced with iCloud with by setting the `kSecAttrSynchronizable` attribute to `kCFBooleanTrue`
Shared items may only be used by apps with the same TEAM_ID

On iOS, encrypted keychain items are by default not available when the device is locked. This behavior can be changed by assigning a `Keychain Protection Class` to a keychain item. 



Keychain access is determined by an app's
- `keychain-access-groups` (called 'Keychain Groups' in XCode under Project Settings -> Capabilities -> Keychain Sharing)
- `application-identifier`
    - described in the [Cocoa Core Competencies Docs](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/AppID.html)
    - is `TEAM_ID`+`BUNDLE_IDENTIFIER`
- `application-group`

Keychain items can't be shared between applications made by different developers

Similar to file encryption, keychain items are assigned a `Keychain Protection Class`:

- Available when unlocked (`kSecAttrAccessibleWhenUnlocked`)
  Only allowed access when the device is unlocked

- Available after first unlock (`kSecAttrAccessibleAfterFirstUnlock`)
  Just what it says.

- Always available (`kSecAttrAccessibleAlways`)
  Not encrypted with a passcode, but the device UID.
  So, you're unable to read the files if you don't have access to the device.

- Passcode enabled (`kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`)
  The same as "Available when unlocked" except that the item is only available on devices with a passcode.
  If passcode is removed, items are deleted.
  Items are not migrated to a new device.
  Items are not synced to iCloud keychain.
  Items are not backed up.
  Items are not included in escrow keybags.


When accessing the keychain for background refresh services (e.g., on receipt of remote notifications), Apple recommends using `kSecAttrAccessibleAfterFirstUnlock`


### Signing

iOS requires that apps are signed to ensure they haven't been tampered with after they've left the developer's hands.

Stock apps (e.g., Safari) have been signed by apple directly.
Third part apps (i.e., yours) have been signed by you with a certificate provided by apple.

The system will do a runtime signature check of any frameworks used by a third party app to verify their authenticity.

What a dig from the iOS Security Guide: "Unlike other mobile platforms, iOS doesn't allow users to install potentially malicious unsigned apps from websites, or run untrusted code."

At runtime, the operating system will also verify the signature of paged memory to make sure it hasn't been modified since last run.
Intense.

### App Sandboxing

Every third party app is sandboxed - it gets its own filesystem container and cant touch the containers of other apps.

A new sandbox is generated and randomly assigned at app install.

If the app needs to access resources provided by the system, it does so through APIs provided by apple, not direct access to the filesystem/processes
Access to these resources are controlled through Entitlements

The OS uses [Address Space Layout Randomization](https://en.wikipedia.org/wiki/Address_space_layout_randomization) to reduce the likelihood of a successful buffer overflow attack


### SSL

App Transport Security enforces, by default, the use of secure standards when communicating over the network
Apps must explicitly declare they wish to use insecure methods of communication

### Important concepts

- App groups
  - Described in [Sharing Data with Your Containing App](https://developer.apple.com/library/content/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html) and the `App Groups` section of the iOS Security Guide
  - Allows sharing `NSUserDefaults` (simple key value store) between app and extensions
  - Allows sharing container directories (what does this actually achieve?)
  - Allows sharing keychain items


- Keybag
  - Are a way of categorizing types of keys
  - There are many different types: User, Device, Backup, Escrow, iCloud Backup
  - Keys for both File Data Protection and Keychain Data Protection classes are stored in keybags


- Effaceable Storage
  - Storage that is guaranteed, at a hardware level, to delete data properly


- Entitlements
  - Define an API for Apple provided frameworks, specifically, things that would normally require root permissions on unix system
  - Created so that applications must explicitly ask for permission to use system functionality. This minimizes the damage possible if your app is exploited.
  - Are cryptographically signed so they're not easy to spoof


- Extensions
  - "The system automatically detects extensions at install time and makes them available to other apps using a matching system." - iOS Security Guide
  - Extensions and the apps their based on don't have direct access to each other's files or memory
  - Extension receive the same privacy settings as their parent applications


- Core data, NSData, SQLite
  - Are encrypted by default


- Passcodes
  - Passcodes are stored with an iteration count of ~80ms. That is, it takes ~80ms to check if an entered passcode is correct. Tries between brute force attacks take at least that long.


- Containers (filesystem/directory)
  - See Apple's [Filesystem Overview](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW12)
  - Are sandbox directories
  - Third party apps are not allowed direct access to the iOS filesystem, and instead have access to the container in which they live
  - iCloud also has its own container
  - Limit the damage done if your app is compromised

- Device UID
  - A device's unique ID
  - 256 bit key baked into the device processor at manufacture time

### FAQs

- How should I store sensitive information like passwords or API tokens?
  - The Security Guide recommends storing passwords in the keychain:
    - `Many apps need to handle passwords and other short but sensitive bits of data, such as keys and login tokens. The iOS Keychain provides a secure way to store these items.` - iOS Security Guide
    
- What's the point of the keychain?
  - Encrypt your secrets
  - Allow/disallow access to secrets depending on the state of the device
  - Sync your secrets to iCloud by setting the `kSecAttrSynchronizable` attribute 
  
  
### Wrapping Up
  
  The iOS Security Guide is quite technical and complicated. If I missed or misrepresented any of the information in the guide you think is important, please leave a comment below!
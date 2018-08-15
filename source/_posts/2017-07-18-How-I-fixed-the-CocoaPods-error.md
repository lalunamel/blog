---
layout: post
title: How I fixed the CocoaPods error `Unable to find host target(s)` after upgrading to CocoaPods 1.2.1
date: 2017-07-18 06:24:59
tags: [Software, iOS]
excerpt: The promise of hands off dependency management sounds great, but every update of CocoaPods seems to bring more trouble. Here's how I fixed a particual error after splunking through the source. 
---
This post was originally prepared at and for the Pivotal Tracker Team in Denver, CO.


## tl;dr
Add your framework or extension as a dependency on your main application so that `your Main Application ---depends-on---> your Framework or Extension`.

You can do this using XCode: 

1. `project navigator`
2. select your `main application target`
3. `build phases`
4. `target dependencies`
5. add your framework or extension to the target dependencies of your main application.

## Background

On the Pivotal Tracker mobile team, we used CocoaPods to manage our dependencies for our iOS application.

CocoaPods had recently been updated to v1.2.1, so we decided to upgrade! But it's never that easy, is it?

After upgrading CocoaPods, running `pod install` produced the following error:


    [!] Unable to find host target(s) for ShareExtension. Please add the host targets for the embedded targets to the Podfile.
    Certain kinds of targets require a host target. A host target is a "parent" target which embeds a "child" target. These are example types of targets that need a host target:
    - Framework
    - App Extension
    - Watch OS 1 Extension
    - Messages Extension (except when used with a Messages Application)


## That error makes no sense and is unintelligible

Let's google it!

The first result is [this GitHub issue on the CocoaPods repo](https://github.com/CocoaPods/CocoaPods/issues/5620).
The answers to that user's question are: 1. `Did you try [doing what the error says]?` and 2. `I think you're going to need to go through the guides or some tutorials`
Not helpful. In fact, there's no mention of what a "host target" or an "embedded target" is in the CocoaPods docs or anywhere else on the internet.

We're no further and left with a few questions:
- What's a target, in CocoaPods parlance?
- What's a host target, what's an embedded target?
- What is this asking me to do exactly, and how do I do it?
  - Do I have an incorrect Podfile, .pbxproj, or something else?


## Let's answer those questions


Again, I googled the string `Please add the host targets for the embedded targets to the Podfile` and found that it was produced by [`analyze_host_targets_in_podfile` in `analyzer.rb`](https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer/analyzer.rb), in the [CocoaPods repo](https://github.com/CocoaPods/CocoaPods).

Let's crack open the local version of CocoaPods and start splunking!
Mine was at `~/.rvm/gems/ruby-2.3.4/gems/cocoapods-1.2.1`

I attempted to download the CocoaPods repo directly and look at that, but I couldn't get tests to run and it wasn't worth the effort.

I also attempted to download the CocoaPods repo directly and point my `Gemfile` at that, but I ran into issues there as well.

My strategy for understanding `analyzer.rb` was to go line by line, reading, until I hit something I didn't understand, put a bunch of print statements in, do a `pod install` and see what comes out.

Rinse and repeat!

I've reproduced my annotated version of `analyzer.rb` below without any of the comments in the original source.
The original comments only speak in terms of the domain that I'm seeking to understand and aren't very helpful for someone new to the code like me.


```lang-ruby
# # # # # # # # # # # # # # # #
# vvv The Relevant Bits vvv # #
# # # # # # # # # # # # # # # #

def analyze_host_targets_in_podfile(aggregate_targets, embedded_aggregate_targets)
  # aggregate_targets targets are all targets defined in the podfile
  # embedded_aggregate_targets targets are a subset of the above that are "embedded"

    # "embeded" targets are those targets defined in EMBED_FRAMEWORKS_IN_HOST_TARGET_TYPES of `aggregate_target.rb`
    # [:app_extension, :framework, :static_library, :messages_extension, :watch_extension, :xpc_service]

  target_definitions_by_uuid = {}
  aggregate_targets.each do |target|
     # a user_target == target, in the xcode sense
    target.user_targets.map(&:uuid).each do |uuid|
      target_definitions_by_uuid[uuid] = target.target_definition
    end
  end

  # user_project == project in the xcode sense
  aggregate_target_user_projects = aggregate_targets.map(&:user_project)
  embedded_targets_missing_hosts = []
  host_uuid_to_embedded_target_definitions = {}

  embedded_aggregate_targets.each do |target|
    host_uuids = []
    # if all the targets are part of the same project, then
    # `aggregate_target_user_projects.product(target.user_targets)` is a list, length = count(targets), of [project, target] repeated
    aggregate_target_user_projects.product(target.user_targets).each do |user_project, user_target|
      # user_project == project for target
      # user_target == target

      host_uuids += user_project.host_targets_for_embedded_target(user_target).map(&:uuid)
    end

    # host_uuids == list of targets that depend on the target that is the subject of this each block

    # how does user_project.host_targets_for_embedded_target(embedded_target) work???
    # that method is part of the CocoaPods/Xcodeproj ruby library
    # it iterates over all targets in a project
    # and returns a list of those targets that depend on embedded_target


    host_uuids.each do |uuid|
      (host_uuid_to_embedded_target_definitions[uuid] ||= []) << target.target_definition if target_definitions_by_uuid.key? uuid
    end

    embedded_targets_missing_hosts << target unless host_uuids.any? do |uuid|
      target_definitions_by_uuid.key? uuid
    end
  end

# # # # # # # # # # # # # # # #
# ^^^ The Relevant Bits ^^^ # #
# # # # # # # # # # # # # # # #

  unless embedded_targets_missing_hosts.empty?
    embedded_targets_missing_hosts_product_types = embedded_targets_missing_hosts.map(&:user_targets).flatten.map(&:symbol_type).uniq

    if embedded_targets_missing_hosts_product_types == [:framework]
      UI.warn 'The Podfile contains framework targets, for which the Podfile does not contain host targets (targets which embed the framework).' \
        "\n" \
        'If this project is for doing framework development, you can ignore this message. Otherwise, add a target to the Podfile that embeds these frameworks to make this message go away (e.g. a test target).'
    else
      target_names = embedded_targets_missing_hosts.map do |target|
        target.name.sub('Pods-', '') # Make the target names more recognizable to the user
      end.join ', '
      raise Informative, "Unable to find host target(s) for #{target_names}. Please add the host targets for the embedded targets to the Podfile." \
                          "\n" \
                          'Certain kinds of targets require a host target. A host target is a "parent" target which embeds a "child" target. These are example types of targets that need a host target:' \
                          "\n- Framework" \
                          "\n- App Extension" \
                          "\n- Watch OS 1 Extension" \
                          "\n- Messages Extension (except when used with a Messages Application)"
    end
  end

  target_mismatches = []
  host_uuid_to_embedded_target_definitions.each do |uuid, target_definitions|
    host_target_definition = target_definitions_by_uuid[uuid]
    target_definitions.each do |target_definition|
      unless host_target_definition.uses_frameworks? == target_definition.uses_frameworks?
        target_mismatches << "- #{host_target_definition.name} (#{host_target_definition.uses_frameworks?}) and #{target_definition.name} (#{target_definition.uses_frameworks?}) do not both set use_frameworks!."
      end
    end
  end

  unless target_mismatches.empty?
    heading = 'Unable to integrate the following embedded targets with their respective host targets (a host target is a "parent" target which embeds a "child" target like a framework or extension):'
    raise Informative, heading + "\n\n" + target_mismatches.sort.uniq.join("\n")
  end
end
```


After working through the source, we've found a few answers:

- What's a target, in CocoaPods parlance?
  - The same thing as in [XCode parlance](https://developer.apple.com/library/content/featuredarticles/XcodeConcepts/Concept-Targets.html)
- What's a host target, what's an embedded target?
  - Host Target: a target that depends on another target
  - Embedded Target: a target that is depended on by another target
  - `Host Target ---depends-on---> Embedded Target`
- Do I have an incorrect Podfile, project (.pbxproj), or something else?
  - To fix this issue, you must modify your project (.pbxproj) file

## What else?
I plan on making a PR to improve this error in the future, and perhaps writing a stern letter to the maintainers of CocoaPods re: creating documentation that is clear, doesn't use domain language, and is actionable.

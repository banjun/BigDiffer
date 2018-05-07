# BigDiffer

[![CI Status](https://img.shields.io/travis/banjun/BigDiffer.svg?style=flat)](https://travis-ci.org/banjun/BigDiffer)
[![Version](https://img.shields.io/cocoapods/v/BigDiffer.svg?style=flat)](https://cocoapods.org/pods/BigDiffer)
[![License](https://img.shields.io/cocoapods/l/BigDiffer.svg?style=flat)](https://cocoapods.org/pods/BigDiffer)
[![Platform](https://img.shields.io/cocoapods/p/BigDiffer.svg?style=flat)](https://cocoapods.org/pods/BigDiffer)

## Usage

```swift
tableView.reloadUsingBigDiff(old: old, new: new)
```

where old & new are `[T]` where `T: BigDiffableSection` (c.f. `ListDiff.Diffable`). See in detail at [example view controller code](Example/BigDiffer/BigDifferMultiSectionTableViewController.swift).
Example project has some workarounds for other diff libraries in terms of applying large number of diffs.


## Features

* Multi section diff & patch for UITableView
* Fast linear complexity diff algorithm a.k.a. Heckel, by making use of [ListDiff](https://github.com/lxcid/ListDiff)
* Optimize diff with some heuristics for large number of rows
  * Skip diffing for currently invisible sections (use reload)
  * Section-wise diff for currently (partially or completely) visible sections
  * Skip applying diff when many deletions detected (> 300), for each section

## Installation

BigDiffer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BigDiffer'
```

Alternatively, use subspecs to use other diff & patch libraries with optimized fallbacks that reloadData for a large number of diffs (row deletions).

```ruby
pod 'BigDiffer/Differ'
```

## Author

@banjun

## License

BigDiffer is available under the MIT license. See the LICENSE file for more info.

import Foundation

struct Stack<Element> {
    var items = [Element]()
    var isEmpty: Bool {
        return self.items.isEmpty
    }
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
}

public protocol Diffable {
    var diffIdentifier: AnyHashable { get }
}

/// https://github.com/Instagram/IGListKit/blob/master/Source/IGListDiff.mm
public enum List {
    /// Used to track data stats while diffing.
    /// We expect to keep a reference of entry, thus its declaration as (final) class.
    final class Entry {
        /// The number of times the data occurs in the old array
        var oldCounter: Int = 0
        /// The number of times the data occurs in the new array
        var newCounter: Int = 0
        /// The indexes of the data in the old array
        var oldIndexes: Stack<Int?> = Stack<Int?>()
        /// Flag marking if the data has been updated between arrays by equality check
        var updated: Bool = false
        /// Returns `true` if the data occur on both sides, `false` otherwise
        var occurOnBothSides: Bool {
            return self.newCounter > 0 && self.oldCounter > 0
        }
        func push(new index: Int?) {
            self.newCounter += 1
            self.oldIndexes.push(index)
        }
        func push(old index: Int?) {
            self.oldCounter += 1;
            self.oldIndexes.push(index)
        }
    }
    
    /// Track both the entry and the algorithm index. Default the index to `nil`
    struct Record {
        let entry: Entry
        var index: Int?
        init(_ entry: Entry) {
            self.entry = entry
            self.index = nil
        }
    }
    
    public struct MoveIndex : Equatable {
        public let from: Int
        public let to: Int
        
        public init(from: Int, to: Int) {
            self.from = from
            self.to = to
        }
        
        public static func ==(lhs: MoveIndex, rhs: MoveIndex) -> Bool {
            return lhs.from == rhs.from && lhs.to == rhs.to
        }
    }
    
    public struct Result {
        public var inserts = IndexSet()
        public var updates = IndexSet()
        public var deletes = IndexSet()
        public var moves = Array<MoveIndex>()
        public var oldMap = Dictionary<AnyHashable, Int>()
        public var newMap = Dictionary<AnyHashable, Int>()
        public var hasChanges: Bool {
            return (self.inserts.count > 0) || (self.deletes.count > 0) || (self.updates.count > 0) || (self.moves.count > 0)
        }
        public var changeCount: Int {
            return self.inserts.count + self.deletes.count + self.updates.count + self.moves.count
        }
        public func validate(_ oldArray: Array<Diffable>, _ newArray: Array<Diffable>) -> Bool {
            return (oldArray.count + self.inserts.count - self.deletes.count) == newArray.count
        }
        public func oldIndexFor(identifier: AnyHashable) -> Int? {
            return self.oldMap[identifier]
        }
        public func newIndexFor(identifier: AnyHashable) -> Int? {
            return self.newMap[identifier]
        }
    }
    
    public static func diffing<T: Diffable & Equatable>(oldArray:Array<T>, newArray:Array<T>) -> Result {
        // symbol table uses the old/new array `diffIdentifier` as the key and `Entry` as the value
        var table = Dictionary<AnyHashable, Entry>()
        
        // pass 1
        // create an entry for every item in the new array
        // increment its new count for each occurence
        // record `nil` for each occurence of the item in the new array
        var newRecords = newArray.map { (newRecord) -> Record in
            let key = newRecord.diffIdentifier
            if let entry = table[key] {
                // add `nil` for each occurence of the item in the new array
                entry.push(new: nil)
                return Record(entry)
            } else {
                let entry = Entry()
                // add `nil` for each occurence of the item in the new array
                entry.push(new: nil)
                table[key] = entry
                return Record(entry)
            }
        }
        
        // pass 2
        // update or create an entry for every item in the old array
        // increment its old count for each occurence
        // record the old index for each occurence of the item in the old array
        // MUST be done in descending order to respect the oldIndexes stack construction
        var oldRecords = oldArray.enumerated().reversed().map { (i, oldRecord) -> Record in
            let key = oldRecord.diffIdentifier
            if let entry = table[key] {
                // push the old indices where the item occured onto the index stack
                entry.push(old: i)
                return Record(entry)
            } else {
                let entry = Entry()
                // push the old indices where the item occured onto the index stack
                entry.push(old: i)
                table[key] = entry
                return Record(entry)
            }
        }
        
        // pass 3
        // handle data that occurs in both arrays
        newRecords.enumerated().filter { $1.entry.occurOnBothSides }.forEach { (i, newRecord) in
            let entry = newRecord.entry
            // grab and pop the top old index. if the item was inserted this will be nil
            assert(!entry.oldIndexes.isEmpty, "Old indexes is empty while iterating new item \(i). Should have nil")
            guard let oldIndex = entry.oldIndexes.pop() else {
                return
            }
            if oldIndex < oldArray.count {
                let n = newArray[i]
                let o = oldArray[oldIndex]
                if n != o {
                    entry.updated = true
                }
            }
            
            // if an item occurs in the new and old array, it is unique
            // assign the index of new and old records to the opposite index (reverse lookup)
            newRecords[i].index = oldIndex
            oldRecords[oldIndex].index = i
        }
        
        // storage for final indexes
        var result = Result()
        
        // track offsets from deleted items to calculate where items have moved
        // iterate old array records checking for deletes
        // increment offset for each delete
        var runningOffset = 0
        let deleteOffsets = oldRecords.enumerated().map { (i, oldRecord) -> Int in
            let deleteOffset = runningOffset
            // if the record index in the new array doesn't exist, its a delete
            if oldRecord.index == nil {
                result.deletes.insert(i)
                runningOffset += 1
            }
            result.oldMap[oldArray[i].diffIdentifier] = i
            return deleteOffset
        }
        
        //reset and track offsets from inserted items to calculate where items have moved
        runningOffset = 0
        /* let insertOffsets */_ = newRecords.enumerated().map { (i, newRecord) -> Int in
            let insertOffset = runningOffset
            if let oldIndex = newRecord.index {
                // note that an entry can be updated /and/ moved
                if newRecord.entry.updated {
                    result.updates.insert(oldIndex)
                }
                
                // calculate the offset and determine if there was a move
                // if the indexes match, ignore the index
                let deleteOffset = deleteOffsets[oldIndex]
                if (oldIndex - deleteOffset + insertOffset) != i {
                    result.moves.append(MoveIndex(from: oldIndex, to: i))
                }
            } else { // add to inserts if the opposing index is nil
                result.inserts.insert(i)
                runningOffset += 1
            }
            result.newMap[newArray[i].diffIdentifier] = i
            return insertOffset
        }
        
        assert(result.validate(oldArray, newArray), "Sanity check failed applying \(result.inserts.count) inserts and \(result.deletes.count) deletes to old count \(oldArray.count) equaling new count \(newArray.count)")
        
        return result
    }
}

//
//  PredicateBuilder.swift
//  PrediKit
//
//  Created by Hector Matos on 5/30/16.
//
//

import Foundation

/**
 The class that gets passed into the builder closure of PrediKit's `NSPredicate` convenience initializer.
 */
public class PredicateBuilder<T: Reflectable> {
    let type: T.Type
    var predicateString: String = ""
    var arguments: [AnyObject?] = []
    
    /**
     Used to indicate that you want to query the actual object checked when the predicate is run. Behaves like the `SELF` in the SQL-like query:
     
         NSPredicate(format: "SELF in names")
     */
    public var SELF: BasicQuery<T> {
        return BasicQuery(builder: self, property: "SELF")
    }
    
    init(type: T.Type) {
        self.type = type
    }
    
    /**
     Describes the key of class `T`'s `String` property you want to query. For example, when creating a predicate that compares a class' string property to a given string:
     
         class Kraken: NSObject {
             var theyCallMe: String
         }
         NSPredicate(format: "theyCallMe == 'Chief Supreme'")
     
     The `property` parameter would be the "theyCallMe" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func string(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> StringQuery<T> {
        return StringQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s number type property you want to query. For example, when creating a predicate that compares a number property to a given value:
     
         class Kraken: NSObject {
             var numberOfHumansEaten: Int
         }
         NSPredicate(format: "numberOfHumansEaten >= 6")
     
     The `property` parameter would be the "numberOfHumansEaten" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func number(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> NumberQuery<T> {
        return NumberQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `NSDate` property you want to query. For example, when creating a predicate compares a class' date property to another given date:
     
         class Kraken: NSObject {
             var birthdate: NSDate
         }
         NSPredicate(format: "birthdate == %@", NSDate())
     
     The `property` parameter would be the "birthdate" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func date(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> DateQuery<T> {
        return DateQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `Bool` property you want to query. For example, when creating a predicate that checks against a given `Bool` flag in a class:
     
         class Kraken: NSObject {
             var isHungry: Bool
         }
         NSPredicate(format: "isHungry == true")
     
     The `property` parameter would be the "isHungry" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func bool(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> BooleanQuery<T> {
        return BooleanQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes the key of class `T`'s `CollectionType` property you want to query. This is also the starting point for subqueries on list properties. For example, when creating a predicate that checks if a class' array property has 5 objects:
     
         class Kraken: NSObject {
             var friends: [LegendaryCreatures]
         }
         NSPredicate(format: "friends.@count == 5")
     
     The `property` parameter would be the "friends" in the example predicate format.
     
     - Parameters:
     - property: The name of the property in the class of type `T`
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func collection(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> SequenceQuery<T> {
        return SequenceQuery(builder: self, property: validatedProperty(property, file: file, line: line))
    }
    
    /**
     Describes a member with a custom type that belongs to class `T` that you want to query. Recursive since it returns an instance of PredicateMemberQuery that is a subclass of PredicateBuilder. For example, when creating a predicate for a specific custom type member:
     
         class Kraken: NSObject {
             var friend: LegendaryCreature
         }
         NSPredicate(format: "friend == %@", legendaryCreature)
     
     The `property` parameter would be the "friend" in the example predicate format.
     
     - Parameters:
     - property: The name of the property member in the class of type `T`
     - memberType: The Reflectable type of the property member
     - file: Name of the file the function is being called from. Defaults to `__FILE__`
     - line: Number of the line the function is being called from. Defaults to `__LINE__`
     */
    public func member<U: protocol<Reflectable, AnyObject>>(property: Selector, ofType memberType: U.Type, file: String = __FILE__, line: Int = __LINE__) -> MemberQuery<T, U> {
        return MemberQuery(builder: self, property: validatedProperty(property), memberType: memberType)
    }
    
    internal func validatedProperty(property: Selector, file: String = __FILE__, line: Int = __LINE__) -> String {
        if !type.properties().contains(property) && self.type != NSObject.self {
            #if DEBUG
                print("\(String(type)) does not seem to contain property \"\(property)\". This could be due to the optionality of a value type. Possible property key values:\n\(type.properties()).\nWarning in file:\(file) at line \(line)")
            #endif
        }
        
        return String(property)
    }
}

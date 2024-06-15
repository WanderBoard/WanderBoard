//
//  CoreDataManager.swift
//  WanderBoard
//
//  Created by Luz on 6/15/24.
//

//import CoreData
//
//class CoreDataManager {
//    static let shared = CoreDataManager()
//
//    private init() { }
//
//    func deleteUserFromCoreData(userId: String, context: NSManagedObjectContext) throws {
//        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "uid == %@", userId)
//
//        do {
//            let users = try context.fetch(fetchRequest)
//            for user in users {
//                context.delete(user)
//            }
//            try context.save()
//        } catch {
//            throw error
//        }
//    }
//}


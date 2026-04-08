
public import Foundation
public import CoreData


public typealias GeneratedVideoCoreDataPropertiesSet = NSSet

extension GeneratedVideo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeneratedVideo> {
        return NSFetchRequest<GeneratedVideo>(entityName: "GeneratedVideo")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var duration: String?
    @NSManaged public var id: UUID?
    @NSManaged public var prompt: String?
    @NSManaged public var quality: String?
    @NSManaged public var thumbnailData: Data?
    @NSManaged public var videoURL: URL?
    @NSManaged public var generationMode: String?
    @NSManaged public var selectedTemplateId: String?
    @NSManaged public var sourceImageData: Data?

}

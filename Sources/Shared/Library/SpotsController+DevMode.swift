#if DEVMODE
import Sugar

extension SpotsController {

  func monitor(filePath: String) {
    guard NSFileManager.defaultManager().fileExistsAtPath(filePath) else { return }

    source = dispatch_source_create(
      DISPATCH_SOURCE_TYPE_VNODE,
      UInt(open(filePath, O_EVTONLY)),
      DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
      fileQueue)

    dispatch_source_set_event_handler(source, {
      // Check that file still exists, otherwise cancel observering
      guard NSFileManager.defaultManager().fileExistsAtPath(filePath) else {
        dispatch_source_cancel(self.source)
        self.source = nil
        return
      }

      do {
        if let data = NSData(contentsOfFile: filePath),
          json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String : AnyObject] {
          dispatch_source_cancel(self.source)
          self.source = nil
          let offset = self.spotsScrollView.contentOffset
          self.reloadIfNeeded(json, compare: { $0 !== $1 }) {
            self.spotsScrollView.contentOffset = offset
          }
        }
      } catch let error {
        dispatch_source_cancel(self.source)
        self.source = nil

        self.reload(["components" : [["kind" : "list", "items" : [[
          "title" : "JSON parsing error",
          "subtitle" : "\(error)"]]
          ]
          ]])
      }
    })

    dispatch_resume(source)
  }
}
#endif

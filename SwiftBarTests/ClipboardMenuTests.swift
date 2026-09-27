import Cocoa
import Testing

@testable import SwiftBar

@Suite(.serialized)
@MainActor
struct ClipboardMenuTests {
    @Test func editingMenuRoutesStandardShortcutsThroughTheResponderChain() throws {
        let app = NSApplication.shared
        let previous = app.mainMenu
        defer { app.mainMenu = previous }
        let existingMenu = NSMenu(title: "Existing")
        let existingItem = NSMenuItem(title: "Existing app menu", action: nil, keyEquivalent: "")
        existingMenu.addItem(existingItem)
        app.mainMenu = existingMenu

        installEditingMenu(in: app)
        installEditingMenu(in: app)

        #expect(app.mainMenu === existingMenu)
        #expect(existingMenu.items.first === existingItem)
        let menus = existingMenu.items.filter { $0.identifier?.rawValue == "SwiftBar.Edit" }
        #expect(menus.count == 1)
        let edit = try #require(menus.first?.submenu)
        for (key, action) in [("x", "cut:"), ("c", "copy:"), ("v", "paste:"), ("a", "selectAll:")] {
            let item = try #require(edit.items.first { $0.keyEquivalent == key })
            #expect(item.keyEquivalentModifierMask == .command)
            #expect(item.action == Selector(action))
            #expect(item.target == nil)
        }
        // Leave Tasker's own undo/redo shortcuts and other plugin keys alone.
        #expect(edit.items.allSatisfy { !["z", "e", "j", "p"].contains($0.keyEquivalent) })
    }

    @Test func editingMenuAlsoWorksWithoutAnExistingMainMenu() {
        let app = NSApplication.shared
        let previous = app.mainMenu
        defer { app.mainMenu = previous }
        app.mainMenu = nil
        installEditingMenu(in: app)
        #expect(app.mainMenu?.items.contains { $0.identifier?.rawValue == "SwiftBar.Edit" } == true)
    }
}

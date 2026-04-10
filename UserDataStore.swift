import SwiftUI
import Combine

// MARK: - UserDataStore
// Persists favorites and viewed state using UserDefaults / @AppStorage

class UserDataStore: ObservableObject {
    static let shared = UserDataStore()

    // MARK: - Storage Keys
    private enum Keys {
        static let favoriteRituals      = "favoriteRitualIds"
        static let favoriteAnnualRituals = "favoriteAnnualRitualIds"
        static let viewedRituals        = "viewedRitualIds"
    }

    // MARK: - Published State
    @Published var favoriteRitualIds: Set<String> {
        didSet { save(favoriteRitualIds, forKey: Keys.favoriteRituals) }
    }

    @Published var favoriteAnnualRitualIds: Set<String> {
        didSet { save(favoriteAnnualRitualIds, forKey: Keys.favoriteAnnualRituals) }
    }

    @Published var viewedRitualIds: Set<String> {
        didSet { save(viewedRitualIds, forKey: Keys.viewedRituals) }
    }

    // MARK: - Init
    private init() {
        favoriteRitualIds        = UserDataStore.load(forKey: Keys.favoriteRituals)
        favoriteAnnualRitualIds  = UserDataStore.load(forKey: Keys.favoriteAnnualRituals)
        viewedRitualIds          = UserDataStore.load(forKey: Keys.viewedRituals)
    }

    // MARK: - Ritual Object Favorites
    func isFavorite(_ ritual: RitualInfo) -> Bool {
        favoriteRitualIds.contains(ritual.id.uuidString)
    }

    func toggleFavorite(_ ritual: RitualInfo) {
        let key = ritual.id.uuidString
        if favoriteRitualIds.contains(key) {
            favoriteRitualIds.remove(key)
        } else {
            favoriteRitualIds.insert(key)
        }
    }

    // MARK: - Annual Ritual Favorites
    func isFavorite(_ ritual: AnnualRitual) -> Bool {
        favoriteAnnualRitualIds.contains(ritual.id.uuidString)
    }

    func toggleFavorite(_ ritual: AnnualRitual) {
        let key = ritual.id.uuidString
        if favoriteAnnualRitualIds.contains(key) {
            favoriteAnnualRitualIds.remove(key)
        } else {
            favoriteAnnualRitualIds.insert(key)
        }
    }

    // MARK: - Viewed Status
    func markViewed(_ ritual: RitualInfo) {
        viewedRitualIds.insert(ritual.id.uuidString)
    }

    func isViewed(_ ritual: RitualInfo) -> Bool {
        viewedRitualIds.contains(ritual.id.uuidString)
    }

    // MARK: - Favorites Lists
    var favoriteRituals: [RitualInfo] {
        RitualDatabase.allRituals.values.filter { isFavorite($0) }
            .sorted { $0.name < $1.name }
    }

    var favoriteAnnualRituals: [AnnualRitual] {
        AnnualRitualDatabase.rituals.filter { isFavorite($0) }
            .sorted { $0.name < $1.name }
    }

    // MARK: - UserDefaults Helpers
    private static func load(forKey key: String) -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(array)
    }

    private func save(_ set: Set<String>, forKey key: String) {
        UserDefaults.standard.set(Array(set), forKey: key)
    }
}

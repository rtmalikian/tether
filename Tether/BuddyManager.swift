import Foundation
import MultipeerConnectivity
import Combine

/// A nearby buddy discovered over the local network.
struct Buddy: Identifiable, Hashable {
    let peerID: MCPeerID
    var onBreak = false
    var lastSeen = Date()

    var id: String { peerID.displayName }
    var displayName: String { peerID.displayName }

    func hash(into hasher: inout Hasher) { hasher.combine(peerID.displayName) }
    static func == (lhs: Buddy, rhs: Buddy) -> Bool {
        lhs.peerID.displayName == rhs.peerID.displayName
    }
}

/// Buddy system: accountability without accounts or servers.
///
/// Buddies find each other over the local network (MultipeerConnectivity —
/// same Wi-Fi). You can see when a buddy starts a break, nudge them to touch
/// grass, and log real-world activities together. The `BuddySyncProvider`
/// seam is where a future opt-in cloud service plugs in for the global mesh.
final class BuddyManager: NSObject, ObservableObject {
    static let serviceType = "tether-buddy" // 1-15 chars, lowercase

    @Published var enabled: Bool = true {
        didSet {
            var s: AppSettings = Store.load("settings", default: AppSettings())
            s.enableBuddyDiscovery = enabled
            Store.save(s, as: "settings")
            enabled ? start() : stop()
        }
    }
    @Published private(set) var buddies: [Buddy] = []
    @Published private(set) var feed: [String] = []
    @Published private(set) var sharedActivities: [SharedActivity] =
        Store.load("activities", default: [])

    private let peerID: MCPeerID
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser

    override init() {
        let s: AppSettings = Store.load("settings", default: AppSettings())
        let name = String(s.buddyDisplayName.prefix(30))
        peerID = MCPeerID(displayName: name.isEmpty ? "Tether User" : name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                               discoveryInfo: ["app": "tether"],
                                               serviceType: Self.serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        enabled = s.enableBuddyDiscovery
        if enabled { start() }
    }

    func start() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        buddies = []
    }

    var buddiesOnBreak: [Buddy] { buddies.filter { $0.onBreak } }

    // MARK: - Outgoing

    func announceBreakStart() { send(type: "break-start", text: nil) }
    func announceBreakEnd() { send(type: "break-end", text: nil) }

    func nudge(_ buddy: Buddy) {
        guard let peer = session.connectedPeers.first(where: { $0.displayName == buddy.displayName })
        else { return }
        send(BuddyMessage(type: "nudge", sender: peerID.displayName,
                          text: "Time to touch grass together?"), to: [peer])
        pushFeed("You nudged \(buddy.displayName) to take a break.")
    }

    func logSharedActivity(title: String, with buddyName: String?) {
        let activity = SharedActivity(date: Date(), title: title, withBuddy: buddyName)
        sharedActivities.insert(activity, at: 0)
        Store.save(sharedActivities, as: "activities")
        send(type: "activity", text: title)
        pushFeed("You logged “\(title)”" + (buddyName.map { " with \($0)" } ?? "") + ".")
    }

    // MARK: - Private

    private func send(type: String, text: String?) {
        send(BuddyMessage(type: type, sender: peerID.displayName, text: text), to: nil)
    }

    private func send(_ message: BuddyMessage, to peers: [MCPeerID]?) {
        let targets = peers ?? session.connectedPeers
        guard !targets.isEmpty, let data = try? JSONEncoder().encode(message) else { return }
        try? session.send(data, toPeers: targets, with: .reliable)
    }

    private func pushFeed(_ line: String) {
        DispatchQueue.main.async {
            self.feed.insert(line, at: 0)
            self.feed = Array(self.feed.prefix(50))
        }
    }

    private func updateBuddy(_ peer: MCPeerID, onBreak: Bool?) {
        DispatchQueue.main.async {
            if let i = self.buddies.firstIndex(where: { $0.displayName == peer.displayName }) {
                if let onBreak { self.buddies[i].onBreak = onBreak }
                self.buddies[i].lastSeen = Date()
            } else {
                self.buddies.append(Buddy(peerID: peer, onBreak: onBreak ?? false))
            }
        }
    }

    private func handle(_ message: BuddyMessage) {
        switch message.type {
        case "break-start":
            if let peer = session.connectedPeers.first(where: { $0.displayName == message.sender }) {
                updateBuddy(peer, onBreak: true)
            }
            pushFeed("\(message.sender) started a break. Join them?")
        case "break-end":
            if let peer = session.connectedPeers.first(where: { $0.displayName == message.sender }) {
                updateBuddy(peer, onBreak: false)
            }
        case "nudge":
            pushFeed("\(message.sender) nudged you: \(message.text ?? "take a break")")
            Notifications.post(title: "\(message.sender) nudged you",
                               body: message.text ?? "Time for a break?")
        case "activity":
            pushFeed("\(message.sender) logged: \(message.text ?? "an activity")")
        default:
            break
        }
    }
}

// MARK: - Multipeer delegates

extension BuddyManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            updateBuddy(peerID, onBreak: nil)
            pushFeed("\(peerID.displayName) connected as your buddy.")
        case .notConnected:
            DispatchQueue.main.async {
                self.buddies.removeAll { $0.displayName == peerID.displayName }
            }
            pushFeed("\(peerID.displayName) disconnected.")
        default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = try? JSONDecoder().decode(BuddyMessage.self, from: data) {
            handle(message)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                 fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension BuddyManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session) // auto-accept nearby buddies
    }
}

extension BuddyManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        guard info?["app"] == "tether" else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 20)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

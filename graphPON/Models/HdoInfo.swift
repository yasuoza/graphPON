class HdoInfo: NSObject {

    var hdoServiceCode: String! = ""
    var packetLogs: [PacketLog] = []

    init(hdoServiceCode: String) {
        self.hdoServiceCode = hdoServiceCode
    }

    init(hdoServiceCode: String, packetLogs: [PacketLog]) {
        self.hdoServiceCode = hdoServiceCode
        self.packetLogs = packetLogs
    }

    func appendPacketLog(packetLog: PacketLog) {
        self.packetLogs.append(packetLog)
    }
   
}

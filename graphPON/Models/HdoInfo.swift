class HdoInfo: NSObject {

    var hdoServiceCode: String! = ""
    var packetLogs: Array<PacketLog>! = []

    init(hdoServiceCode: String) {
        self.hdoServiceCode = hdoServiceCode
    }

    init(hdoServiceCode: String, packetLogs: Array<PacketLog>) {
        self.hdoServiceCode = hdoServiceCode
        self.packetLogs = packetLogs
    }

    func addPacketLog(packetLog: PacketLog) {
        self.packetLogs.append(packetLog)
    }
   
}

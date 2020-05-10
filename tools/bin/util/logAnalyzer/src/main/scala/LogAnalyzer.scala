
import java.nio.file.{Files, Path, Paths}
import java.time.{LocalDateTime, Instant, ZoneId}
import java.time.temporal.ChronoUnit
import java.time.format.DateTimeFormatter
import scala.io.Source
import scala.util.{Try, Success, Failure}
import scala.collection.mutable.{Map, ArrayBuffer, ListMap}
import scala.collection.JavaConverters._
import scala.tools.nsc.io.File

/**
 * This program allows to parse logs generated by Lepton, ADTN and IBRDTN platforms.
 * It extracts data from the given files and produces 3 main kind  of information
 *   Global: overview numbers on the experiment such as the duration, number of messages sent/received..
 *   Node: this section contains information on all evolved nodes (activity duration, number of messages sent...) 
 *   Message: give information about messages exchanged during the experiment (source, destination, receive time, ...)
 *
 * Required arguments:
 *      - lepton_out_file : the output file produced by Lepton (lepton.out)
 *      - dtn_out_dir     : the directory containing the DTN system generated logs. 
 *      - dtn_type        : the DTN type (adtn | ibrdtn). 
 *
 * Optional arguments:
 *      - output_file     : the output file. 
 *
 * @version 04/2020
 */
object Main {

    def main(args : Array[String]) = {

        def usage = {
            println("\nusage: <lepton_out_file> <dtn_out_dir> <dtn_type> [output_file]");
            println("  Required");
            println("    lepton_out_file : the output file produced by Lepton (lepton.out)");
            println("    dtn_out_dir     : the directory containing the DTN generated logs");
            println("    dtn_type        : the DTN type (adtn | ibrdtn)");
            println("  Optional");
            println("    output_file     : the output file\n");
            System.exit(1);
        }

        if( args.length < 3 || args(0) == "-h" ) { // usage check 
            usage;
        }
        if( args(2) != "adtn" && args(2) != "ibrdtn" ) usage;

        val leptonOutFilePath = Paths.get(args(0));
        val dtnOutDirPath = Paths.get(args(1));
        val isAdtn = if(args(2) == "adtn") true else false;
        val outputFile = if(args.length > 3) args(3) else "output.txt";
        
        println("Starting LogAnalyzer");
        println(" outputFile -> " + outputFile);
        var data = LogAnalyzer.process(leptonOutFilePath, dtnOutDirPath, isAdtn);
        File(outputFile).writeAll(data.toString);
        println("\n"+data);
    }

    /**
     * This class represents the global information section. It computes the duration of an experiment based on the
     * given starTime and the EndTime of Lepton.
     * 
     *   startTime        : the lepton start time.
     *   endTime          : the lepton end time (date of the last recorded event by lepton)
     *   activeNodes      : the number of active nodes
     *   sndEvents        : the total number of messages sent by all nodes during an experiment
     *   rcvEvents        : the total number of messages received by all nodes during an experiment
     *   minRcvDuration   : the minimum rcvDuration of all received messages during an experiment
     *   maxRcvDuration   : the maximum rcvDuration of all received messages during an experiment
     *   totalRcvDuration : the sum of all messages' rcvDuration during an experiment
     */
    case class Global(var startTime : LocalDateTime = LocalDateTime.now, 
        var endTime : LocalDateTime = LocalDateTime.now,
        var activeNodes : Int = 0, var sndEvents : Int = 0, var rcvEvents : Int = 0, 
        var minRcvDuration : Long = -1L, var maxRcvDuration : Long = -1L, var totalRcvDuration : Long = 0L) {

        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")

        def duration = ChronoUnit.SECONDS.between(startTime, endTime)

        override def toString() : String = {
            var sb = new StringBuilder
            sb ++= "[Global]" + "\n"
            sb ++= "  start time        : "+ formatter.format(startTime) + "\n"
            sb ++= "  duration (s)      : "+ duration + "\n"
            sb ++= "  active nodes      : "+ activeNodes + "\n"
            sb ++= "  messages sent     : "+ sndEvents +" \n"
            sb ++= "  messages received : "+ rcvEvents + " ("+ Try((rcvEvents*100)/sndEvents).getOrElse(0) +"%)"+ "\n"
            sb ++= "  messages lost     : "+ (sndEvents - rcvEvents) +" \n"
            sb ++= "  rcv duration (s)  : "+ minRcvDuration +", "+ maxRcvDuration +", "+ Try(totalRcvDuration/rcvEvents).getOrElse(0) +" (min, max, avg)" +" \n"
            sb ++= "\n"
            sb.toString
        }
    }
    
    /**
     * This class contains information about a Node.
     *
     *   nodeId            : the node identifier.
     *   activityStartTime : date of the first activity of a node (first beacon).
     *   activityEndTime   : date of the last activity of a node.
     *   totalSnd          : the total number of messages sent by a node.
     *   totalRcv          : the total number of messages sent to a node.
     *   nbRcv             : the number of effective messages received by a node.
     *   minNbNeighbors    : the minimum  number of neighbor with which the node interact at a given moment.
     *   maxNbNeighbors    : the maximum  number of neighbor with which the node interact at a given moment.
     *   outConnection     : the number connections initiated by a node.
     *   inConnection      : the number of connection received by a node.
     *   minRcvDuration    : the minimum rcvDuration of a node.
     *   maxRcvDuration    : the maximum rcvDuration of a node.
     *   totalRcvDuration  : the sum of rcvDuration of all messages received by a node.
     */
    case class Node(var nodeId : String, var activityStartTime : Option[LocalDateTime] = None, 
        var activityEndTime : Option[LocalDateTime] = None,
        var totalSnd : Int = 0, var totalRcv : Int = 0, var nbRcv : Int = 0, 
        var minNbNeighbors : Int = 0, var maxNbNeighbors : Int = 0,
        var outConnection : Int = 0, var inConnection : Int = 0,
        var minRcvDuration : Long = -1L, var maxRcvDuration : Long = -1L, var totalRcvDuration : Long = 0L
    ) extends Ordered [Node] {

        def activityDuration : Long = ChronoUnit.SECONDS.between(
            activityStartTime.getOrElse(LocalDateTime.now), 
            activityEndTime.getOrElse(LocalDateTime.now)
        )

        def avgRcvDuration : Long = Try(totalRcvDuration/nbRcv).getOrElse(0)

        override def toString : String = {
            var sb = new StringBuilder
            sb ++= f" ${nodeId}%10s" + " "*4
            sb ++= f" ${activityDuration}%5d" + " "*8
            sb ++= f" ${totalSnd}%3d" + " "*7
            sb ++= f" ${nbRcv}%3d/${totalRcv}" + " "*7
            sb ++= f" ${minNbNeighbors}%2d" + " "*6
            sb ++= f" ${maxNbNeighbors}%2d" + " "*5
            sb ++= f" ${outConnection}%5d" + " "*3
            sb ++= f" ${inConnection}%5d" + " "*3
            sb ++= f" (${minRcvDuration}, ${maxRcvDuration}, ${avgRcvDuration})" 
            sb.toString
        }

        def compare(that : Node) : Int = this.nodeId compare that.nodeId
    }

    /**
     * This class represents a Message. It contains information on an exchanged message
     * between two nodes.
     *
     *   msgId           : the message identifier
     *   src             : the source nodes of a message.
     *   dst             : the destination node of a message
     *   sndTime         : the send date of a message
     *   rcvTime         : the received date of a message
     *   leptonStartTime : the lepton start time. Useful to compute the duration
     */
    case class Message(var msgId : String, var src : String, var dst : String,
        var sndTime : LocalDateTime, var rcvTime : Option[LocalDateTime] = None, 
        var leptonStartTime : LocalDateTime) extends Ordered[Message] {
        
        val formatter = DateTimeFormatter.ofPattern("HH:mm:ss")

        def sndStep : Long = ChronoUnit.MILLIS.between(leptonStartTime, sndTime)
        def rcvStep : Long = if(rcvTime.isDefined) ChronoUnit.MILLIS.between(leptonStartTime, rcvTime.get) else -1L
        def rcvDuration : Long = if(rcvTime.isDefined) ChronoUnit.SECONDS.between(sndTime, rcvTime.get) else -1L
        def compare(that : Message): Int = this.sndTime compareTo that.sndTime
        // def compare(that : Message): Int = this.rcvDuration compare that.rcvDuration
        // def compare(that : Message): Int = this.src compare that.src

        override def toString : String = {
            var sb = new StringBuilder
            sb ++= f" ${msgId}%20s" + " "*3
            sb ++= f" ${src}%10s" + " "*3
            sb ++= f" ${dst}%10s" + " "*3
            sb ++= f" ${sndStep}%10d" + " "*5
            sb ++= f" ${rcvStep}%10d" + " "*2
            sb ++= f" ${rcvDuration}%10d" + " "*9
            sb ++= f" ${formatter.format(sndTime)}%8s" + " "*3
            sb ++= f" ${if(rcvTime.isDefined) formatter.format(rcvTime.get)}%8s"
            sb.toString
        }
    }

    /**
     * This class is a container of the 3 main sections of data (Gloabl, Nodes, Massages)
     * extracted from log files.
     */
    case class Data(var global : Global, var nodes : Map[String, Node], var messages : Map[String, Message]) {
        override def toString() = {
            var sb = new StringBuilder
            sb ++= global.toString

            sb ++= "[Nodes]" + "\n"
            sb ++= "-"*105 + "\n"
            sb ++= " "*4+ "NodeId" +" "*4+ "duration (s)" +" "*3+ "sndEvts" +" "*3+ "nbRcv/total" +" "*3+ "minNhb" +" "*3+ "maxNhb" +" "*3+ "outCon" +" "*4+ "inCon" +" "*3+ "rcvDuration (s)" + "\n"
            sb ++= "-"*105 + "\n"
            nodes.values.toList.sorted.foreach( x => sb ++= x + "\n"  )
            sb ++= "\n"

            sb ++= "[Messages]" + "\n"
            sb ++= "-"*125 + "\n"
            sb ++= " "*8 + "MessageId" + " "*13 + "src" + " "*11 + "dst" + " "*9 + "sndStep" + " "*9 + "rcvStep" + " "*5 + "rcvDuration (s)" + " "*3 + "sndTime"  + " "*5 + "rcvTime" +"\n"
            sb ++= "-"*125 + "\n"
            messages.values.toList.sorted.foreach( x => sb ++= x + "\n" ) 
            sb.toString;
        }
    }

    /**
     * The main object which analyzes logs
     * @param leptonOutFilePath The lepton output file
     * @param dtnOutDirPath The directory which contains the dtn output files
     * @param isAdtn true if dtn type is ADTN false if IBRDTN
     *
     * @return Data object
     */
    object LogAnalyzer {
        def process(leptonOutFilePath : Path, dtnOutDirPath : Path, isAdtn : Boolean) : Data = { 

            var nodes = Map[String, Node]()
            var messages = Map[String, Message]()
            var global = Global()
            var data = Data(global, nodes, messages)

            // process lepton out in order to extract useful data
            def processLeptonOut() = {
                println("processing Lepton log -> " + leptonOutFilePath + " ...")
                val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS")
                // patterns for extracting useful data
                val pattern_startTime = """\s*start_time\s*: (\d+)""".r; //lepton_
                val pattern_deferred = """\s*start_deferred\s*: (\d+)""".r;
                val pattern_hub = """(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d.\d{3}) hub (.*)""".r;
                val pattern_sdr_rcv = """.*sdr=(\w+),rcv=((?:\w+(?:,\w+)*)?)""".r; // TODO
                val pattern_relay = """relay: opened StreamRelay\((\w+) <=> (\w+)\)""".r;

                Try(Source.fromFile(leptonOutFilePath.toString())) match { // opening the log file
                    case Success(buff) => { // file correctly opened
                        var startTimeEpoch = 0L;
                        var startDeferred = 0;
                        buff.getLines.foreach( _ match { // reading the file line by line
                            case pattern_startTime(strEpoch) => startTimeEpoch = strEpoch.toLong
                            case pattern_deferred(strDeferred) => startDeferred = strDeferred.toInt
                            case pattern_hub(strDate, infos) => {
                                var date = LocalDateTime.parse(strDate, formatter);
                                data.global.endTime = date
                                infos match {
                                    case pattern_sdr_rcv(nodeId, neighbors) => {
                                        var nbNeighbors = neighbors.split(",").size;
                                        if(data.nodes.contains(nodeId)) {
                                            var node = data.nodes(nodeId)
                                            node.activityEndTime = Some(date)
                                            if(node.minNbNeighbors > nbNeighbors) node.minNbNeighbors = nbNeighbors;
                                            if(node.maxNbNeighbors < nbNeighbors) node.maxNbNeighbors = nbNeighbors;
                                        } else { 
                                            data.nodes += (nodeId -> Node(nodeId, Some(date), Some(date), 0, 0, 0, nbNeighbors, nbNeighbors))
                                        }
                                    }
                                    case pattern_relay(nodeId1, nodeId2) => {
                                        if(data.nodes.contains(nodeId1)) {
                                            var node = data.nodes(nodeId1)
                                            node.activityEndTime = Some(date); 
                                            node.outConnection += 1;
                                        } else {
                                            data.nodes += (nodeId1 -> Node(nodeId1, Some(date), Some(date)))
                                        }
                                        if(data.nodes.contains(nodeId2)) {
                                            var node = data.nodes(nodeId2);
                                            node.activityEndTime = Some(date); 
                                            node.inConnection += 1;
                                        } else {
                                            data.nodes += (nodeId2 -> Node(nodeId2, Some(date), Some(date)))
                                        }
                                    }
                                    case _ =>
                                }
                            }
                            case _ =>
                        })
                        buff.close()
                        data.global.startTime = Instant.ofEpochMilli(startTimeEpoch).atZone(ZoneId.systemDefault()).toLocalDateTime();
                        data.global.startTime.plusSeconds(startDeferred);
                    }
                    case Failure(e) => println(e) // fail to open the file
                }
                println("job done [Lepton out]")
            }
            
            // process dtn logs in order to extract useful data
            def processNodesLog() = {
                println("processing Nodes logs -> " + dtnOutDirPath + " ...")

                val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
                val logFileName = if(isAdtn) "adtn.log" else "log.log"

                def adtnLineProcessor(line : String, map : Map[String, Tuple3[LocalDateTime, String, String]]) {
                    val pattern_main = """\[(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)\]\[.*\]\[.*\]\[.*\] - (.*)""".r;
                    val pattern_create = """New Bundle created (\w+) (\w+)@(\w+)""".r; // dmis01_641397941_0
                    val pattern_received = """Received Bundle (\w+) (\w+)@(\w+)""".r;
                    line match {
                        case pattern_main(strDate, infos) => {
                            val date = LocalDateTime.parse(strDate, formatter);
                            infos match {
                                case pattern_create(msgId, src, dst) => { 
                                    data.global.sndEvents += 1; 
                                    if(data.nodes.contains(src)) data.nodes(src).totalSnd += 1; 
                                    if(data.nodes.contains(dst)) data.nodes(dst).totalRcv += 1; 
                                    if(data.messages.contains(msgId)) 
                                        data.messages(msgId).sndTime = date 
                                    else
                                        data.messages += (msgId -> Message(msgId, src, dst, date, None, data.global.startTime))
                                }
                                case pattern_received(msgId, src, dst) => 
                                    if(!map.contains(msgId)) map += (msgId -> Tuple3(date, src, dst))
                                case _ =>
                            }
                        }
                        case _ =>
                    }
                }

                def ibrdtnLineProcessor(line : String, map : Map[String, Tuple3[LocalDateTime, String, String]]) {
                    val pattern_crt = """CREATE,(.*),(.*),(.*),(.*)""".r
                    val pattern_rcv = """RECEIVE,(.*),(.*),(.*),(.*)""".r
                    line match {
                        case pattern_crt(strDate, msgId, src, dst) => {
                            data.global.sndEvents += 1
                            if(data.nodes.contains(src)) data.nodes(src).totalSnd += 1;
                            val date = LocalDateTime.parse(strDate, formatter);
                            if(dst != "unknown") data.nodes(dst).totalRcv += 1;
                            if(data.messages.contains(msgId)) 
                                data.messages(msgId).sndTime = date 
                            else
                                data.messages += (msgId -> Message(msgId, src, dst, date, None, data.global.startTime))
                        } case pattern_rcv(strDate, msgId, src, dst) => {
                            val date = LocalDateTime.parse(strDate, formatter);
                            if(!map.contains(msgId)) map += (msgId -> Tuple3(date, src, dst))
                        }
                        case _ =>
                    }
                }

                def process(lineProcessor : (String, Map[String, Tuple3[LocalDateTime, String, String]]) => Unit) = {
                    Files.list(dtnOutDirPath).iterator().asScala // get scala iterator over DTN log dir path
                        .foreach( nodeDirPath => { // iterate through all files in the directory
                        if(Files.isDirectory(nodeDirPath)) {
                            val logFilePath = nodeDirPath.resolve(logFileName)
                            if(Files.isRegularFile(logFilePath)) {
                                Try(Source.fromFile(logFilePath.toString())) match {
                                    case Success(buff) => {
                                        var map = Map[String, Tuple3[LocalDateTime, String, String]]()
                                        buff.getLines.foreach( l => lineProcessor(l, map)) 
                                        buff.close
                                        if(!map.isEmpty) { // if at least one message is received
                                            for((msgId, (date, src, dst)) <- map) {
                                                data.global.rcvEvents += 1;
                                                if(data.nodes.contains(dst)) data.nodes(dst).nbRcv += 1;
                                                if(data.messages.contains(msgId)) 
                                                    data.messages(msgId).rcvTime = Some(date) 
                                                else
                                                    data.messages += (msgId -> Message(msgId, src, dst, date, Some(date), data.global.startTime))
                                            }
                                        }
                                    }
                                    case Failure(e) => println(e)
                                }
                            }
                        }
                    })
                }

                val lineProcessor = if(isAdtn) adtnLineProcessor _ else ibrdtnLineProcessor _
                process(lineProcessor)

                println("job done [Nodes]")
            }
            
            // Compute some statistics
            def computeStatistics() = {
                for(msg <- data.messages.values) {
                    if(msg.rcvDuration >= 0 && data.nodes.contains(msg.dst)) {
                        data.nodes(msg.dst).totalRcvDuration += msg.rcvDuration
                        val min = data.nodes(msg.dst).minRcvDuration
                        if(min == -1 || min > msg.rcvDuration) {
                            data.nodes(msg.dst).minRcvDuration = msg.rcvDuration
                        }
                        if(data.nodes(msg.dst).maxRcvDuration < msg.rcvDuration) {
                            data.nodes(msg.dst).maxRcvDuration = msg.rcvDuration
                        }
                        data.global.totalRcvDuration += msg.rcvDuration
                    }
                }
                for(node <- data.nodes.values) {
                    val min = data.global.minRcvDuration
                    if( min == -1 || min > node.minRcvDuration ) {
                        data.global.minRcvDuration = node.minRcvDuration
                    }
                    if( data.global.maxRcvDuration < node.maxRcvDuration ) {
                        data.global.maxRcvDuration = node.maxRcvDuration
                    }
                }
            }

            processLeptonOut
            processNodesLog
            data.global.activeNodes = data.nodes.size
            computeStatistics
            data
        }
    }

}
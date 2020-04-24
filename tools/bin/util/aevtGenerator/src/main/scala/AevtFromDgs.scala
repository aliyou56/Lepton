import scala.collection.mutable.ArrayBuffer
import scala.io.Source
import scala.util.{Random, Try, Success, Failure}
import scala.tools.nsc.io.File

object Main {

    def main(args : Array[String]) = {
        
        if( args.length < 1 || "-h".equals(args(0)) ) { // usage
            println("usage: <dgs_file> [aevt_out_filename]")
            System.exit(1)
        }

        var nodes = ArrayBuffer[String]() // 
        var result = new StringBuilder
        var outputFilename = "app.aevt" // default name of the output file
        if(args.length > 1) outputFilename = args(1)
        val online_pattern = """online=(true|false)""".r;

        Try(Source.fromFile(args(0))) match {
            case Success(buff) => {
                buff.getLines.foreach( line => {
                    processLine(line) match {
                        case Some(s) => result ++= s + "\n"
                        case None =>
                    }
                })
                buff.close
                File(outputFilename).writeAll(result.toString)
            } 
            case Failure(e) => println(e) 
        }

        def processLine(line : String) : Option[String] = {
            var res : Option[String] = None
            val pattern_st = """st (\d+)""".r;
            val pattern_an = """an (\w+) (.*)""".r;
            val pattern_cn = """cn (\w+) online=(true|false)""".r;
            val pattern_dn = """dn (\w+)""".r;
            line match {
                case pattern_st(step) => {
                    if(nodes.size > 1) {
                        if ( (Random.nextDouble * 5).toInt == 0 ) {
                            var idx1 = Random.nextInt(nodes.size)
                            var idx2 = Random.nextInt(nodes.size)
                            if (idx1 == idx2) {
                                idx2 = (idx2 + 1) % nodes.size;
                            }
                            res = Some(step +" snd "+ nodes(idx1) +" dst-id="+ nodes(idx2) +" mid="+ nodes(idx1) +"@" + nodes(idx2) +"-"+ step)
                        }
                    }
                }
                case pattern_an(nodeId, params) => if(!params.contains("online=false")) nodes += nodeId;
                case pattern_cn(nodeId, online) => if(Try(online.toBoolean).getOrElse(false)) nodes += nodeId else nodes -= nodeId;
                case pattern_dn(nodeId) => nodes -= nodeId;
                case _ =>
            }
            res
        }
    }
}
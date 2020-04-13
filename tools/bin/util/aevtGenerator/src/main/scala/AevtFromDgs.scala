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
            val values = line.split(" ")
            if(values.size > 1)
            values(0) match {
                case "st" => {
                    if(nodes.size > 1) {
                        if ( (Random.nextDouble * 5).toInt == 0 ) {
                            var idx1 = Random.nextInt(nodes.size)
                            var idx2 = Random.nextInt(nodes.size)
                            if (idx1 == idx2) {
                                idx2 = (idx2 + 1) % nodes.size;
                            }
                            val step = values(1)
                            res = Some(step +" snd "+ nodes(idx1) +" dst-id="+ nodes(idx2) +" mid="+ nodes(idx1) +"@" + nodes(idx2) +"-"+ step)
                        }
                    }
                }  
                case "an" => {
                    var nodeId = values(1)
                    // val typeArr = values(2).split(" ")
                    // if(typeArr(0).equals("profile")) {
                    //     nodeId += ":" + typeArr(1) 
                    // }
                    nodes += nodeId
                }
                case "dn" => {
                    val nodeId = values(1)
                    nodes -= nodeId
                }
                case _ =>
            }
            res
        }
    }
}
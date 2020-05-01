import scala.io.Source
import scala.math.BigDecimal
import scala.tools.nsc.io.File
import scala.util.{Try, Success, Failure}
import java.nio.file.{Path, Paths}

/**
 * This program cleans the given performance file. It produces a new file 
 *  containing the cleaned data. If no output filename is given, data are stored
 *  in the same directory of the given input file.
 * 
 * Input Arguments
 *    Required:
 *      - performance_file : the file to be cleaned
 * 
 *    optional:
 *      - output_filename : the file which will contain the cleaned data
 * 
 * Output
 *      - new file containing cleaned data.
 *          format: step cpu(%) mem(%)
 *
 * @version 04/2020
 */
object Main {
    def main(args : Array[String]) = {

        if(args.length < 1 || "-h".equals(args(0))) { // usage check 
            println("usage: <performance_file> [output-file]");
            System.exit(1);
        }

        val inputPath = Paths.get(args(0));
        var outputPath = inputPath.getParent().resolve("cleaned-" + inputPath.getFileName());
        if(args.length > 1) outputPath = Paths.get(args(1))
        val data = new StringBuilder("# time(s) cpu(%) mem(%)" + "\n")
        
        // round double value 
        def round(v : Double): Double = BigDecimal(v).setScale(2, BigDecimal.RoundingMode.HALF_UP).toDouble

        Try(Source.fromFile(inputPath.toString())) match { 
            case Success(buff) => {
                var x = 0; var cpu = 0.0; var mem = 0.0;
                val pattern_x = """x=(\d+)""".r; 
                val pattern_v = """(\d+) (\d+.\d+) (\d+.\d+) (.+)""".r; 

                buff.getLines.foreach( _ match {
                    case pattern_x(x_) => {
                        if(x != 0) {
                            data ++= s"${x} ${round(cpu)} ${round(mem)}" + "\n";
                            x = 0; cpu = 0.0; mem = 0.0;
                        } else x = x_.toInt
                    }
                    case pattern_v(pid_, cpu_, mem_, command_) => {
                        cpu += cpu_.toDouble;
                        mem += mem_.toDouble;
                    }
                    case _ =>
                })
                buff.close();
            }
            case Failure(e) => println(e);
        }
        File(outputPath.toString()).writeAll(data.toString)
        // println(data)
    }
}
import java.io.*;

/**
 *
 * @author Jackpot
 */
public class filecopy {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        File dir = new File("included");
        File apps = new File("apps");
        FilenameFilter filter = new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return !name.startsWith(".");
            }
        };
        FilenameFilter asmfilter = new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return (!name.startsWith(".") && name.endsWith(".asm"));
            }
        };
        String[] files = dir.list(filter);
        String[] appfiles = apps.list(asmfilter);
        File indexlist = new File("files.asm");
        BufferedWriter br = new BufferedWriter(new FileWriter(indexlist));
        br.write("diskfileindex:\n");
        for(int i=0; i<files.length; i++)
        {
            br.write("db \"" + files[i] + "\",0\n");
            br.write("dd (f" + i + "-$$)/512\n");
            br.write("dd (f" + (i + 1) + "-f" + i + ")/512\n");
        }
        for(int i=0; i<appfiles.length; i++)
        {
            br.write("db \"" + appfiles[i].substring(0, appfiles[i].length() - 4) + "\",0\n");
            br.write("dd (af" + i + "-$$)/512\n");
            br.write("dd (af" + (i + 1) + "-af" + i + ")/512\n");
        }
        br.write("enddiskfileindex:\n\n");
        br.write("align 512,db 0\n");
        for(int i=0; i<files.length; i++)
        {
            br.write("f" + i + ":\n");
            br.write("incbin " + "\"included/" + files[i] + "\"\n");
            br.write("align 512,db 0\n");
        }
        br.write("f" + files.length + ":\n");
        for(int i=0; i<appfiles.length; i++)
        {
            br.write("af" + i + ":\n");
            br.write("%include " + "\"apps/" + appfiles[i] + "\"\n");
            br.write("align 512,db 0\n");
        }
        br.write("af" + appfiles.length + ":\n");
        br.close();
    }

}

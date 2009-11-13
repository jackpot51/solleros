import java.io.*;
/*
 * @author Jackpot
 */
public class filecopy {
    /*
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        File apps = new File("apps");
        File included = new File ("included");
        String appsdir = apps.getCanonicalPath() + "/";
        String includeddir = included.getCanonicalPath() + "/";
        FilenameFilter asmfilter = new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return (!name.startsWith(".") && name.endsWith(".asm"));
            }
        };
        FilenameFilter cfilter = new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return (!name.startsWith(".") && name.endsWith(".c"));
            }
        };
        FilenameFilter cppfilter = new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return (!name.startsWith(".") && name.endsWith(".cpp"));
            }
        };
        String[] asmfiles = apps.list(asmfilter);
        for(int i=0; i<asmfiles.length; i++){
			String s = null;
            String[] command = new String[]{"nasm", appsdir + asmfiles[i], "-f bin", "-o " + includeddir + asmfiles[i].substring(0, asmfiles[i].length() - 4)};
            Process child = Runtime.getRuntime().exec(command);
			BufferedReader stdError = new BufferedReader(new InputStreamReader(child.getErrorStream()));
			BufferedReader stdInput = new BufferedReader(new InputStreamReader(child.getInputStream()));
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
            }
            while ((s = stdError.readLine()) != null) {
                System.out.println(s);
            }
        }
        String[] cfiles = apps.list(cfilter);
        for(int i=0; i<cfiles.length; i++){
			String s = null;
            String[] command = new String[]{"/SollerOS/cross/bin/i586-pc-solleros-gcc", "-o", includeddir + cfiles[i].substring(0, cfiles[i].length() - 2) + ".elf", appsdir + cfiles[i]};
            Process child = Runtime.getRuntime().exec(command);
			BufferedReader stdError = new BufferedReader(new InputStreamReader(child.getErrorStream()));
			BufferedReader stdInput = new BufferedReader(new InputStreamReader(child.getInputStream()));
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
            }
            while ((s = stdError.readLine()) != null) {
                System.out.println(s);
            }
        }
        String[] cppfiles = apps.list(cppfilter);
        for(int i=0; i<cppfiles.length; i++){
			String s = null;
            String[] command = new String[]{"/SollerOS/cross/bin/i586-pc-solleros-g++", "-o", includeddir + cppfiles[i].substring(0, cppfiles[i].length() - 4) + ".elf", appsdir + cppfiles[i]};
            Process child = Runtime.getRuntime().exec(command);
			BufferedReader stdError = new BufferedReader(new InputStreamReader(child.getErrorStream()));
			BufferedReader stdInput = new BufferedReader(new InputStreamReader(child.getInputStream()));
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
            }
            while ((s = stdError.readLine()) != null) {
                System.out.println(s);
            }
        }

        FilenameFilter filter = new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return !name.startsWith(".");
            }
        };
        File dir = new File("included");
        String[] files = dir.list(filter);
        File indexlist = new File("fileindex.asm");
        File filelist = new File("files.asm");
        BufferedWriter br = new BufferedWriter(new FileWriter(indexlist));
        BufferedWriter br2 = new BufferedWriter(new FileWriter(filelist));
        br.write("diskfileindex:\n");
        for(int i=0; i<files.length; i++)
        {
            br.write("db \"" + files[i] + "\",0\n");
            br.write("dd (f" + i + "-$$)/512\n");
            br.write("dd (f" + (i + 1) + "-f" + i + ")/512\n");
        }
        br.write("enddiskfileindex:\n\n");
		br.close();
		br2.write("align 512,db 0\n");
        for(int i=0; i<files.length; i++)
        {
            br2.write("f" + i + ":\n");
            br2.write("incbin " + "\"included/" + files[i] + "\"\n");
			br2.write("align 512,db 0\n");
        }
        br2.write("f" + files.length + ":\n");
        br2.close();
    }
}

import java.io.*;
/*
 * @author Jackpot
 */
public class fsmaker {
    /*
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        File apps = new File("../apps");
		File included = new File ("../included");
		File indexlist = new File("../build/fileindex.asm");
		File filelist = new File("../build/files.asm");
		BufferedWriter br = new BufferedWriter(new FileWriter(indexlist));
		BufferedWriter br2 = new BufferedWriter(new FileWriter(filelist));
		if(apps.exists() && included.exists()){
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
			String ccomp = "";
			if(new File("/SollerOS/cross/bin/i586-pc-solleros-gcc").exists()){
				ccomp = "/SollerOS/cross/bin/i586-pc-solleros-gcc";
			}
			if(new File("\\cygwin\\SollerOS\\cross\\bin\\i586-pc-solleros-gcc.exe").exists()){
				ccomp="\\cygwin\\SollerOS\\cross\\bin\\i586-pc-solleros-gcc.exe";
			}
			if(!ccomp.equals("")){
				System.out.println("GCC: " + ccomp);
				String[] cfiles = apps.list(cfilter);
				for(int i=0; i<cfiles.length; i++){
					String s = null;
                                        String[] command;
                                        if(cfiles[i].endsWith(".n.c")){
                                        	command = new String[]{ccomp, "-nostdlib", "-s", "-o", includeddir + cfiles[i].substring(0, cfiles[i].length() - 4) + ".elf", appsdir + cfiles[i]};
                                        }else{
                                                command = new String[]{ccomp, "-s", "-o", includeddir + cfiles[i].substring(0, cfiles[i].length() - 2) + ".elf", appsdir + cfiles[i]};
                                        }
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
			}else{
				System.out.println("Could not find GCC");
			}
			String cppcomp = "";
			if(new File("/SollerOS/cross/bin/i586-pc-solleros-g++").exists()){
				cppcomp = "/SollerOS/cross/bin/i586-pc-solleros-g++";
			}
			if(new File("\\cygwin\\SollerOS\\cross\\bin\\i586-pc-solleros-g++.exe").exists()){
				cppcomp="\\cygwin\\SollerOS\\cross\\bin\\i586-pc-solleros-g++.exe";
			}
			if(!cppcomp.equals("")){
				System.out.println("G++: " + cppcomp);
				String[] cppfiles = apps.list(cppfilter);
				for(int i=0; i<cppfiles.length; i++){
					String s = null;
					String[] command = new String[]{cppcomp, "-s", "-o", includeddir + cppfiles[i].substring(0, cppfiles[i].length() - 4) + ".elf", appsdir + cppfiles[i]};
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
			}else{
				System.out.println("Could not find G++");
			}
			FileFilter filter = new FileFilter() {
				public boolean accept(File f) {
					return !f.getName().startsWith(".") && f.isFile();
				}
			};
			File dir = new File("../included");
			File[] files = dir.listFiles(filter);
			br.write("diskfileindex:\n");
			for(int i=0; i<files.length; i++)
			{
				br.write("db \"" + files[i].getName() + "\",0\n");
				br.write("dd (f" + i + "-$$)/512\n");
				br.write("dd (f" + (i + 1) + "-f" + i + ")/512\n");
			}
			br.write("enddiskfileindex:\n\n");
			br.close();
			br2.write("align 512,db 0\n");
			for(int i=0; i<files.length; i++)
			{
				br2.write("f" + i + ":\n");
				br2.write("incbin " + "\"included/" + files[i].getName() + "\"\n");
				br2.write("align 512,db 0\n");
			}
			br2.write("f" + files.length + ":\n");
			br2.close();
		}else{
			br.write("diskfileindex:\n");
			br.write("enddiskfileindex:\n\n");
			br.close();
			br2.close();
		}
	}
}

import java.io.*;
/*
 * @author Jeremy Soller
 */
public class unfs {
    static BufferedWriter br;
    static BufferedWriter brb;
    static BufferedWriter bri;
    static BufferedWriter brn;
    static File imgMain;
    static File imgOut;
    static File imgIndex;
    static File imgNodes;
    static File imgBinary;
    static FilenameFilter hiddenfilter = new FilenameFilter() {
            public boolean accept(File dir, String name) {
                return (!name.startsWith("."));
            }
    };
    public static void initImage(File img){
	try {
            imgOut = img;
            imgMain = new File(imgOut.getName() + ".asm");
            imgBinary = new File(imgOut.getName() + "-inc.asm");
            imgNodes = new File(imgOut.getName() + "-node.asm");
            imgIndex = new File(imgOut.getName() + "-index.asm");
            br = new BufferedWriter(new FileWriter(imgMain));
            brb = new BufferedWriter(new FileWriter(imgBinary));
            bri = new BufferedWriter(new FileWriter(imgIndex));
            brn = new BufferedWriter(new FileWriter(imgNodes));
        } catch (IOException ex) {
            System.out.println(ex);
        }
    }
    public static void writeHeader(String t, int v, int bs, int ms, int us, int cs, int ce){
	try {
            br.write("fsys:\n");
            br.write(".h:\n");         //Write header location
            br.write("\tdb " + t.length() + "\n");
            br.write("\tdb \"" + t + "\"\n");//Write the type
            br.write("\tdw " + v + "\n");   //Write the version
            br.write("\tdb " + bs + "\n");  //Write the block pointer size
            br.write("\tdb " + ms + "\n");  //Write the memory pointer size
            br.write("\tdb " + us + "\n");  //Write the user and group ID size
            br.write("\tdb " + cs + "\n");  //Write the character encoding number
            br.write("\tdb " + ce + "\n");  //Write the character encoding number
            br.write("\tdd .NC.Node\n");     //Write the node collection node's location
            br.write("\tdd .IC.Node\n");     //Write the index collection node's location
            //Write the node collection node
            br.write(".NC.Node: dd .NC.NodeEnd\n");
            br.write("\tdw 0\n");
            br.write("\tdd (.NC - .h)/512\n");
            br.write("\tdw 0\n");
            br.write("\tdd (.NCEnd - .h)/512\n");
            br.write(".NC.NodeEnd: dd 0\n");
            //Write the index collection node
            br.write(".IC.Node: dd .IC.NodeEnd\n");
            br.write("\tdw 0\n");
            br.write("\tdd (.IC - .h)/512\n");
            br.write("\tdw 0\n");
            br.write("\tdd (.ICEnd - .h)/512\n");
            br.write(".IC.NodeEnd: dd 0\n");
            //Done with the NCN and ICN, starting the NC
            br.write("align 512, db 0\n");
            br.write(".NC:\n");
            //Start with the Super Root node
            br.write(".SRoot.Node: dd .SRoot.NodeEnd - .h\n");
            br.write("\t.root.Node:\n");
            br.write("\t\tdd .root.Name - .IC\n");
            br.write("\t\tdb 0\n"); //This is a folder
            br.write("\t\tdd 0\n"); //Properties are not used
            br.write("\t\tdd .root.NC - .h\n");
            br.write("\t\tdd 0\n"); //The root node has no parent
            br.write(".SRoot.NodeEnd: dd 0\n");
            br.write("%include \"" + imgNodes.getName() + "\"\n");
			br.write("align 512, db 0\n");
            br.write(".NCEnd:\n");
            br.write(".IC:\n");
            br.write(".root.Name: dd .root.Node - .NC\n");
            br.write("\tdb 0\n");
            br.write("%include \"" + imgIndex.getName() + "\"\n");
            br.write("align 512, db 0\n");
            br.write(".ICEnd:\n");
            br.write("%include \"" + imgBinary.getName() + "\"\n");
        } catch (IOException ex) {
            System.out.println(ex);
	}
    }
    public static void writeSystem(File folder){
        //Write the nodes for the files in this folder
        unfs.writeFolderNodes(folder);
        //Write the index entries for the files in this folder
        unfs.writeFolderIndexes(folder);
    }
    public static void writeFolderNodes(File folder){
        try{
            //First write the root folder's node collection
            File[] files = folder.listFiles(hiddenfilter);
            String fname;
            if(folder.getParent() != null){
                fname = folder.getParent() + "/" + folder.getName();
            }else{
                fname = folder.getName();
            }
            String fnamei = fname.replace('\\', '/');
            fname = fname.replace('\\', '.').replace('/','.');
            brn.write("." + fname + ".NC: dd ." + fname + ".NCEnd - .NC\n");
            for(int i = 0; i<files.length; i++){
                String name = fname + "." + files[i].getName();
                brn.write("\t." + name + ".Node:\n");
                brn.write("\t\tdd ." + name + ".Name - .IC\n");
                if(files[i].isDirectory()){
                    brn.write("\t\tdb 0\n");
                }else{
                    brn.write("\t\tdb 1\n");
                }
                brn.write("\t\tdd 0\n");
                brn.write("\t\tdd ." + name + ".NC - .NC\n");
                brn.write("\t\tdd ." + fname + ".Node - .NC\n");
            }
            brn.write("." + fname + ".NCEnd: dd 0\n");
            if(folder.isDirectory()){
                for(int i = 0; i < files.length; i++){
                    if(files[i].isDirectory()){
                        writeFolderNodes(files[i]);
                    }else{
                        String name = fname + "." + files[i].getName();
                        String namei = fnamei + "/" + files[i].getName();
                        //Write the cluster collection for the file
                        brn.write("." + name + ".NC: dd ." + fname + ".NCEnd - .NC\n");
                        brn.write("\tdw 0\n");
                        brn.write("\tdd (." + name + ".Bin - .h)/512\n");
                        brn.write("\tdw 0\n");
                        brn.write("\tdd (." + name + ".BinEnd - .h)/512\n");
                        brn.write("." + name + ".NCEnd: dd 0\n");
                        //Write the file includes
                        brb.write("." + name + ".Bin:\n");
                        brb.write("\tincbin \"" + namei + "\"\n");
                        brb.write("\talign 512, db 0\n");
                        brb.write("." + name + ".BinEnd:\n");
                    }
                }
            }
        } catch(IOException ex) {
            System.out.println(ex);
        }
    }
    public static void writeFolderIndexes(File folder){
        try{
            //First write the root folder's node collection
            File[] files = folder.listFiles(hiddenfilter);
            String fname;
            if(folder.getParent() != null){
                fname = folder.getParent() + "." + folder.getName();
            }else{
                fname = folder.getName();
            }
            fname = fname.replace('\\', '.').replace('/','.');
            for(int i = 0; i<files.length; i++){
                String name = fname + "." + files[i].getName();
                bri.write("\t." + name + ".Name: dd (." + name + ".Node - .NC)\n");
                bri.write("\tdb \"" + files[i].getName() + "\",0\n" );
            }
            if(folder.isDirectory()){
                for(int i = 0; i < files.length; i++){
                    if(files[i].isDirectory()){
                        writeFolderIndexes(files[i]);
                    }
                }
            }else{
                
            }
        } catch(IOException ex) {
            System.out.println(ex);
        }
    }
    public static void closeImage(){
        try {
            br.close();
            brb.close();
            bri.close();
            brn.close();
        } catch (IOException ex) {
            System.out.println(ex);
        }
    }
}

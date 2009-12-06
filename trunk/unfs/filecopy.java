import java.io.*;

/*
 * @author Jeremy Soller
 */
public class filecopy {
/* FSType is the filesystem type.
 * FSVersion is the filesystem version.
 * FSBlockSize is the size of block pointers in bytes.
 * FSMemorySize is the size of memory pointers in bytes.
 * FSUserSize is the size of User and Group ID's.
 * FSClusterSize is the size of the allocation block as an exponent of 2.
 * FSCharEncode is the type of character encoding.
 * #0=ASCII
 */
    static String FSType = "UnFS";
    static int FSVersion = 1;
    static int FSBlockSize = 6;
    static int FSMemorySize = 4;
    static int FSUserSize = 2;
    static int FSClusterSize = 9;
    static int FSCharEncode = 0;
    public static void main(String[] args) throws IOException {
        File imgfile = new File("img");
        //Open the image source file
        unfs.initImage(imgfile);
        //Write the header and the part of the node collection that does not change
        unfs.writeHeader(FSType, FSVersion, FSBlockSize, FSMemorySize, FSUserSize, FSClusterSize, FSCharEncode);
        File fsloc = new File ("root");
        //Write an image using this folder
        unfs.writeSystem(fsloc);
        //Close the image source file
        unfs.closeImage();
    }
}
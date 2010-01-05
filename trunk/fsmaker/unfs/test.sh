javac "unfs.java"
javac "fsmaker.java"
java fsmaker
nasm img.asm -o "../../included/_img.bin"
echo "Press enter."
read doneit
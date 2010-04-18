using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace FontMaker
{
    public partial class Form1 : Form
    {
        Graphics box;
        Graphics box2;
        Graphics box3;
        FileStream openfs;
        FileStream savefs;
        int current = 0;
        bool openedafilealready = false;
        bool[,] pixeldata = new bool[65536,129];
        byte[] readbyte = new byte[16];
        bool filetype = true;
        string openedfile = "";
        string savedfile = "";

        public Form1()
        {
            InitializeComponent();
            box = pictureBox1.CreateGraphics();
            box2 = pictureBox2.CreateGraphics();
            box3 = pictureBox3.CreateGraphics();
            pictureBox1.MouseDown += new MouseEventHandler(pictureBox1_MouseDown);
        }

        public void pictureBox1_MouseDown(object sender, MouseEventArgs mea)
        {
            pixeldata[current, 128] = true;
            int pdata = mea.X / 40 + mea.Y / 40 * 8;
            int mousex = mea.X - (mea.X % 40) + 1;
            int mousey = mea.Y - (mea.Y % 40) + 1;
            if (pixeldata[current,pdata])
            {
                pixeldata[current,pdata] = false;
            }
            else
            {
                pixeldata[current,pdata] = true;
            }
            updategraphics(pdata);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                if (openedafilealready)
                {
                    openfs.Close();
                }
                openedfile = openFileDialog1.FileName;
                openfs = new FileStream(openedfile, FileMode.Open);
                if (openedfile.EndsWith(".hex"))
                {
                    numericUpDown1.Maximum = 65535;
                    filetype = false;
                }
                else
                {
                    numericUpDown1.Maximum = openfs.Length / 16 - 1;
                    filetype = true;
                }
                openedafilealready = true;
                if (openfs.CanRead)
                {
                    if (filetype)
                    {
                        openfs.Position = 0;
                        for (int valint = 0; valint < numericUpDown1.Maximum; valint++)
                        {
                            openfs.Read(readbyte, 0, 16);
                            pixeldata[valint, 128] = true;
                            for (int i = 0; i < 16; i++)
                            {
                                bool[] pd = new bool[8];
                                for (int i2 = 0; i2 < 8; i2++)
                                {
                                    pd[i2] = Convert.ToBoolean((readbyte[i] - ((readbyte[i] >> (i2 + 1)) << (i2 + 1))) >> i2);
                                }
                                for (int i2 = 1; i2 < 8; i2++)
                                {
                                    pixeldata[valint, i * 8 + i2] = pd[8 - i2]; //the pixel data must be flipped and something adjusted
                                }
                                pixeldata[valint, i * 8] = pd[0];
                            }
                        }
                    }
                    else
                    {
                        openfs.Position = 0;
                        bool canread = true;
                        while (canread)
                        {
                            byte[] number = new byte[5];
                            byte[] readdata = new byte[65];
                            bool largechar = false;
                            while (number[4] != ':') openfs.Read(number, 0, 5);
                            openfs.Read(readdata, 0, 33);
                            string str = Encoding.GetEncoding(1251).GetString(number, 0, 4);
                            if (readdata[32] != 10)
                            {
                                largechar = true;
                                openfs.Read(readdata, 33, 32);
                            }
                            int valint = Convert.ToInt32(str, 16);
                            pixeldata[valint, 128] = false;
                            if (!largechar)
                            {
                                pixeldata[valint, 128] = true;
                                for (int i = 0; i < 16; i++)
                                {
                                    string strb = Encoding.GetEncoding(1251).GetString(readdata, i * 2, 2);
                                    int rb = Convert.ToInt32(strb, 16);
                                    for (int i2 = 0; i2 < 8; i2++)
                                    {
                                        pixeldata[valint, i * 8 + 7 - i2] = Convert.ToBoolean(rb >> i2 & 1);
                                    }
                                }
                            }
                            if (openfs.Position >= openfs.Length) canread = false;
                        }
                        pixeldata[0, 128] = true;
                    }
                }
                loadpdata(numericUpDown1.Value);
            }
        }

        private void numericUpDown1_ValueChanged(object sender, EventArgs e)
        {
            loadpdata(numericUpDown1.Value);
        }
        private void loadpdata(decimal value)
        {
            current = Convert.ToInt32(value);
            this.Text = Convert.ToChar(current).ToString() + " U+" + current.ToString("X4");
            if (pixeldata[current, 128])
            {
                for (int i = 0; i < 128; i++)
                {
                    updategraphics(i);
                }
            }
            else
            {
                for (int i = 0; i < 128; i++)
                {
                    invalidategraphics(i);
                }
            }
            
        }
        private void invalidategraphics(int pdata)
        {
            int mousex = pdata % 8 * 40 + 1;
            int mousey = pdata / 8 * 40 + 1;
            box.FillRectangle(Brushes.Gray, mousex, mousey, 38, 38);
            box2.FillRectangle(Brushes.Gray, pdata % 8 * 2, pdata / 8 * 2, 2, 2);
            box3.FillRectangle(Brushes.Gray, pdata % 8, pdata / 8, 1, 1);
        }
        private void updategraphics(int pdata)
        {
            int mousex = pdata % 8 * 40 + 1;
            int mousey = pdata / 8 * 40 + 1;
            if (pixeldata[current,pdata])
            {
                box.FillRectangle(Brushes.Black, mousex, mousey, 38, 38);
                box2.FillRectangle(Brushes.Black, pdata % 8 * 2, pdata / 8 * 2, 2, 2);
                box3.FillRectangle(Brushes.Black, pdata % 8, pdata / 8, 1, 1);
            }
            else
            {
                box.FillRectangle(Brushes.White, mousex, mousey, 38, 38);
                box2.FillRectangle(Brushes.White, pdata % 8 * 2, pdata / 8 * 2, 2, 2);
                box3.FillRectangle(Brushes.White, pdata % 8, pdata / 8, 1, 1);
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                savedfile = saveFileDialog1.FileName;
                if (savedfile == openedfile)
                {
                    for (int i = 0; i < 16; i++)
                    {
                        readbyte[i] = 0;
                        bool[] pd = new bool[8];
                        pd[0] = pixeldata[current,i * 8];
                        for (int i2 = 1; i2 < 8; i2++)
                        {
                            pd[8 - i2] = pixeldata[current,i * 8 + i2];
                        }
                        for (int i2 = 0; i2 < 8; i2++)
                        {
                            readbyte[i] = Convert.ToByte((Convert.ToByte(pd[i2]) << i2) + readbyte[i]);
                        }
                    }
                    openfs.Position = Convert.ToInt64(current * 16);
                    openfs.Write(readbyte, 0, 16);
                }
                else
                {
                    savefs = new FileStream(savedfile, FileMode.OpenOrCreate);
                    if (savefs.CanWrite)
                    {
                        savefs.Position = 0;
                        for (int valint = 0; valint < 0x500; valint++)
                        {
                            int nv = valint;
                            if (!pixeldata[nv, 128])
                            {
                                nv = 0xFFFD; //replace with ? in diamond sign's number
                            }
                            for (int i = 0; i < 16; i++)
                            {
                                readbyte[i] = 0;
                                bool[] pd = new bool[8];
                                pd[0] = pixeldata[nv, i * 8];
                                for (int i2 = 1; i2 < 8; i2++)
                                {
                                    pd[8 - i2] = pixeldata[nv, i * 8 + i2];
                                }
                                for (int i2 = 0; i2 < 8; i2++)
                                {
                                    readbyte[i] = Convert.ToByte((Convert.ToByte(pd[i2]) << i2) + readbyte[i]);
                                }
                            }
                            savefs.Position = Convert.ToInt64(valint * 16);
                            savefs.Write(readbyte, 0, 16);
                        }
                    }
                    savefs.Close();
                }
            }
        }
    }
}

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
        bool openedafilealready = false;
        bool[] pixeldata = new bool[128];
        byte[] readbyte = new byte[16];
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
            int pdata = mea.X / 40 + mea.Y / 40 * 8;
            int mousex = mea.X - (mea.X % 40) + 1;
            int mousey = mea.Y - (mea.Y % 40) + 1;
            if (pixeldata[pdata])
            {
                pixeldata[pdata] = false;
            }
            else
            {
                pixeldata[pdata] = true;
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
                openedafilealready = true;
                numericUpDown1.Maximum = openfs.Length / 16 - 1;
                loadpdata(numericUpDown1.Value);
            }
        }

        private void numericUpDown1_ValueChanged(object sender, EventArgs e)
        {
            loadpdata(numericUpDown1.Value);
        }
        private void loadpdata(decimal value)
        {
            if (openfs.CanRead)
            {
                this.Text = Convert.ToChar(Convert.ToInt64(value)).ToString();
                openfs.Position = Convert.ToInt64(value * 16);
                openfs.Read(readbyte, 0, 16);
                for (int i = 0; i < 16; i++)
                {
                    bool[] pd = new bool[8];
                    for (int i2 = 0; i2 < 8; i2++)
                    {
                        pd[i2] = Convert.ToBoolean((readbyte[i] - ((readbyte[i] >> (i2 + 1)) << (i2 + 1))) >> i2);
                    }
                    for (int i2 = 1; i2 < 8; i2++)
                    {
                        pixeldata[i * 8 + i2] = pd[8 - i2]; //the pixel data must be flipped and something adjusted
                    }
                    pixeldata[i * 8] = pd[0];
                }
                for (int pdata = 0; pdata < 128; pdata++)
                {
                    updategraphics(pdata);
                }
            }
        }
        private void updategraphics(int pdata)
        {
            int mousex = pdata % 8 * 40 + 1;
            int mousey = pdata / 8 * 40 + 1;
            if (pixeldata[pdata])
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
                        pd[0] = pixeldata[i * 8];
                        for (int i2 = 1; i2 < 8; i2++)
                        {
                            pd[8 - i2] = pixeldata[i * 8 + i2];
                        }
                        for (int i2 = 0; i2 < 8; i2++)
                        {
                            readbyte[i] = Convert.ToByte((Convert.ToByte(pd[i2]) << i2) + readbyte[i]);
                        }
                    }
                    openfs.Position = Convert.ToInt64(numericUpDown1.Value * 16);
                    openfs.Write(readbyte, 0, 16);
                }
                else
                {
                    savefs = new FileStream(savedfile, FileMode.OpenOrCreate);
                    if (savefs.CanWrite && openfs.CanRead)
                    {
                        openfs.Position = 0;
                        savefs.Position = 0;
                        for (int i = 0; i < openfs.Length; i++)
                        {
                            savefs.WriteByte(Convert.ToByte(openfs.ReadByte()));
                        }
                        for (int i = 0; i < 16; i++)
                        {
                            readbyte[i] = 0;
                            bool[] pd = new bool[8];
                            pd[0] = pixeldata[i * 8];
                            for (int i2 = 1; i2 < 8; i2++)
                            {
                                pd[8 - i2] = pixeldata[i * 8 + i2];
                            }
                            for (int i2 = 0; i2 < 8; i2++)
                            {
                                readbyte[i] = Convert.ToByte((Convert.ToByte(pd[i2]) << i2) + readbyte[i]);
                            }
                        }
                        savefs.Position = Convert.ToInt64(numericUpDown1.Value * 16);
                        savefs.Write(readbyte, 0, 16);
                    }
                    savefs.Close();
                }
            }
        }
    }
}

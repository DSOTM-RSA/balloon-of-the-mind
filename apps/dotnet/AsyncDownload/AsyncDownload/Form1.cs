using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Net; // use to access web clients
using System.Diagnostics; // needed to make use of process 

namespace AsyncDownload
{
    public partial class Form1 : Form
    {
        WebClient client = new WebClient(); //make new web client

        public Form1() // contructor which runs when Form is started
        {
            InitializeComponent();
        }

        private void btnFreeze_Click(object sender, EventArgs e)
        {
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                // freezes the interface
                client.DownloadFile("https://pixabay.com/videos/ocean-rocks-sun-waves-oregon-28268_tiny.mp4?attachment", saveFileDialog1.FileName);
        }

        private void btnOpenFile_Click(object sender, EventArgs e)
        {
            // open windows explorer and file downloaded
            Process.Start("explroer.exe", "/select," + saveFileDialog1.FileName);
        }

        private void btnAsync_Click(object sender, EventArgs e)
        {
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                // does not block the thread, leaving the program usuable
                client.DownloadFileAsync(new Uri("https://pixabay.com/videos/ocean-rocks-sun-waves-oregon-28268_tiny.mp4?attachment"), saveFileDialog1.FileName);
        }
    }
}

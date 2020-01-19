using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ContactManagement
{
    public partial class Main : Form
    {
        public Main()
        {
            InitializeComponent();
        }

        private void businesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            BusinessContacts frm = new BusinessContacts(); // make a new form
            frm.MdiParent = this; // set the parent to this form
            frm.Show(); // show form
        }

        private void cascadeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            LayoutMdi(MdiLayout.Cascade); // set layout to cascade
        }

        private void tileVerticallyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            LayoutMdi(MdiLayout.TileVertical); // set vertically
        }

        private void tileHorizontallyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            LayoutMdi(MdiLayout.TileHorizontal); // set horizontally
        }
    }
}

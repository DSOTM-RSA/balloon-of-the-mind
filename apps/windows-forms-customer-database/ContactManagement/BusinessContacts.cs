using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO; // needed for file-system use
using System.Diagnostics;
using Microsoft.Office.Interop.Excel;

namespace ContactManagement
{
    public partial class BusinessContacts : Form
    {
        string connString = @"Data Source=(localdb)\ProjectsV13;Initial Catalog=AddressBook;Integrated Security=True;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False";

        // this allows us to build the connection between the program and the database
        SqlDataAdapter dataAdapter; // declares a new data adapter 
        System.Data.DataTable table; // declares a new data table object

        SqlConnection conn; // declares a new SqlConnection
        string selectionStatment = "Select * from BusinessContacts"; // declares select statement used multiple times
        

        public BusinessContacts()
        {
            InitializeComponent();
        }

        private void BusinessContacts_Load(object sender, EventArgs e)
        {
            
            comboBox1.SelectedIndex = 0; // set index to 0
            dataGridView1.DataSource = bindingSource1; // sets the source of the data to be displayed in the grid
           

            // select all data from business contacts table
            // calls the GetData method 
            // which connects to the databsase using the SqlDataAdaptor
            // creates a new table object
            // deals with locale settings
            // fills the table 
            // and sets the DataSource of the bindingSource to that of the table
            GetData(selectionStatment); 
            
        }

        private void GetData(string selectCommand)
        {
            try
            {
                dataAdapter = new SqlDataAdapter(selectCommand, connString); // pass in select command and connection string
                table = new System.Data.DataTable(); // make a new data table object
                table.Locale = System.Globalization.CultureInfo.InvariantCulture; // fit to deal with locales
                dataAdapter.Fill(table); // fill the data table
                bindingSource1.DataSource = table; // set the data source on the binding source to be the table
                dataGridView1.Columns[0].ReadOnly = true; // set the PK as read-only
            }

            catch (SqlException ex)
            {
                MessageBox.Show(ex.Message); // show a useful error mesage
            }
        }

        // checks if 0 rows of data are returned
        private void recordsExist(int rowcount)
        {
            if (rowcount == 0)
            {
                MessageBox.Show("No Matching Records Found!");
                
            }
        }

        // clears picture dialog after an insert
        private void cleanPicture()
        {
            dlgBoxImage.FileName = "";
            pictureBox1.Image = null;
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            SqlCommand command; // declares a new sql command object

            // field names into the DB via parameters
            string insert = @"Insert into BusinessContacts(Date_Added,Company,Website,Title,First_Name,
                                    Last_Name,Address,City,State,Postal_Code,Email,Mobile,Notes,Image)

                               values(@Date_Added,@Company,@Website,@Title,@First_Name,
                                    @Last_Name,@Address,@City,@State,@Postal_Code,@Email,@Mobile,@Notes,@Image)";

            using (conn = new SqlConnection(connString)) // using allows disposing of low-level resources
            {
                // attempt to add text in text labels to parameters
                // otherwise print message
                // using handles graceful execution :: termination of resources

                try
                {

                    conn.Open();
                    command = new SqlCommand(insert, conn);
                    command.Parameters.AddWithValue(@"Date_Added", dateTimePicker1.Value.Date);
                    command.Parameters.AddWithValue(@"Company", txtCompany.Text);
                    command.Parameters.AddWithValue(@"Website", txtWebsite.Text);
                    command.Parameters.AddWithValue(@"Title", txtTitle.Text);
                    command.Parameters.AddWithValue(@"First_Name", txtFname.Text);
                    command.Parameters.AddWithValue(@"Last_Name", txtLname.Text);
                    command.Parameters.AddWithValue(@"Address", txtAddress.Text);
                    command.Parameters.AddWithValue(@"City", txtCity.Text);
                    command.Parameters.AddWithValue(@"State", txtState.Text);
                    command.Parameters.AddWithValue(@"Postal_Code", txtPostalCode.Text);
                    command.Parameters.AddWithValue(@"Email", label.Text);
                    command.Parameters.AddWithValue(@"Mobile", txtMobile.Text);
                    command.Parameters.AddWithValue(@"Notes", txtNotes.Text);// read value from form and add
                    if (dlgBoxImage.FileName != "") // deal with process when no image is added
                        command.Parameters.AddWithValue(@"Image", File.ReadAllBytes(dlgBoxImage.FileName));
                    else
                        command.Parameters.Add("@Image", SqlDbType.VarBinary).Value = DBNull.Value;
                    command.ExecuteNonQuery(); // push content into DB table
                }

                catch(Exception ex)
                {
                    MessageBox.Show(ex.Message); // show the user a mesasge
                }

                GetData(selectionStatment); // get the updated data
                dataGridView1.Update(); // redraws data grid view
                cleanPicture(); // clear picture interface
            }
        }

        private void dataGridView1_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter); // declares a new sql command builder object :: for editing DB records
            dataAdapter.UpdateCommand = commandBuilder.GetUpdateCommand(); // get the update command
            try
            {
                bindingSource1.EndEdit(); // updates the table that is in-memory in our program
                dataAdapter.Update(table); // updates the DB

                //MessageBox.Show("DB successfully updated!"); // 

            }
            
            catch(Exception ex)
            {
                MessageBox.Show(ex.Message); // print exception message
                
            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            DataGridViewRow row = dataGridView1.CurrentRow; // grab reference to current row
            string idname = row.Cells["ID"].Value.ToString(); // grab the value of the cell in this row
            string fname = row.Cells["First_Name"].Value.ToString();
            string lname = row.Cells["First_Name"].Value.ToString();

            DialogResult result = MessageBox.Show("Do you really want to delete " + fname + " " + lname + ", record" + idname,"Message",MessageBoxButtons.YesNo,MessageBoxIcon.Question);

            string deleteStatement = @"Delete from BusinessContacts where id = '"+idname+"'";

            if(result==DialogResult.Yes)
            {
                using(conn = new SqlConnection(connString))
                {
                    try
                    {
                        conn.Open();
                        SqlCommand comm = new SqlCommand(deleteStatement, conn); // is the command with a connections string
                        comm.ExecuteNonQuery(); // this causes the delete to happen
                        
                        GetData(selectionStatment); // get data again
                        dataGridView1.Update(); // redraws the data grid view
                    }

                    catch(Exception ex)
                    {
                        MessageBox.Show(ex.Message);
                    }
                }
                   
            }

        }

        // implements search functionality for records in the DB
        // the combo box is used to select a filter
        // compared using `like` to records in DB
        // if no records are found print a message to user
        private void btnSearch_Click(object sender, EventArgs e)
        {
            switch (comboBox1.SelectedItem.ToString())
            
            { 
                case "First Name":
                    GetData("select * from BusinessContacts where lower(first_name) like '%" + txtSearch.Text.ToLower()+ "%'");
                    recordsExist(table.Rows.Count); // print message if results returned have 0 rows
                    break;

                case "Last Name":
                    GetData("select * from BusinessContacts where lower(last_name) like '%" + txtSearch.Text.ToLower() + "%'");
                    recordsExist(table.Rows.Count);
                    break; 

                case "Company":
                    GetData("select * from BusinessContacts where lower(company) like '%" + txtSearch.Text.ToLower() + "%'");
                    recordsExist(table.Rows.Count);
                    break;
                     

            }
        }

        private void btnAddPicture_Click(object sender, EventArgs e)
        {
            if (dlgBoxImage.ShowDialog() == DialogResult.OK)
                pictureBox1.Load(dlgBoxImage.FileName);
           // else
           //     dlgBoxImage.FileName = "";

           // pictureBox1.
        }

        private void pictureBox1_DoubleClick(object sender, EventArgs e)
        {
            Form form = new Form(); // makes a new form
            form.BackgroundImage = pictureBox1.Image;
            form.Size = pictureBox1.Image.Size; // sets size to size of original picture
            form.Show();
        }

        private void btnExportOpen_Click(object sender, EventArgs e)
        {
            _Application excel = new Microsoft.Office.Interop.Excel.Application();
            _Workbook workbook = excel.Workbooks.Add(Type.Missing);
            _Worksheet worksheet = null;
            try
            {
                worksheet = workbook.ActiveSheet;
                worksheet.Name = "Business Contacts";

                // becasue both worksheets and grid are tabualr uses nested loops
                for (int rowIndex = 0; rowIndex< dataGridView1.Rows.Count - 1; rowIndex++)  // goes over rows
                {
                    for (int colIndex = 0; colIndex < dataGridView1.Columns.Count; colIndex++) // goes over columns
                    {
                        if(rowIndex==0)
                        {
                            // in excel row and column indexes begin at 1,1 not 0,0
                            worksheet.Cells[rowIndex + 1, colIndex + 1] = dataGridView1.Columns[colIndex].HeaderText;
                        }
                        else
                        {
                            // fix the row index and fills all columns
                            worksheet.Cells[rowIndex + 1, colIndex + 1] = dataGridView1.Rows[rowIndex].Cells[colIndex].Value.ToString();
                        }
                    }
                }

                if(saveFileDialog1.ShowDialog()==DialogResult.OK)
                {
                    workbook.SaveAs(saveFileDialog1.FileName);
                    Process.Start("excel.exe", saveFileDialog1.FileName);
                }

            }

            catch(Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                excel.Quit();
                workbook = null;
                excel = null;
            }

        }

        private void btnSaveText_Click(object sender, EventArgs e)
        {
            if (saveFileDialog2.ShowDialog() == DialogResult.OK)
            {
                using (StreamWriter sw = new StreamWriter(saveFileDialog2.FileName))
                {
                    // for each row grabbed
                    foreach (DataGridViewRow row in dataGridView1.Rows)
                    {
                        // go through the cells of that rows
                        foreach (DataGridViewCell cell in row.Cells) 
                            //write value 
                            sw.Write(cell.Value);
                        // push to next line
                        sw.WriteLine();
                    }
                }
            // 
            Process.Start("notepad.exe", saveFileDialog2.FileName);
            }
        }
    }
}

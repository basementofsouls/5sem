using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Net.Http;
using System.Net.Http.Json;

namespace windows_client
{
    public partial class Form1 : Form
    {
        private const string ApiUrl = "http://localhost:5072/api/calculator";
        public Form1()
        {
            InitializeComponent();
        }

        private async void button1_Click(object sender, EventArgs e)
        {
            if (int.TryParse(textBoxX.Text, out int x) && int.TryParse(textBoxY.Text, out int y))
            {
                using (HttpClient client = new HttpClient())
                {
                    var numbers = new { X = x, Y = y };
                    var response = await client.PostAsJsonAsync(ApiUrl, numbers);

                    if (response.IsSuccessStatusCode)
                    {
                        var sum = await response.Content.ReadAsStringAsync();
                        MessageBox.Show($"Сумма: {sum}", "Результат");
                    }
                    else
                    {
                        MessageBox.Show("Ошибка при отправке запроса", "Ошибка");
                    }
                }
            }
            else
            {
                MessageBox.Show("Пожалуйста, введите числа X и Y", "Ошибка");
            }

        }
    }
}

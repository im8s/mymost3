
namespace WinFrmTalk
{
    public class sqlite_master
    {
        private string _type;
        private string _name;
        private string tbl_name;
        private int _rootpage;
        private string _sql;

        public string Type { get => _type; set => _type = value; }
        public string Name { get => _name; set => _name = value; }
        public string Tbl_name { get => tbl_name; set => tbl_name = value; }
        public int Rootpage { get => _rootpage; set => _rootpage = value; }
        public string Sql { get => _sql; set => _sql = value; }
    }
}

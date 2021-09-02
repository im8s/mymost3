using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    //百度地图定位接口返回的json数据
    public class LocationModel
    {
        [Serializable]
        //存储百度定位API返回结果类
        public class AddressForQueryIPFromBaidu
        {
            public string Address { get; set; }
            public Content Content { get; set; }
            public string Status { get; set; }
        }
        [Serializable]
        public class Content
        {
            public string Address { get; set; }
            public Address_Detail Address_Detail { get; set; }
            public Point Point { get; set; }
        }
        [Serializable]
        public class Address_Detail
        {
            public string City { get; set; }
            public string City_Code { get; set; }
            public string District { get; set; }
            public string Province { get; set; }
            public string Street { get; set; }
            public string Street_Number { get; set; }
        }
        [Serializable]
        public class Point
        {
            public string X { get; set; }
            public string Y { get; set; }
        }
    }
}

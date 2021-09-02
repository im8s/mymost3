
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;
using WinFrmTalk.View;
using System.Threading;
using WinFrmTalk.Controls;
using System.Threading.Tasks;

namespace WinFrmTalk.Helper
{
    public class RedpaperUIUtils
    {
        public static string messageid;
        public static MessageObject msg;
        public static EQredPaper eQred;
        public static List<MessageObject> RedPacketLst = new List<MessageObject>();
        #region 红包相关接口
        /// <summary>
        /// 查看红包详情
        /// </summary>
        /// <param name="id"></param>
        internal static void GetRedPacket(string id, MessageObject message, EQredPaper eQredPaper)
        {
            messageid = id;
            msg = message;

            eQred = eQredPaper;
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "redPacket/getRedPacket")
            .AddParams("access_token", Applicate.Access_Token)
            .AddParams("id", id)
            .Build().Execute((sccess, data) =>
            {
                if (sccess)
                {
                    string code = UIUtils.DecodeString(data, "resultCode");

                    if (UIUtils.IsNull(code))
                    {
                        Redpackges reapackges = JsonConvert.DeserializeObject<Redpackges>(data["packet"].ToString());

                        // string text = UIUtils.DecodeString(packet, "greetings");
                        //string resultdata = UIUtils.DecodeString(data, "data");
                        //var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(resultdata);

                        //string packet = UIUtils.DecodeString(list, "packet");
                        if (reapackges.type == "3")
                        {
                            string tips = reapackges.greetings;
                            List<List<string>> Commandlst = new List<List<string>>();
                            bool isadd = false;
                            for (int i = 0; i < RedPacketLst.Count; i++)
                            {
                                if (RedPacketLst[i].messageId == message.messageId)
                                {
                                    isadd = true;
                                    break;
                                }
                            }
                            if (!isadd)
                            {
                                RedPacketLst.Add(message);
                            }

                            List<string> list = new List<string>();

                            // Dictionary<string ,List<string>> CommandRed = new Dictionary<string, List<string>>()
                            list.Add(tips);
                            list.Add(id);
                            list.Add("1");
                            Commandlst.Add(list);

                            Messenger.Default.Send(Commandlst, MessageActions.RED_UPDATE_COMMAND);// 更新UI消息

                        }
                        else
                        {
                            bool isOneself = msg.fromUserId != Applicate.MyAccount.userId ? false : true;
                            if (!isOneself || msg.isGroup == 1)
                            {
                                OpenRedPacket(id);
                            }
                            else
                            {


                                MeSeeRReadPaper(data);
                            }
                        }

                    }
                    else
                    {
                        if (code == "100101")
                        {
                            SeeRReadPaper(data, ",已过期");
                        }
                        else
                        {// 已领完
                            SeeRReadPaper(data);

                        }

                    }

                }
                else
                {

                }
            });
        }
        public static void MeSeeRReadPaper(Dictionary<string, object> data)
        {
            string resultdata = UIUtils.DecodeString(data, "packet");
            //var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(resultdata);
            //string resultdata = UIUtils.DecodeString(data, "packet");
            string list = UIUtils.DecodeString(data, "list");
            Redpackges reapackges = JsonConvert.DeserializeObject<Redpackges>(resultdata);
            //string resultlist = UIUtils.DecodeString(list, "list");
            List<Receivers> reds = JsonConvert.DeserializeObject<List<Receivers>>(list);
            Acceoptlst = reds;

            Frmreceivemony frmreceivemony = new Frmreceivemony();
            frmreceivemony.BringToFront();
            frmreceivemony.receivelst = reds;
            frmreceivemony.reapackgeinfo = reapackges;
            frmreceivemony.Show();
            frmreceivemony.BindTodata();


            ImageLoader.Instance.DisplayAvatar(reapackges.userId, frmreceivemony.pic_head);
        }
        public static void SeeRReadPaper(Dictionary<string, object> data, string datetime = "")
        {
            string resultdata = UIUtils.DecodeString(data, "data");
            var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(resultdata);

            string packet = UIUtils.DecodeString(list, "packet");
            Redpackges reapackges = JsonConvert.DeserializeObject<Redpackges>(packet);
            string resultlist = UIUtils.DecodeString(list, "list");
            List<Receivers> reds = JsonConvert.DeserializeObject<List<Receivers>>(resultlist);

            Frmreceivemony frmreceivemony = new Frmreceivemony();
            frmreceivemony.datatime = datetime;
            frmreceivemony.receivelst = reds;
            frmreceivemony.reapackgeinfo = reapackges;
            frmreceivemony.Show();
            frmreceivemony.BindTodata();

            ImageLoader.Instance.DisplayAvatar(reapackges.userId, frmreceivemony.pic_head);
        }

        static List<Receivers> Acceoptlst = new List<Receivers>();
        /// <summary>
        /// 打开红包
        /// </summary>
        /// <param name="id"></param>
        internal static void OpenRedPacket(string id)
        {
            //红包未领取的时候，消息列表输入了口令，就要打开


            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "redPacket/openRedPacket")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("id", id)
                .Build().Execute((sccess, data) =>
                {
                    if (sccess)
                    {

                        string resultdata = UIUtils.DecodeString(data, "packet");
                        //var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(resultdata);
                        //string resultdata = UIUtils.DecodeString(data, "packet");
                        string list = UIUtils.DecodeString(data, "list");
                        Redpackges reapackges = JsonConvert.DeserializeObject<Redpackges>(resultdata);
                        //string resultlist = UIUtils.DecodeString(list, "list");
                        List<Receivers> reds = JsonConvert.DeserializeObject<List<Receivers>>(list);

                        Acceoptlst = reds;
                        string money = "0";

                        if (reapackges.type == "3")
                        {
                            //Task task = new Task(() =>
                            //{
                            //    eQred.DisposeRedPoint(msg);
                            //}
                            //);
                            //task.Start();
                            //if (eQred.IsHandleCreated)
                            //{
                            //    eQred. Invoke(new Action(() =>
                            //    {
                            //        eQred.DisposeRedPoint(msg);
                            //    }));

                            //}



                            eQred.Invoke(new Action(() =>
                            {
                                for (int i = 0; i < RedPacketLst.Count; i++)
                                {
                                    if (RedPacketLst[i].content == reapackges.greetings)
                                    {
                                        eQred.DisposeRedPoint(RedPacketLst[i], 0);
                                        RedPacketLst.Remove(RedPacketLst[i]);
                                    }
                                }


                            }));

                        }
                        FrmopenRedpaper frmopenRedpaper = new FrmopenRedpaper();
                        frmopenRedpaper.Radius = 30;
                        for (int i = 0; i < reds.Count; i++)
                        {
                            if (reds[i].userId == Applicate.MyAccount.userId)
                            {
                                money = reds[i].money;
                            }
                        }
                        frmopenRedpaper.getdata(reapackges.userName, reapackges.greetings, money, reapackges.userId, messageid);
                        frmopenRedpaper.reapackgeinfo = reapackges;
                        frmopenRedpaper.acceoptlst = Acceoptlst;
                        frmopenRedpaper.Show();

                        Friend friend = new Friend { UserId = reapackges.userId, NickName = reapackges.userName };

                        ShiKuManager.ReceivedRedPack(friend, Applicate.MyAccount.nickname);

                        //如果是口令红包，那条消息的红点消失
                    }
                });
        }
        #endregion
        #region 转账相关
        /// <summary>
        /// 获取转账信息
        /// </summary>
        /// <param name="id"></param>
        internal static void GetTranfserinfo(string id, MessageObject message)
        {
            msg = message;
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "skTransfer/getTransferInfo")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("id", id)
                .Build().Execute((sccess, data) =>
                {
                    if (sccess)
                    {
                        string code = UIUtils.DecodeString(data, "resultCode");

                        if (UIUtils.IsNull(code) && (code != "10032"))
                        {
                            TransferInfo transferInfo = new TransferInfo();
                            transferInfo.createTime = UIUtils.DecodeInt(data, "createTime");
                            transferInfo.id = UIUtils.DecodeString(data, "id");
                            transferInfo.money = UIUtils.DecodeDouble(data, "money");
                            transferInfo.outTime = UIUtils.DecodeInt(data, "outTime ");
                            transferInfo.receiptTime = UIUtils.DecodeInt(data, "receiptTime");
                            transferInfo.remark = UIUtils.DecodeString(data, "remark");
                            transferInfo.status = UIUtils.DecodeInt(data, "status");
                            transferInfo.toUserId = UIUtils.DecodeInt(data, "toUserId");
                            transferInfo.userId = UIUtils.DecodeInt(data, "userId");
                            transferInfo.userName = UIUtils.DecodeString(data, "userName");

                            FrmTransferReceive frmTransferReceive = new FrmTransferReceive();
                            frmTransferReceive.TransferInfo = transferInfo;
                            frmTransferReceive.BringToFront();
                            frmTransferReceive.waiteReceived();
                        }
                        else
                        {
                            string resultdata = UIUtils.DecodeString(data, "data");
                            var keys = JsonConvert.DeserializeObject<Dictionary<string, object>>(resultdata);
                            SetReceivedata(keys);
                        }
                    }
                });
        }
        /// <summary>
        /// 接受转账
        /// </summary>
        /// <param name="id"></param>
        internal static void ReceiveTranfser(string id)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "skTransfer/receiveTransfer")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("id", id)
                .Build().Execute((sccess, data) =>
                {
                    if (sccess)
                    {
                        string code = UIUtils.DecodeString(data, "resultCode");

                        if (UIUtils.IsNull(code))
                        {
                            SetReceivedata(data);
                        }



                    }
                });
        }
        public static void SetReceivedata(Dictionary<string, object> data)
        {
            HaveReceived haveReceived = new HaveReceived();
            haveReceived.Time = UIUtils.DecodeInt(data, "time");
            haveReceived.id = UIUtils.DecodeString(data, "id");
            haveReceived.money = UIUtils.DecodeDouble(data, "money");
            haveReceived.createTime = UIUtils.DecodeInt(data, "createTime");
            haveReceived.receiptTime = UIUtils.DecodeInt(data, "receiptTime");
            haveReceived.sendId = UIUtils.DecodeInt(data, "sendId");
            haveReceived.sendName = UIUtils.DecodeString(data, "sendName");
            haveReceived.transferid = UIUtils.DecodeString(data, "transferid");
            haveReceived.userId = UIUtils.DecodeInt(data, "userId");
            haveReceived.userName = UIUtils.DecodeString(data, "userName");
            FrmTransferReceive frmTransferReceive = new FrmTransferReceive();
            frmTransferReceive.HaveReceived = haveReceived;
            frmTransferReceive.BringToFront();
            frmTransferReceive.SureReceived();
        }
        #endregion
    }

}

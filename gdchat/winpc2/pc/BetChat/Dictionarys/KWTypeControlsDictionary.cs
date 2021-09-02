using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using WinFrmTalk.Controls;
using WinFrmTalk.Model;

namespace WinFrmTalk.Dictionarys
{
    public class KWTypeControlsDictionary
    {
        static Dictionary<kWCMessageType, EQBaseControl> typeControls;
        private static readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问
        
        private KWTypeControlsDictionary(MessageObject messageModel)
        {

        }


        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        //public static Dictionary<kWCMessageType, EQBaseControl> GetControlsDictionary(MessageObject messageModel)
        //{
        //    // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
        //    // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
        //    // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
        //    // 双重锁定只需要一句判断就可以了
        //    if (typeControls == null)
        //    {
        //        lock (looker)
        //        {
        //            // 如果类的实例不存在则创建，否则直接返回
        //            if (typeControls == null)
        //            {
        //                typeControls = new Dictionary<kWCMessageType, EQBaseControl>();
        //            }
        //        }
        //    }
        //    return typeControls;
        //}

        public static EQBaseControl GetObjectByType(MessageObject messageModel)
        {
            //if (typeControls.Count < 1)
            //    AddDictionary(messageModel);

            //if (typeControls.ContainsKey(messageModel.type))
            //{
            //    return typeControls[messageModel.type];
            //}
            //else
            //{
            //    return new EQRemindControl(messageModel);
            //}
            return GetBaseControl(messageModel);
        }

        public static void GetObjectByType(MessageObject messageModel, EQBaseControl eqBase, Action<EQBaseControl> action)
        {
            //Task.Factory.StartNew(() =>
            Thread thread = new Thread(() =>
            {
                eqBase = GetBaseControl(messageModel);
                action?.Invoke(eqBase);
            });
            thread.SetApartmentState(ApartmentState.STA);
            thread.Start();
        }

        private static EQBaseControl GetBaseControl(MessageObject messageModel)
        {
            switch (messageModel.type)
            {
                case kWCMessageType.CUSTOM_EMOT:
                case kWCMessageType.EMOT_PACKAGE:
                case kWCMessageType.Image:
                    return new EQImageControl(messageModel);
                case kWCMessageType.Text:
                    return new EQRichTextBoxControl(messageModel);
                case kWCMessageType.Voice:
                    return new EQVoiceControl(messageModel);
                case kWCMessageType.Location:
                    return new EQLocationControl(messageModel);
                case kWCMessageType.Link:
                    return new EQLinkControl(messageModel);
                case kWCMessageType.Gif:
                    return new EQGifControl(messageModel);
                case kWCMessageType.Video:
                    return new EQVideoControl(messageModel);
                case kWCMessageType.Card:
                    return new EQCardControl(messageModel);
                case kWCMessageType.File:
                    return new EQFileControl(messageModel);
                case kWCMessageType.History:
                    return new EQCombRelayControl(messageModel);
                case kWCMessageType.Replay:
                    return new EQReplyControl(messageModel);
                case kWCMessageType.labMoreMsg:
                    return new EQLblMoreMsg(messageModel);
                case kWCMessageType.Remind:
                    return new EQRemindControl(messageModel);
                case kWCMessageType.ImageTextSingle:
                    return new EQImageTextSingle(messageModel);
                case kWCMessageType.ImageTextMany:
                    return new EQImageTextMany(messageModel);
                case kWCMessageType.RedPacket:
                    return new EQredPaper(messageModel);
                case kWCMessageType.TRANSFER:
                    return new EQaccounts(messageModel);
                case kWCMessageType.TYPE_SECURE_LOST_KEY:
                    return new EQSendChatKey(messageModel);
                default:
                   LogUtils.Log("-------未处理的消息类型：" + messageModel.type + "-------");
                    return new EQRemindControl(messageModel);
            }
        }

        private void AddDictionary(MessageObject messageModel)
        {
            typeControls = new Dictionary<kWCMessageType, EQBaseControl>();
            if (messageModel.type == kWCMessageType.Image)
                typeControls.Add(kWCMessageType.Image, new EQImageControl(messageModel));
            else if (messageModel.type == kWCMessageType.Text)
                typeControls.Add(kWCMessageType.Text, new EQRichTextBoxControl(messageModel));
            else if (messageModel.type == kWCMessageType.Voice)
                typeControls.Add(kWCMessageType.Voice, new EQVoiceControl(messageModel));
            else if (messageModel.type == kWCMessageType.Location)
                typeControls.Add(kWCMessageType.Location, new EQLocationControl(messageModel));
            else if (messageModel.type == kWCMessageType.Link)
                typeControls.Add(kWCMessageType.Link, new EQLinkControl(messageModel));
            else if (messageModel.type == kWCMessageType.Gif)
                typeControls.Add(kWCMessageType.Gif, new EQGifControl(messageModel));
            else if (messageModel.type == kWCMessageType.Video)
                typeControls.Add(kWCMessageType.Video, new EQVideoControl(messageModel));
            else if (messageModel.type == kWCMessageType.Card)
                typeControls.Add(kWCMessageType.Card, new EQCardControl(messageModel));
            else if (messageModel.type == kWCMessageType.File)
                typeControls.Add(kWCMessageType.File, new EQFileControl(messageModel));
            else if (messageModel.type == kWCMessageType.History)
                typeControls.Add(kWCMessageType.History, new EQCombRelayControl(messageModel));
            else if (messageModel.type == kWCMessageType.Replay)
                typeControls.Add(kWCMessageType.Replay, new EQReplyControl(messageModel));
            else if (messageModel.type == kWCMessageType.labMoreMsg)
                typeControls.Add(kWCMessageType.labMoreMsg, new EQLblMoreMsg(messageModel));
            else if (messageModel.type == kWCMessageType.ImageTextSingle)
                typeControls.Add(kWCMessageType.ImageTextSingle, new EQImageTextSingle(messageModel));
            else if (messageModel.type == kWCMessageType.ImageTextMany)
                typeControls.Add(kWCMessageType.ImageTextMany, new EQImageTextMany(messageModel));
            else if (messageModel.type == kWCMessageType.CUSTOM_EMOT)
                typeControls.Add(kWCMessageType.CUSTOM_EMOT, new EQImageControl(messageModel));
            else if (messageModel.type == kWCMessageType.EMOT_PACKAGE)
                typeControls.Add(kWCMessageType.EMOT_PACKAGE, new EQImageControl(messageModel));
        }
    }
}

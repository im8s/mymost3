using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;


    
    internal class OperateObject
    {
        private OperateType _operateType;
        private Color _color;
        private object _data;
        private int _width;

    public OperateObject() { }

        public OperateObject(
            OperateType operateType, Color color, object data)
        {
            _operateType = operateType;
            _color = color;
            _data = data;
        }

        public OperateObject(
            OperateType operateType, Color color, object data, int width)
        {
            _operateType = operateType;
            _color = color;
            _data = data;
            _width = width;
        }

        public OperateType OperateType
        {
            get { return _operateType; }
            set { _operateType = value; }
        }

        public Color Color
        {
            get { return _color; }
            set { _color = value; }
        }

        public object Data
        {
            get { return _data; }
            set { _data = value; }
        }

        /// <summary>
        /// pan的宽度 
        /// </summary>
        public int Width
        {
            get { return _width; }
            set { _width = value; }
        }

        public static OperateType DrawStyleToOperateType(DrawStyle drawStyle)
        {
            switch (drawStyle)
            {
                case DrawStyle.Arrow:
                    return OperateType.DrawArrow;
                case DrawStyle.Ellipse:
                    return OperateType.DrawEllipse;
                case DrawStyle.Line:
                    return OperateType.DrawLine;
                case DrawStyle.None:
                    return OperateType.None;
                case DrawStyle.Rectangle:
                    return OperateType.DrawRectangle;
                case DrawStyle.Text:
                    return OperateType.DrawText;
                case DrawStyle.Mosaic:
                    return OperateType.DrawMosaic;
                default:
                    return OperateType.None;
            }
        }
    }


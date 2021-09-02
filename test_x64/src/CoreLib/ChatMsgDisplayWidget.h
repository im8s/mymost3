#pragma once

#include "corelib_global.h"

#include <QWidget>
#include <QDateTime>

#include <string>
using namespace std;


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

#define ITEM_HEIGHT			40
#define ITEM_SPACE          20
#define ITEM_TITLE_HEIGHT   20

#define SIZE_HINT			QSize(300,300)

#define DATE_TIME			QDateTime::currentDateTime().toString("yyyy/MM/dd hh:mm:ss")

enum EnumOrientation
{
	None,
	Left,
	Right
};

enum EnumMessageType
{
	Text,           // 普通文字消息
	Audio,          // 语音消息
	Picture,        // 图片消息
	Files,          // 文件传输
	DateTime,       // 日期时间
};

//enum  E_MSG_TYPE
//{
//	Unknow,
//	Register = 0x10,     // 用户注册
//	Login,                          // 用户登录
//	Logout,                         // 用户注销
//	LoginRepeat,                    // 重复登录
//
//	UserOnLine = 0x15,     // 用户上线通知
//	UserOffLine,                    // 用户下线通知
//	UpdateHeadPic,                  // 用户更新头像
//
//	AddFriend = 0x20,     // 添加好友
//	AddGroup,                       // 添加群组
//
//	AddFriendRequist,               // 添加好友确认通知
//	AddGroupRequist,                // 添加群组确认通知
//
//	CreateGroup = 0x25,     // 创建群组
//
//	GetMyFriends = 0x30,     // 上线获取我的好友的状态
//	GetMyGroups,                    // 获取我的群组信息
//
//	RefreshFriends = 0x35,     // 刷新好友状态
//	RefreshGroups,                  // 刷新群组成员状态
//
//	SendMsg = 0x40,     // 发送消息
//	SendGroupMsg,                   // 发送群组消息
//	SendFile,                       // 发送文件
//	SendPicture,                    // 发送图片
//	SendFace,                       // 发送表情
//
//	ChangePasswd = 0x50,     // 修改密码
//
//	DeleteFriend = 0x55,     // 删除好友
//	DeleteGroup,                    // 退出群组
//
//	SendFileOk = 0x60,     // 文件发送完成状态
//
//	GetFile = 0x65,     // 获取文件（到服务器下载文件）
//	GetPicture,                     // 图片下载
//};

//enum E_STATUS
//{
//	ConnectedHost = 0x01,
//	DisConnectedHost,
//
//	LoginSuccess,       // 登录成功
//	LoginPasswdError,   // 密码错误
//
//	OnLine,
//	OffLine,
//
//	RegisterOk,
//	RegisterFailed,
//
//	AddFriendOk,
//	AddFriendFailed,
//};

class CORELIB_EXPORT InfoItem
{
public:
	InfoItem();
	InfoItem(const QString& strName, const QString& datetime, const QString &pixmap, const QString &text, 
				const QString& strSize, const quint8 &orientation = Right, const quint8 &msgType = Text);

	~InfoItem();

	void SetName(const QString &text);
	QString GetName() const;

	void SetDatetime(const QString &text);
	QString GetDatetime() const;

	void SetHeadPixmap(const QString &pixmap);
	QString GetStrPixmap() const;

	void SetText(const QString& text);
	QString GetText() const;

	void SetFileSizeString(const QString& strSize);
	QString GetFileSizeString() const;

	void SetOrientation(quint8 orientation);
	quint8 GetOrientation() const;

	void SetMsgType(const quint8 &msgType);
	quint8 GetMsgType() const;

	void SetItemHeight(qreal itemHeight);
	qreal GetItemHeight() const;

	void SetBobbleRect(const QRectF &bobbleRect);
	QRectF GetBobbleRect() const;

private:
	QString     m_strName;
	QString     m_strDatetime;
	QString     m_strPixmap;
	QString     m_strText;
	QString     m_strSize;

	quint8      m_orientation;
	quint8      m_msgType;
	qreal       m_itemHeight;
	QRectF      m_bobbleRect;
	
	quint8      m_nStatus;
};

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

class QMenu;
class QHBoxLayout;
class QScrollBar;
class CORELIB_EXPORT ChatMsgWidget : public QWidget
{
	Q_OBJECT

public:
	ChatMsgWidget(QWidget *parent = Q_NULLPTR);
	~ChatMsgWidget();

	void addItem(InfoItem *item);
	void addItems(QVector<InfoItem*> items);

	void clear();

	void render();

	int itemCount() const
	{
		return m_ifiColl.count();
	}

	void clearAllMessages();

protected:
	void paintEvent(QPaintEvent *);

	void mouseMoveEvent(QMouseEvent *);
	void mousePressEvent(QMouseEvent *);
	void mouseDoubleClickEvent(QMouseEvent *e);

	void resizeEvent(QResizeEvent *);
	void leaveEvent(QEvent *);
	void showEvent(QShowEvent *);
	void wheelEvent(QWheelEvent *);

private:
	void drawBackground(QPainter* painter);
	void drawItems(QPainter* painter);
	//void drawHoverRect(QPainter* painter);

	void initVars();
	void initSettings();
	void calcGeo();
	void wheelUp();
	void wheelDown();

Q_SIGNALS:
	void sig_setMaximum(int max);
	void sig_setCurrentIndex(int currIndex);
	void sig_itemClicked(const QString& str);
	void signalDownloadFile(const QString &fileName);

private Q_SLOTS:
	void SltFileMenuClicked(QAction *action);
	void SltTextMenuClicked(QAction *action);

public Q_SLOTS:
	void setCurrentIndex(int curIndex);

private:
	QMenu *		textRightButtonMenu;
	QMenu *		picRightButtonMenu;
	QMenu *		fileRightButtonMenu;

	QVector<InfoItem*>	m_ifiColl;

	int		m_currIndex;
	int		m_selectedIndex;
	int		m_VisibleItemCnt;
	int		m_ItemCounter;

	bool	m_bAllJobsDone;

	QRectF	m_HoverRect;

	QString m_strHoverText;

	QFont	m_font;

	bool    m_bHover;
	int     m_nHoverItemIndex;
};

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT ChatMsgDisplayWidget : public QWidget
{
	Q_OBJECT

public:
	ChatMsgDisplayWidget(QWidget *parent = Q_NULLPTR);
	~ChatMsgDisplayWidget();

	void dispMsg(const QString& strName, const string& strMsg, int flag);

	void addItem(InfoItem *item);
	void addItems(QVector<InfoItem*> items);

	void clear();

	void render();

	void setCurrItem(const int &index);

protected:
	QSize sizeHint() const
	{
		return QSize(SIZE_HINT);
	}

	void resizeEvent(QResizeEvent *);

private:
	void initVars();
	void initWgts();
	void initStgs();
	void initConns();

	void calcGeo();

Q_SIGNALS:
	void sig_setCurrentIndex(int currIndex);
	void sig_itemClicked(const QString& str);
	void signalDownloadFile(const QString &fileName);

private Q_SLOTS:
	void setMaximum(int max);

private:
	QHBoxLayout*			mainLayout;
	QScrollBar*				scrollbar;
	ChatMsgWidget*			d;

	QDateTime				m_lastShowMsgTime;
};

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////



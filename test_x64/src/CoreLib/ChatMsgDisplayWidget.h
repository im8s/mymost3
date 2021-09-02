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
	Text,           // ��ͨ������Ϣ
	Audio,          // ������Ϣ
	Picture,        // ͼƬ��Ϣ
	Files,          // �ļ�����
	DateTime,       // ����ʱ��
};

//enum  E_MSG_TYPE
//{
//	Unknow,
//	Register = 0x10,     // �û�ע��
//	Login,                          // �û���¼
//	Logout,                         // �û�ע��
//	LoginRepeat,                    // �ظ���¼
//
//	UserOnLine = 0x15,     // �û�����֪ͨ
//	UserOffLine,                    // �û�����֪ͨ
//	UpdateHeadPic,                  // �û�����ͷ��
//
//	AddFriend = 0x20,     // ��Ӻ���
//	AddGroup,                       // ���Ⱥ��
//
//	AddFriendRequist,               // ��Ӻ���ȷ��֪ͨ
//	AddGroupRequist,                // ���Ⱥ��ȷ��֪ͨ
//
//	CreateGroup = 0x25,     // ����Ⱥ��
//
//	GetMyFriends = 0x30,     // ���߻�ȡ�ҵĺ��ѵ�״̬
//	GetMyGroups,                    // ��ȡ�ҵ�Ⱥ����Ϣ
//
//	RefreshFriends = 0x35,     // ˢ�º���״̬
//	RefreshGroups,                  // ˢ��Ⱥ���Ա״̬
//
//	SendMsg = 0x40,     // ������Ϣ
//	SendGroupMsg,                   // ����Ⱥ����Ϣ
//	SendFile,                       // �����ļ�
//	SendPicture,                    // ����ͼƬ
//	SendFace,                       // ���ͱ���
//
//	ChangePasswd = 0x50,     // �޸�����
//
//	DeleteFriend = 0x55,     // ɾ������
//	DeleteGroup,                    // �˳�Ⱥ��
//
//	SendFileOk = 0x60,     // �ļ��������״̬
//
//	GetFile = 0x65,     // ��ȡ�ļ����������������ļ���
//	GetPicture,                     // ͼƬ����
//};

//enum E_STATUS
//{
//	ConnectedHost = 0x01,
//	DisConnectedHost,
//
//	LoginSuccess,       // ��¼�ɹ�
//	LoginPasswdError,   // �������
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



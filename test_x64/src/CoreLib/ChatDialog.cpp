#include "ChatDialog.h"
#include "DataPacket.h"
#include "ToolFunc.h"

//#include "MyApplication.h"

#include "ui_ChatDialog.h"

//#include "ControlManager.h"

#include <QDebug>
#include <QCloseEvent>
#include <QKeyEvent>


ChatDialog::ChatDialog(QWidget *parent)
    : QDialog(parent)
{
	ui = new Ui_ChatAppClass();
    ui->setupUi(this);

	ui->ledtHost->setText("localhost");
	ui->ledtPort->setText("8999");
	ui->ledtUser->setText("admin");
	ui->ledtPass->setText("pass");

	QObject::connect(ui->pbtnSend, SIGNAL(clicked()), this, SLOT(onClickedPBtnSend()));
	QObject::connect(ui->pbtnConnectTo, SIGNAL(clicked()), this, SLOT(onConnectTo()));

	//QObject::connect(CMGR, SIGNAL(connectedStateChanged(bool)), this, SLOT(connectedStateChanged(bool)));
	//QObject::connect(CMGR, SIGNAL(stateChanged(quint32, qint32)), this, SLOT(stateChanged(quint32, qint32)));
	//QObject::connect(CMGR, SIGNAL(dispTalkMsg(qint32, const QString&, const string&, int)), this, SLOT(dispTalkMsg(qint32, const QString&, const string&, int)));
	
	//setWindowFlags(windowFlags() | Qt::WindowStaysOnTopHint);
	//setAttribute(Qt::WA_DeleteOnClose);

	//connectedStateChanged(CMGR->getConnected());
}

ChatDialog::~ChatDialog()
{
	//Q_EMIT widgetDestroyed();

	delete ui;
}

void ChatDialog::closeEvent(QCloseEvent *e)
{
	m_bQuit = true;

	Q_EMIT widgetDestroyed();

	QDialog::closeEvent(e);
}

void ChatDialog::keyPressEvent(QKeyEvent *event)
{
	switch (event->key())
	{
	case Qt::Key_Escape:
		break;
	default:
		QDialog::keyPressEvent(event);
	}
}

void ChatDialog::onClickedPBtnSend()
{
	QString str = ui->ledtMsg->text();

	//CMGR->doTalkMsg(str);
}

void ChatDialog::onConnectTo()
{
	ui->pbtnConnectTo->setEnabled(false);
	{
		bool bConnected = false; /*CMGR->getConnected();*/

		if (!bConnected)
		{
			QString strHost = ui->ledtHost->text();
			quint16 port = ui->ledtPort->text().toInt();
			QString strUser = ui->ledtUser->text();
			QString strPass = ui->ledtPass->text();

			//CMGR->setPlayerName(strUser);

			ui->pbtnConnectTo->setText(ZN_STR("正在连接聊天室..."));

			bool b = false; // CMGR->connectToHost(strHost, port);
			if (b)
			{
				ui->pbtnConnectTo->setText(ZN_STR("离开聊天室"));

				//if (CMGR->doLoginMsg(strUser, strPass))
				{
				
				}
			}
			else
			{
				ui->pbtnConnectTo->setText(ZN_STR("加入聊天室"));
			}

			//CMGR->setConnected(b);
		}
		else
		{
			//CMGR->disconnect();

			ui->pbtnConnectTo->setText(ZN_STR("加入聊天室"));
		}
	}
	ui->pbtnConnectTo->setEnabled(true);
}

void ChatDialog::connectedStateChanged(bool bConnected)
{
	stateChanged(0, bConnected ? 0 : -1);
}

void ChatDialog::stateChanged(quint32 msgId, qint32 code)
{
	if (m_bQuit)
		return;

	if (0 == msgId)
	{
		if (0 == code)
		{
			ui->pbtnConnectTo->setText(ZN_STR("离开聊天室"));
			ui->pbtnConnectTo->setEnabled(true);
		}
		else
		{
			ui->pbtnConnectTo->setText(ZN_STR("加入聊天室"));
			ui->pbtnConnectTo->setEnabled(true);
		}
	}
}

void ChatDialog::dispTalkMsg(qint32 pId, const QString& strName, const string& strContent, int flag)
{
	if (!m_bQuit)
	{
		//ui->tedtMsg->dispMsg(strName, strContent, flag);

		QString strMsg = strName + "==>\n\t" + strContent.data() + "\n\n";
		strMsg = ui->tedtMsg->toPlainText() + strMsg;

		if (strMsg.size() > 1000)
			strMsg = strMsg.remove(0, strMsg.size() - 2000);

		ui->tedtMsg->setText(strMsg);
		ui->tedtMsg->moveCursor(QTextCursor::End);
	}
}




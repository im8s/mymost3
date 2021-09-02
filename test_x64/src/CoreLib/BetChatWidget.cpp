#include "BetChatWidget.h"
#include "ui_BetChatWidget.h"

#include "DataPacket.h"
#include "ToolFunc.h"

#include "BetApplication.h"
#include "BetCtlManager.h"

#include <QDebug>
#include <QCloseEvent>
#include <QKeyEvent>


BetChatWidget::BetChatWidget(QWidget *parent)
	: QWidget(parent)
{
	ui = new Ui::BetChatWidget();
	ui->setupUi(this);

	ui->tedtMsg->document()->setMaximumBlockCount(1000);

	ui->ledtHost->setText("localhost");
	ui->ledtPort->setText("8999");
	ui->ledtUser->setText("admin");
	ui->ledtPass->setText("pass");

	QObject::connect(ui->pbtnSend, SIGNAL(clicked()), this, SLOT(onClickedPBtnSend()));
	QObject::connect(ui->pbtnConnectTo, SIGNAL(clicked()), this, SLOT(onConnectTo()));

	QObject::connect((QObject*)BCMGR->getBetRobot(), SIGNAL(connectedStateChanged(const QString&, bool)), this, SLOT(connectedStateChanged(const QString&, bool)));
	QObject::connect((QObject*)BCMGR->getBetRobot(), SIGNAL(stateChanged(quint32, qint32)), this, SLOT(stateChanged(quint32, qint32)));

	QObject::connect((QObject*)BCMGR, SIGNAL(dispTalkMsg(const QString&, const QString&, const QString&, int)),
		this, SLOT(dispTalkMsg(const QString&, const QString&, const QString&, int)));

	/*QObject::connect((QObject*)BCMGR, SIGNAL(dispSysTalkMsg(const QString&, const QString&, const QString&, int)),
		this, SLOT(dispTalkMsg(const QString&, const QString&, const QString&, int)));*/

		//QObject::connect(this, SIGNAL(sigTalkMsg(const QString&)), BCMGR, SLOT(slotTalkMsg(const QString&)));
		//QObject::connect(this, SIGNAL(sigSysTalkMsg(const QString&)), BCMGR, SLOT(slotSysTalkMsg(const QString&)));

		/*QObject::connect(this, SIGNAL(sigTalkMsg(const QString&)), (QObject*)BCMGR->getBetTask(), SLOT(slotTalkMsg(const QString&)));
		QObject::connect(this, SIGNAL(sigSysTalkMsg(const QString&)), (QObject*)BCMGR->getBetTask(), SLOT(slotSysTalkMsg(const QString&)));*/

		//setWindowFlags(windowFlags() | Qt::WindowStaysOnTopHint);
		//setAttribute(Qt::WA_DeleteOnClose);

	connectedStateChanged("", BCMGR->getConnected());

	m_st.start();
}

BetChatWidget::~BetChatWidget()
{
	//Q_EMIT widgetDestroyed();

	delete ui;
}

void BetChatWidget::closeEvent(QCloseEvent *e)
{
	m_bQuit = true;

	Q_EMIT widgetDestroyed();

	QWidget::closeEvent(e);
}

void BetChatWidget::keyPressEvent(QKeyEvent *event)
{
	switch (event->key())
	{
	case Qt::Key_Escape:
		break;
	default:
		QWidget::keyPressEvent(event);
	}
}

void BetChatWidget::onClickedPBtnSend()
{
	QString str = ui->ledtMsg->text();

	BCMGR->talkMsgInQueue(str);
}

void BetChatWidget::onConnectTo()
{
	ui->pbtnConnectTo->setEnabled(false);
	{
		bool bConnected = BCMGR->getConnected();

		if (!bConnected)
		{
			QString strHost = ui->ledtHost->text();
			quint16 port = ui->ledtPort->text().toInt();
			QString strUser = ui->ledtUser->text();
			QString strPass = ui->ledtPass->text();

			tLoginParam lp;
			lp.strHost = strHost;
			lp.nPort = port;
			lp.strUser = strUser;
			lp.strPass = strPass;

			BCMGR->setBetRobotParams(lp);

			/*BCMGR->setPlayerName(strUser);

			ui->pbtnConnectTo->setText(ZN_STR("正在连接聊天室..."));

			bool b = BCMGR->connectToHost(strHost, port);
			if (b)
			{
				ui->pbtnConnectTo->setText(ZN_STR("离开聊天室"));

				if (BCMGR->doLoginMsg(strUser, strPass))
				{

				}
			}
			else
			{
				ui->pbtnConnectTo->setText(ZN_STR("加入聊天室"));
			}

			BCMGR->setConnected(b);*/
		}
		else
		{
			BCMGR->setGStatus(GS_disconnecting);

			ui->pbtnConnectTo->setText(ZN_STR("加入聊天室"));

			//ui->pbtnConnectTo->setEnabled(true);

			BCMGR->onClearAll();
		}
	}
}

void BetChatWidget::connectedStateChanged(const QString& pid, bool bConnected)
{
	stateChanged(0, bConnected ? 0 : -1);

	ui->pbtnConnectTo->setEnabled(true);
}

void BetChatWidget::stateChanged(quint32 msgId, qint32 code)
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

void BetChatWidget::dispTalkMsg(const QString& pid, const QString& strName, const QString& strContent, int flag)
{
	if (!m_bQuit)
	{
		//ui->tedtMsg->dispMsg(strName, strContent, flag);

		QString strMsg = strName + "==>\n\t" + strContent + "\n\n";

		/*m_strMsg += strMsg;

		if (m_st.elapsed() >= 3000)
		{
			ui->tedtMsg->append(m_strMsg);
			m_strMsg.clear();

			m_st.restart();
		}*/


		//strMsg = ui->tedtMsg->toPlainText() + strMsg;

		//if (strMsg.size() > 2000)
			//strMsg = strMsg.remove(0, strMsg.size() - 2000);

		ui->tedtMsg->setPlainText(strMsg);
		//ui->tedtMsg->moveCursor(QTextCursor::End);
	}
}


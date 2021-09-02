#include "BetDialog.h"

#include "PlayerListWidget.h"
#include "LotteryDataWidget.h"
#include "InfoSettingsWidget.h"
#include "LostrateWidget.h"
#include "GameRuleWidget.h"
#include "VoiceGuideWidget.h"
#include "ExtendedFunctionWidget.h"
#include "InstructionWidget.h"

#include "BetChatWidget.h"

#include "BetApplication.h"
#include "BetCtlManager.h"

#include "ToolFunc.h"

#include "LRSettings.h"

#include <QIcon>
#include <QDateTime>
#include <QTabWidget>
#include <QMessageBox>


BetDialog::BetDialog(QWidget *parent)
    : QDialog(parent)
{
    ui.setupUi(this);

	//setWindowFlags(Qt::WindowMinMaxButtonsHint|Qt::WindowSystemMenuHint);
	setWindowFlags(windowFlags() | Qt::WindowMinMaxButtonsHint | Qt::WindowTitleHint);

	{
		QObject::connect(ui.tbtnLogin, SIGNAL(clicked()), this, SLOT(onClickedPBtnLogin()));
		QObject::connect(ui.tbtnSysStart, SIGNAL(clicked()), this, SLOT(onClickedPBtnSysStartup()));
		QObject::connect(ui.tbtnTimeAdjust, SIGNAL(clicked()), this, SLOT(onClickedPBtnTimeAdjust()));
		QObject::connect(ui.tbtnSaveSettings, SIGNAL(clicked()), this, SLOT(onClickedPBtnSave()));
		QObject::connect(ui.tbtnCardRecharge, SIGNAL(clicked()), this, SLOT(onClickedPBtnCardRecharge()));

		QObject::connect(BCMGR, SIGNAL(dispALottery(int,const tLottery&)), this, SLOT(dispALottery(int,const tLottery&)));
		QObject::connect(BCMGR, SIGNAL(dispDrawLotteryTimeLeft(const QString&)), this, SLOT(dispDrawLotteryTimeLeft(const QString&)));
		QObject::connect(BCMGR, SIGNAL(statusMsgHint(int, const QString&)), this, SLOT(statusMsgHint(int, const QString&)));

		//QObject::connect((QObject*)BCMGR->getBetRobot(), SIGNAL(statusMsgHint(int, const QString&)), this, SLOT(statusMsgHint(int, const QString&)));
	}

	{
		{
			ui.statusWidget->setSizeGripEnabled(false);
			//ui.statusWidget->showMessage(ZN_STR("准备"),3000);
			//ui.statusWidget->addWidget(new QLabel("test text"));

			//lbl0 = new QLabel(ZN_STR("Stop"));
			lbl0 = new QLabel(ZN_STR("-"));
			lbl0->setMinimumSize(70, 20);
			lbl0->setFrameShape(QFrame::Panel);
			lbl0->setFrameShadow(QFrame::Sunken);
			lbl0->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
			ui.statusWidget->addPermanentWidget(lbl0);

			//lbl1 = new QLabel(ZN_STR("停止"));
			lbl1 = new QLabel(ZN_STR("-"));
			lbl1->setMinimumSize(180, 20);
			lbl1->setFrameShape(QFrame::Panel);
			lbl1->setFrameShadow(QFrame::Sunken);
			lbl1->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
			lbl1->setStyleSheet("color: rgb(255, 0, 0);");
			QFont font = lbl1->font();
			font.setBold(true);
			lbl1->setFont(font);
			ui.statusWidget->addPermanentWidget(lbl1);

			lbl2 = new QLabel(ZN_STR("-"));
			lbl2->setMinimumSize(200, 20);
			lbl2->setFrameShape(QFrame::Panel);
			lbl2->setFrameShadow(QFrame::Sunken);
			lbl2->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
			lbl2->setStyleSheet("color: rgb(255, 0, 0);");
			lbl2->setFont(font);
			ui.statusWidget->addPermanentWidget(lbl2);

			//lbl3 = new QLabel(ZN_STR("强制停猜"));
			lbl3 = new QLabel(ZN_STR("-"));
			lbl3->setMinimumSize(90, 20);
			lbl3->setFrameShape(QFrame::Panel);
			lbl3->setFrameShadow(QFrame::Sunken);
			lbl3->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
			ui.statusWidget->addPermanentWidget(lbl3);

			//lbl4 = new QLabel(ZN_STR("主号登录 13725859862金刚、13725859862"));
			lbl4 = new QLabel(ZN_STR("-"));
			lbl4->setMinimumSize(70, 20);
			lbl4->setFrameShape(QFrame::Panel);
			lbl4->setFrameShadow(QFrame::Sunken);
			lbl4->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
			ui.statusWidget->addPermanentWidget(lbl4, 16777215);
		}

		ui.tbtnLogin->setText(ZN_STR("登录主号"));
		ui.tbtnLogin->setIcon(QIcon(":/image/bold.png"));

		ui.tbtnSysStart->setText(ZN_STR("系统启动"));
		ui.tbtnSysStart->setIcon(QIcon(":/image/clear.png"));

		ui.tbtnTimeAdjust->setText(ZN_STR("时间校准"));
		ui.tbtnTimeAdjust->setIcon(QIcon(":/image/color.png"));

		ui.tbtnSaveSettings->setText(ZN_STR("保存设置"));
		ui.tbtnSaveSettings->setIcon(QIcon(":/image/save.png"));

		ui.tbtnCardRecharge->setText(ZN_STR("卡密充值"));
		ui.tbtnCardRecharge->setIcon(QIcon(":/image/send.png"));

		ui.tbtnAKeyScreenshot->setText(ZN_STR("一键截图"));
		ui.tbtnAKeyScreenshot->setIcon(QIcon(":/image/under.png"));
		{
			QPalette pat;
			pat.setColor(QPalette::ButtonText, Qt::red);
			ui.tbtnAKeyScreenshot->setPalette(pat);
		}

		{
			//ui.infoWidget->setStyleSheet("background-color: rgb(166, 202, 240);");
		}

		{
			QTabWidget* tabWidget = ui.bridgeWidget->getTabWidget();

			tabWidget->clear();
			{
				PlayerListWidget* p = new PlayerListWidget();
				tabWidget->addTab(p, p->windowTitle());
			}

			{
				LotteryDataWidget* p = new LotteryDataWidget();
				tabWidget->addTab(p, p->windowTitle());
			}

			{
				InfoSettingsWidget* p = new InfoSettingsWidget();
				tabWidget->addTab(p, p->windowTitle());
			}

			{
				LostrateWidget* p = new LostrateWidget();
				tabWidget->addTab(p, p->windowTitle());
			}

			{
				GameRuleWidget* p = new GameRuleWidget();
				tabWidget->addTab(p, p->windowTitle());
			}

			{
				VoiceGuideWidget* p = new VoiceGuideWidget();
				tabWidget->addTab(p, p->windowTitle());
			}

			{
				ExtendedFunctionWidget* p = new ExtendedFunctionWidget();
				tabWidget->addTab(p, p->windowTitle());
			}

			{
				InstructionWidget* p = new InstructionWidget();
				tabWidget->addTab(p, p->windowTitle());
			}
		}
	}

	{
		QObject::connect(&timer, SIGNAL(timeout()), this, SLOT(onTimedout()));
		timer.start(800);
	}
}

BetDialog::~BetDialog()
{

}

void BetDialog::keyPressEvent(QKeyEvent *event)
{
	switch (event->key())
	{
	case Qt::Key_Escape:
		break;
	default:
		QDialog::keyPressEvent(event);
	}
}

void BetDialog::onTimedout()
{
	QDateTime dt = QDateTime::currentDateTime();
	QString str = dt.toString("yyyy-MM-dd hh:mm:ss");

	lbl2->setText(str);
}

void BetDialog::onClickedPBtnLogin()
{
	if (!chatDlg)
	{
		ui.tbtnLogin->setEnabled(false);

		chatDlg = new BetChatWidget();
		QObject::connect(chatDlg, SIGNAL(widgetDestroyed()), this, SLOT(widgetLoginDestroyed()));
		chatDlg->show();
	}
}

void BetDialog::onClickedPBtnSysStartup()
{
	ui.tbtnSysStart->setEnabled(false);
	{
		bool b = !BCMGR->getSysStartup();

		BCMGR->setSysStartup(b);

		ui.tbtnSysStart->setText(b ? ZN_STR("系统停止") : ZN_STR("系统启动"));
	}
	ui.tbtnSysStart->setEnabled(true);
}

void BetDialog::onClickedPBtnTimeAdjust()
{
	ui.tbtnTimeAdjust->setEnabled(false);
	BCMGR->lotteryRequest(0);
	ui.tbtnTimeAdjust->setEnabled(true);
}

void BetDialog::onClickedPBtnSave()
{
	ui.tbtnSaveSettings->setEnabled(false);
	{
		QTabWidget* tabWidget = ui.bridgeWidget->getTabWidget();

		{
			LostrateWidget* p = (LostrateWidget*)tabWidget->widget(3);
			if (p)
			{
				LRSettings lrs;
				bool b = p->getDataFromUI(lrs);
				if (!b)
				{
					QMessageBox::information(this, ZN_STR("信息提示"), ZN_STR("提取赔率数据失败"));
				}
				else
				{
					BCMGR->setLRSettings(lrs);
				}
			}
		}

		{
			GameRuleWidget* p = (GameRuleWidget*)tabWidget->widget(4);
			if (p)
			{
				LotteryRule lr;
				bool b = p->getDataFromUI(lr);
				if (!b)
				{
					QMessageBox::information(this, ZN_STR("信息提示"), ZN_STR("提取游戏规则数据失败"));
				}
				else
				{
					BCMGR->setLotteryRule(lr);
				}
			}
		}

		if (BCMGR->saveConfigFromFile())
		{
			QMessageBox::information(this, ZN_STR("信息提示"), ZN_STR("保存设置参数成功"));
		}
		else
		{
			QMessageBox::information(this, ZN_STR("信息提示"), ZN_STR("保存设置参数失败"));
		}
	}
	ui.tbtnSaveSettings->setEnabled(true);
}

void BetDialog::onClickedPBtnCardRecharge()
{

}

void BetDialog::widgetLoginDestroyed()
{
	if (chatDlg)
	{
		//chatDlg->close();
		chatDlg->deleteLater();
		chatDlg = nullptr;
	}

	ui.tbtnLogin->setEnabled(true);
}

void BetDialog::dispALottery(int flag, const tLottery& lot)
{
	if (0 == flag)
	{
		ui.lblNo->setText(QString::number(lot.nPeriods));
	}
	else if (1 == flag)
	{
		QString str = "[" + QString::number(lot.nPeriods) + "]: " + lot.asAllResult();
		ui.lblLastInfo->setText(str);
	}
}

void BetDialog::dispDrawLotteryTimeLeft(const QString& strDt)
{
	ui.lblWaitInfo->setText(strDt);
}

void BetDialog::statusMsgHint(int flag, const QString& strMsg)
{
	if (0 == flag)
	{
		lbl0->setText(strMsg);
	}
	else if (1 == flag)
	{
		lbl1->setText(strMsg);
	}
	else if (2 == flag)
	{
		lbl3->setText(strMsg);
	}
}

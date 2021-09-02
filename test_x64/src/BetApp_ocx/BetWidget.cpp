#include "BetWidget.h"
#include "ui_BetWidget.h"

#include "PlayerListWidget.h"
#include "LotteryDataWidget.h"
#include "InfoSettingsWidget.h"
#include "LostrateWidget.h"
#include "GameRuleWidget.h"
#include "VoiceGuideWidget.h"
#include "ExtendedFunctionWidget.h"
#include "InstructionWidget.h"

#include "BetCtlManager.h"

#include <QIcon>
#include <QDateTime>
#include <QTabWidget>
#include <QMessageBox>
#include <QKeyEvent>


BetWidget::BetWidget(QWidget *parent)
	: QWidget(parent)
{
	ui = new Ui::BetWidget();
	ui->setupUi(this);

	//setWindowFlags(Qt::WindowMinMaxButtonsHint|Qt::WindowSystemMenuHint);
	setWindowFlags(windowFlags() | Qt::WindowMinMaxButtonsHint | Qt::WindowTitleHint);

	{
		QObject::connect(ui->tbtnLogin, SIGNAL(clicked()), this, SLOT(onClickedPBtnLogin()));
		QObject::connect(ui->tbtnSysStart, SIGNAL(clicked()), this, SLOT(onClickedPBtnSysStartup()));
		QObject::connect(ui->tbtnTimeAdjust, SIGNAL(clicked()), this, SLOT(onClickedPBtnTimeAdjust()));
		QObject::connect(ui->tbtnSaveSettings, SIGNAL(clicked()), this, SLOT(onClickedPBtnSave()));
		QObject::connect(ui->tbtnCardRecharge, SIGNAL(clicked()), this, SLOT(onClickedPBtnCardRecharge()));

		QObject::connect(BCMGR, SIGNAL(dispALottery(int, const tLottery&)), this, SLOT(dispALottery(int, const tLottery&)));
		QObject::connect(BCMGR, SIGNAL(dispDrawLotteryTimeLeft(const QString&)), this, SLOT(dispDrawLotteryTimeLeft(const QString&)));
		QObject::connect(BCMGR, SIGNAL(statusMsgHint(int, const QString&)), this, SLOT(statusMsgHint(int, const QString&)));

		QObject::connect(BCMGR, SIGNAL(sigMsgSend(const QString&, const QString&)), this, SLOT(slotMsgSend(const QString&, const QString&)));

		QObject::connect(ui->cmbSelGrp, SIGNAL(currentIndexChanged(int)), this, SLOT(currentIndexChangedForGroupID(int)));

		QObject::connect(BCMGR, SIGNAL(onRefreshGroupInfo()), this, SLOT(onRefreshGroupInfo()));

	}

	{
		ui->tbtnLogin->setText(ZN_STR("登录主号"));
		ui->tbtnLogin->setIcon(QIcon(":/image/bold.png"));

		ui->tbtnSysStart->setText(ZN_STR("系统启动"));
		ui->tbtnSysStart->setIcon(QIcon(":/image/clear.png"));

		ui->tbtnTimeAdjust->setText(ZN_STR("时间校准"));
		ui->tbtnTimeAdjust->setIcon(QIcon(":/image/color.png"));

		ui->tbtnSaveSettings->setText(ZN_STR("保存设置"));
		ui->tbtnSaveSettings->setIcon(QIcon(":/image/save.png"));

		ui->tbtnCardRecharge->setText(ZN_STR("卡密充值"));
		ui->tbtnCardRecharge->setIcon(QIcon(":/image/send.png"));

		ui->tbtnAKeyScreenshot->setText(ZN_STR("一键截图"));
		ui->tbtnAKeyScreenshot->setIcon(QIcon(":/image/under.png"));
		{
			QPalette pat;
			pat.setColor(QPalette::ButtonText, Qt::red);
			ui->tbtnAKeyScreenshot->setPalette(pat);
		}

		{
			//ui->infoWidget->setStyleSheet("background-color: rgb(166, 202, 240);");
		}

		{
			QTabWidget* tabWidget = ui->bridgeWidget->getTabWidget();

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

BetWidget::~BetWidget()
{
	delete ui;
}

void BetWidget::keyPressEvent(QKeyEvent *event)
{
	switch (event->key())
	{
	case Qt::Key_Escape:
		break;
	default:
		QWidget::keyPressEvent(event);
	}
}

#if 1
void BetWidget::msgArrived(const QString& pid, const QString& strName, const QString& strMsg)
{
	BCMGR->msgArrived(pid, strName, strMsg);
}
#else
void BetWidget::msgArrived(const QString& gid, const QString& pid, const QString& strName, const QString& strMsg)
{
	BCMGR->msgArrived(gid, pid, strName, strMsg);
}
#endif

void BetWidget::notifyGroupInfo(const QVariant& v)
{
	BCMGR->notifyGroupInfo(v);
}

void BetWidget::notifyGroupCreated(const QVariant& v)
{
	BCMGR->notifyGroupCreated(v);
}

void BetWidget::notifyGroupDeleted(const QString& gid)
{
	BCMGR->notifyGroupDeleted(gid);
}

void BetWidget::notifyMemberInfo(const QVariant& v)
{
	BCMGR->notifyMemberInfo(v);
}

void BetWidget::notifyMemberJoin(const QVariant& v)
{
	BCMGR->notifyMemberJoin(v);
}

void BetWidget::notifyMemberLeave(const QString& pid)
{
	BCMGR->notifyMemberLeave(pid);
}

void BetWidget::onTimedout()
{
	QDateTime dt = QDateTime::currentDateTime();
	QString str = dt.toString("yyyy-MM-dd hh:mm:ss");

	ui->statusWidget->setText(2, str);
}

void BetWidget::onClickedPBtnLogin()
{
	Q_EMIT onPBtnLoginClicked();
}

void BetWidget::onClickedPBtnSysStartup()
{
	ui->tbtnSysStart->setEnabled(false);
	{
		bool b = !BCMGR->getSysStartup();

		BCMGR->setSysStartup(b);

		ui->tbtnSysStart->setText(b ? ZN_STR("系统停止") : ZN_STR("系统启动"));
	}
	ui->tbtnSysStart->setEnabled(true);
}

void BetWidget::onClickedPBtnTimeAdjust()
{
	ui->tbtnTimeAdjust->setEnabled(false);
	BCMGR->lotteryRequest(0);
	ui->tbtnTimeAdjust->setEnabled(true);
}

void BetWidget::onClickedPBtnSave()
{
	ui->tbtnSaveSettings->setEnabled(false);
	{
		QTabWidget* tabWidget = ui->bridgeWidget->getTabWidget();

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
	ui->tbtnSaveSettings->setEnabled(true);
}

void BetWidget::onClickedPBtnCardRecharge()
{

}

void BetWidget::widgetLoginDestroyed()
{
	ui->tbtnLogin->setEnabled(true);
}

void BetWidget::dispALottery(int flag, const tLottery& lot)
{
	if (0 == flag)
	{
		ui->lblNo->setText(QString::number(lot.nPeriods));
	}
	else if (1 == flag)
	{
		QString str = "[" + QString::number(lot.nPeriods) + "]: " + lot.asAllResult();
		ui->lblLastInfo->setText(str);
	}
}

void BetWidget::dispDrawLotteryTimeLeft(const QString& strDt)
{
	ui->lblWaitInfo->setText(strDt);
}

void BetWidget::statusMsgHint(int flag, const QString& strMsg)
{
	if (0 == flag)
	{
		ui->statusWidget->setText(0, strMsg);
	}
	else if (1 == flag)
	{
		ui->statusWidget->setText(1, strMsg);
	}
	else if (2 == flag)
	{
		ui->statusWidget->setText(3, strMsg);
	}
}

void BetWidget::slotMsgSend(const QString& gid, const QString& strMsg)
{
	Q_EMIT msgSend(gid, strMsg);
}

void BetWidget::currentIndexChangedForGroupID(int index)
{
	QString strGId = ui->cmbSelGrp->itemData(index).toString();

	BCMGR->setGroupID(strGId);

	Q_EMIT setGroupId(strGId);
}

void BetWidget::onRefreshGroupInfo()
{
	ui->cmbSelGrp->clear();

	tGroupRefVector coll;
	BCMGR->getGroupInfoVector(coll);

	for (int k = 0; k < coll.size(); ++k)
	{
		const tGroup& gi = coll[k];

		ui->cmbSelGrp->addItem(gi.strName, gi.gid);
	}

	QString strGId = BCMGR->getGroupID();
	ui->cmbSelGrp->setCurrentText(strGId);
}


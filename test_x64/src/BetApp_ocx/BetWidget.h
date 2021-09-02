#pragma once

#include <QAxBindable>
#include <QAxFactory>
#include <QWidget>
namespace Ui { class BetWidget; };

#include "gdata.h"

#include "GroupInfo.h"
#include "PlayerInfo.h"

#include "GroupInfoList.h"
#include "PlayerInfoList.h"

#include <QTimer>

class QLabel;
class BetChatWidget;
class BetWidget : public QWidget, public QAxBindable
{
	Q_OBJECT

	Q_CLASSINFO("ClassID", "{DF16845C-92CD-4AAB-A982-EB9840E7466A}")
	Q_CLASSINFO("InterfaceID", "{616F620B-91C5-4410-A74E-6B81C76FFFE1}")
	Q_CLASSINFO("EventsID", "{E1816BBA-BF5D-4A31-9855-D6BA43205600}")

	//Q_PROPERTY(QString text READ text WRITE setText)
	//Q_PROPERTY(int value READ value WRITE setValue)

public:
	BetWidget(QWidget *parent = Q_NULLPTR);
	~BetWidget();

protected:
	void keyPressEvent(QKeyEvent *event);

Q_SIGNALS:
	void onPBtnLoginClicked();

	void setGroupId(const QString& gid);
	void msgSend(const QString& gid, const QString& strMsg);

public Q_SLOTS:
#if 1
	void msgArrived(const QString& pid, const QString& strName, const QString& strMsg);
#else
	void msgArrived(const QString& gid, const QString& pid, const QString& strName, const QString& strMsg);
#endif

	void notifyGroupInfo(const QVariant& v);
	void notifyGroupCreated(const QVariant& v);
	void notifyGroupDeleted(const QString& gid);

	void notifyMemberInfo(const QVariant& v);
	void notifyMemberJoin(const QVariant& v);
	void notifyMemberLeave(const QString& pid);

private Q_SLOTS:
	void onTimedout();

	void onClickedPBtnLogin();
	void onClickedPBtnSysStartup();
	void onClickedPBtnTimeAdjust();
	void onClickedPBtnSave();
	void onClickedPBtnCardRecharge();

	void widgetLoginDestroyed();

	void dispALottery(int flag, const tLottery& lot);

	void dispDrawLotteryTimeLeft(const QString& strDt);

	void statusMsgHint(int flag, const QString& strMsg);

	void slotMsgSend(const QString& gid, const QString& strMsg);

	void currentIndexChangedForGroupID(int index);

	void onRefreshGroupInfo();

private:
	Ui::BetWidget *ui;

	QTimer		timer;
};

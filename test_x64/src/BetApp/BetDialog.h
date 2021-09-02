#pragma once

#include <QtWidgets/QDialog>
#include "ui_BetDialog.h"

#include "gdata.h"

#include <QTimer>

class QLabel;
class BetChatWidget;
class BetDialog : public QDialog
{
    Q_OBJECT

public:
    BetDialog(QWidget *parent = Q_NULLPTR);
	~BetDialog();

protected:
	void keyPressEvent(QKeyEvent *event);

signals:

private slots:
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

private:
    Ui::BetDialog ui;

	QLabel*		lbl0 = nullptr;
	QLabel*		lbl1 = nullptr;
	QLabel*		lbl2 = nullptr;
	QLabel*		lbl3 = nullptr;
	QLabel*		lbl4 = nullptr;

	QTimer		timer;

	BetChatWidget*		chatDlg = nullptr;
};

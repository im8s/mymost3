#pragma once

#include "corelib_global.h"

#include <QtWidgets/QDialog>

#include "Connection.h"


class QCloseEvent;
class QKeyEvent;
class Ui_BetChatDialog;
class CORELIB_EXPORT BetChatDialog : public QDialog
{
    Q_OBJECT

public:
    BetChatDialog(QWidget *parent = Q_NULLPTR);
	~BetChatDialog();

protected:
	void closeEvent(QCloseEvent *e);

	void keyPressEvent(QKeyEvent *event);

signals:
	void widgetDestroyed();

public slots:
	void onClickedPBtnSend();
	void onConnectTo();

	void connectedStateChanged(const QString& pid, bool bConnected);
	void stateChanged(quint32 msgId, qint32 code);

	void dispTalkMsg(const QString& pId, const QString& strName, const QString& strContent, int flag);

private:
	Ui_BetChatDialog*	ui;

	bool	m_bQuit = false;
};

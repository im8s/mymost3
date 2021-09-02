#pragma once

#include "corelib_global.h"

#include <QtWidgets/QDialog>

#include "Connection.h"


class QCloseEvent;
class QKeyEvent;
class Ui_ChatAppClass;
class CORELIB_EXPORT ChatDialog : public QDialog
{
    Q_OBJECT

public:
    ChatDialog(QWidget *parent = Q_NULLPTR);
	~ChatDialog();

protected:
	void closeEvent(QCloseEvent *e);

	void keyPressEvent(QKeyEvent *event);

signals:
	void widgetDestroyed();

public slots:
	void onClickedPBtnSend();
	void onConnectTo();

	void connectedStateChanged(bool bConnected);

	void stateChanged(quint32 msgId, qint32 code);

	void dispTalkMsg(qint32 pId, const QString& strName, const string& strContent, int flag);

private:
	Ui_ChatAppClass* ui;

	bool	m_bQuit = false;
};

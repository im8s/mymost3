#pragma once

#include "corelib_global.h"

#include <QWidget>
namespace Ui { class BetChatWidget; };

#include "Connection.h"


class QCloseEvent;
class QKeyEvent;
class CORELIB_EXPORT BetChatWidget : public QWidget
{
	Q_OBJECT

public:
	BetChatWidget(QWidget *parent = Q_NULLPTR);
	~BetChatWidget();

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
	Ui::BetChatWidget *ui;

	bool	m_bQuit = false;

	QTime		m_st;
	QString		m_strMsg;
};

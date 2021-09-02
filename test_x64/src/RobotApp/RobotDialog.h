#pragma once

#include <QtWidgets/QDialog>
#include "ui_RobotDialog.h"


class RobotDialog : public QDialog
{
    Q_OBJECT

public:
    RobotDialog(QWidget *parent = Q_NULLPTR);

signals:

private slots:
	void onClickedPBtnSelFilePath();
	void onClickedPBtnStartup();

	void onOnline();
	void onOffline();

	void slotShowContextMenu(const QPoint& point);

	void slotRobotTaskQuit();

private:
    Ui::RobotAppClass	ui;

	QMenu*		m_menu;

	bool		m_bStartup = false;

	int			m_nThreadNum = 0;
	int			m_nCurThreadNum = 0;
};

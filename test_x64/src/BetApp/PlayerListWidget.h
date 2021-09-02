#pragma once

#include <QWidget>
#include "ui_PlayerListWidget.h"


class QMenu;
class PScoreTVModel;
class PlayerListWidget : public QWidget
{
	Q_OBJECT

public:
	PlayerListWidget(QWidget *parent = Q_NULLPTR);
	~PlayerListWidget();

signals:


public slots:
	void slotShowContextMenu(const QPoint& point);

	void onRefreshModel();

private:
	Ui::PlayerListWidget	ui;

	PScoreTVModel* model	= nullptr;

	QMenu*		m_menu = nullptr;
};

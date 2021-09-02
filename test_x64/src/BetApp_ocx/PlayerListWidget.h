#pragma once

#include <QWidget>


class QMenu;
class PScoreTVModel;
class Ui_PlayerListWidget;
class PlayerListWidget : public QWidget
{
	Q_OBJECT

public:
	PlayerListWidget(QWidget *parent = Q_NULLPTR);
	~PlayerListWidget();

signals:


public slots:
	void slotShowContextMenu(const QPoint& point);

	//void onRefreshModel();

private:
	Ui_PlayerListWidget*	ui = nullptr;

	PScoreTVModel* model	= nullptr;

	QMenu*		m_menu = nullptr;
};

#pragma once

#include <QWidget>
#include "ui_LotteryDataWidget.h"

#include "pdata.h"


class QMenu;
class LotteryDataTVModel;
class LotteryDataWidget : public QWidget
{
	Q_OBJECT

public:
	LotteryDataWidget(QWidget *parent = Q_NULLPTR);
	~LotteryDataWidget();

signals:
	

public slots:
	void onClickedPBtnFetchLotteryData();

	void slotShowContextMenu(const QPoint& point);

	void onRefreshModel();

private:
	Ui::LotteryDataWidget ui;

	LotteryDataTVModel* model = nullptr;

	QMenu*		m_menu = nullptr;
};

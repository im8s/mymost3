#pragma once

#include <QWidget>
#include "ui_ForLotteryWidget.h"


class ForLotteryWidget : public QWidget
{
	Q_OBJECT

public:
	ForLotteryWidget(QWidget *parent = Q_NULLPTR);
	~ForLotteryWidget();

private:
	Ui::ForLotteryWidget ui;
};

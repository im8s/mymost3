#pragma once

#include <QWidget>
#include "ui_ForScoreWidget.h"


class ForScoreWidget : public QWidget
{
	Q_OBJECT

public:
	ForScoreWidget(QWidget *parent = Q_NULLPTR);
	~ForScoreWidget();

private:
	Ui::ForScoreWidget ui;
};

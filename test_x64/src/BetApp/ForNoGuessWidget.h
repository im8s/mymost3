#pragma once

#include <QWidget>
#include "ui_ForNoGuessWidget.h"


class ForNoGuessWidget : public QWidget
{
	Q_OBJECT

public:
	ForNoGuessWidget(QWidget *parent = Q_NULLPTR);
	~ForNoGuessWidget();

private:
	Ui::ForNoGuessWidget ui;
};

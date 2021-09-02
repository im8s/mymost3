#pragma once

#include <QWidget>
#include "ui_MyInfoWidget.h"


class MyInfoWidget : public QWidget
{
	Q_OBJECT

public:
	MyInfoWidget(QWidget *parent = Q_NULLPTR);
	~MyInfoWidget();

private:
	Ui::MyInfoWidget ui;
};

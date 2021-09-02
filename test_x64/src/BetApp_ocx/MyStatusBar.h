#pragma once

#include <QStatusBar>
#include "ui_MyStatusBar.h"


class MyStatusBar : public QStatusBar
{
	Q_OBJECT

public:
	MyStatusBar(QWidget *parent = Q_NULLPTR);
	~MyStatusBar();

private:
	Ui::MyStatusBar ui;
};

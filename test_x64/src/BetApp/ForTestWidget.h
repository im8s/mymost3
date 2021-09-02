#pragma once

#include <QWidget>
#include "ui_ForTestWidget.h"


class ForTestWidget : public QWidget
{
	Q_OBJECT

public:
	ForTestWidget(QWidget *parent = Q_NULLPTR);
	~ForTestWidget();

private:
	Ui::ForTestWidget ui;
};

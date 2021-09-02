#pragma once

#include <QWidget>
#include "ui_ForAdvertiseWidget.h"


class ForAdvertiseWidget : public QWidget
{
	Q_OBJECT

public:
	ForAdvertiseWidget(QWidget *parent = Q_NULLPTR);
	~ForAdvertiseWidget();

private:
	Ui::ForAdvertiseWidget ui;
};

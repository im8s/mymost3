#pragma once

#include <QWidget>
#include "ui_ExtendedFunctionWidget.h"


class ExtendedFunctionWidget : public QWidget
{
	Q_OBJECT

public:
	ExtendedFunctionWidget(QWidget *parent = Q_NULLPTR);
	~ExtendedFunctionWidget();

private:
	Ui::ExtendedFunctionWidget ui;
};

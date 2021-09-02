#pragma once

#include <QWidget>
#include "ui_QuerybackAndCheckWidget.h"


class QuerybackAndCheckWidget : public QWidget
{
	Q_OBJECT

public:
	QuerybackAndCheckWidget(QWidget *parent = Q_NULLPTR);
	~QuerybackAndCheckWidget();

private:
	Ui::QuerybackAndCheckWidget ui;
};

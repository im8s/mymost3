#pragma once

#include <QWidget>
#include "ui_InfoSettingsWidget.h"


class InfoSettingsWidget : public QWidget
{
	Q_OBJECT

public:
	InfoSettingsWidget(QWidget *parent = Q_NULLPTR);
	~InfoSettingsWidget();

private:
	Ui::InfoSettingsWidget ui;
};

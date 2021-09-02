#pragma once

#include <QWidget>
#include "ui_InstructionWidget.h"


class InstructionWidget : public QWidget
{
	Q_OBJECT

public:
	InstructionWidget(QWidget *parent = Q_NULLPTR);
	~InstructionWidget();

private:
	Ui::InstructionWidget ui;
};

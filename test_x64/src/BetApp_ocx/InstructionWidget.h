#pragma once

#include <QWidget>


class Ui_InstructionWidget;
class InstructionWidget : public QWidget
{
	Q_OBJECT

public:
	InstructionWidget(QWidget *parent = Q_NULLPTR);
	~InstructionWidget();

private:
	Ui_InstructionWidget *ui = nullptr;
};

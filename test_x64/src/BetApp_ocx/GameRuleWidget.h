#pragma once

#include <QWidget>
#include "ui_GameRuleWidget.h"


class LotteryRule;
class GameRuleWidget : public QWidget
{
	Q_OBJECT

public:
	GameRuleWidget(QWidget *parent = Q_NULLPTR);
	~GameRuleWidget();

	bool getDataFromUI(LotteryRule& lr);

private:
	void initUIByData();

private:
	Ui::GameRuleWidget	ui;
};

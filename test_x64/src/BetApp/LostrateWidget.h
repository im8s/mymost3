#pragma once

#include <QWidget>
#include "ui_LostrateWidget.h"


class LRSettings;
class LostrateWidget : public QWidget
{
	Q_OBJECT

public:
	LostrateWidget(QWidget *parent = Q_NULLPTR);
	~LostrateWidget();

	bool getDataFromUI(LRSettings& lrs);

protected:

private slots:
	void onCBStateChangedUseLCLikeCard1(int state);
	void onCBStateChangedUseLCLikeCard2(int state);
	void onCBStateChangedUseLCLikeCard3(int state);

	void onClickedPBtnCalculate();

private:
	void initUIByData();

private:
	Ui::LostrateWidget ui;
};

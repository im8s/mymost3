#pragma once

#include <QWidget>
#include "ui_VoiceGuideWidget.h"


class VoiceGuideWidget : public QWidget
{
	Q_OBJECT

public:
	VoiceGuideWidget(QWidget *parent = Q_NULLPTR);
	~VoiceGuideWidget();

private:
	Ui::VoiceGuideWidget ui;
};

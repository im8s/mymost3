#include "MyInfoWidget.h"

#include <QPalette>


MyInfoWidget::MyInfoWidget(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);

	setWindowFlags(windowFlags() | Qt::FramelessWindowHint);

	QPalette pal;
	pal.setColor(QPalette::Background, QColor(166, 202, 240));
	setAutoFillBackground(true);
	setPalette(pal);
}

MyInfoWidget::~MyInfoWidget()
{
}

#include "ExtendedFunctionWidget.h"
#include "ToolFunc.h"


ExtendedFunctionWidget::ExtendedFunctionWidget(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);

	QString str = ZN_STR("������\n���\n����\n����\n������Ա\n");
	ui.tedtNickName->setPlainText(str);
}

ExtendedFunctionWidget::~ExtendedFunctionWidget()
{
}

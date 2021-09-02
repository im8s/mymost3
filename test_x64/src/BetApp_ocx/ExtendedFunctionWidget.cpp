#include "ExtendedFunctionWidget.h"
#include "ToolFunc.h"


ExtendedFunctionWidget::ExtendedFunctionWidget(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);

	QString str = ZN_STR("机器人\n会计\n财务\n管理\n工作人员\n");
	ui.tedtNickName->setPlainText(str);
}

ExtendedFunctionWidget::~ExtendedFunctionWidget()
{
}

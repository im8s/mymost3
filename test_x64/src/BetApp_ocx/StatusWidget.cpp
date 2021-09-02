#include "StatusWidget.h"
//#include "ui_StatusWidget.h"

#include "ToolFunc.h"

#include <QHBoxLayout>
#include <QLabel>


StatusWidget::StatusWidget(QWidget *parent)
	: QWidget(parent)
{
	//ui = new Ui::StatusWidget();
	//ui->setupUi(this);

	QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Fixed);
	sizePolicy.setHorizontalStretch(0);
	sizePolicy.setVerticalStretch(0);
	sizePolicy.setHeightForWidth(this->sizePolicy().hasHeightForWidth());
	this->setSizePolicy(sizePolicy);

	horizontalLayout_9 = new QHBoxLayout(this);
	horizontalLayout_9->setSpacing(6);
	horizontalLayout_9->setContentsMargins(0, 0, 0, 0);
	horizontalLayout_9->setObjectName(ZN_STR("horizontalLayout_9"));

	//lbl0 = new QLabel(ZN_STR("Stop"));
	lbl0 = new QLabel(ZN_STR("-"));
	lbl0->setObjectName(ZN_STR("lbl0"));
	lbl0->setMinimumSize(70, 20);
	lbl0->setFrameShape(QFrame::Panel);
	lbl0->setFrameShadow(QFrame::Sunken);
	lbl0->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);

	horizontalLayout_9->addWidget(lbl0);

	//lbl1 = new QLabel(ZN_STR("Í£Ö¹"));
	lbl1 = new QLabel(ZN_STR("-"));
	lbl1->setObjectName(ZN_STR("lbl1"));
	lbl1->setMinimumSize(180, 20);
	lbl1->setFrameShape(QFrame::Panel);
	lbl1->setFrameShadow(QFrame::Sunken);
	lbl1->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
	lbl1->setStyleSheet("color: rgb(255, 0, 0);");
	QFont font = lbl1->font();
	font.setBold(true);
	lbl1->setFont(font);

	horizontalLayout_9->addWidget(lbl1);

	lbl2 = new QLabel(ZN_STR("-"));
	lbl2->setObjectName(ZN_STR("lbl2"));
	lbl2->setMinimumSize(200, 20);
	lbl2->setFrameShape(QFrame::Panel);
	lbl2->setFrameShadow(QFrame::Sunken);
	lbl2->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
	lbl2->setStyleSheet("color: rgb(255, 0, 0);");
	lbl2->setFont(font);

	horizontalLayout_9->addWidget(lbl2);

	//lbl3 = new QLabel(ZN_STR("Ç¿ÖÆÍ£²Â"));
	lbl3 = new QLabel(ZN_STR("-"));
	lbl3->setObjectName(ZN_STR("lbl3"));
	lbl3->setMinimumSize(90, 20);
	lbl3->setFrameShape(QFrame::Panel);
	lbl3->setFrameShadow(QFrame::Sunken);
	lbl3->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);

	horizontalLayout_9->addWidget(lbl3);

	//lbl4 = new QLabel(ZN_STR("Ö÷ºÅµÇÂ¼ 13725859862½ð¸Õ¡¢13725859862"));
	lbl4 = new QLabel(ZN_STR("-"));
	lbl4->setObjectName(ZN_STR("lbl4"));
	lbl4->setMinimumSize(70, 20);
	lbl4->setFrameShape(QFrame::Panel);
	lbl4->setFrameShadow(QFrame::Sunken);
	lbl4->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);

	horizontalLayout_9->addWidget(lbl4);
}

StatusWidget::~StatusWidget()
{
	//delete ui;
}

void StatusWidget::setText(int flag, const QString& strMsg)
{
	if (0 == flag)
		lbl0->setText(strMsg);
	else if (1 == flag)
		lbl1->setText(strMsg);
	else if (2 == flag)
		lbl2->setText(strMsg);
	else if (3 == flag)
		lbl3->setText(strMsg);
	else if (4 == flag)
		lbl4->setText(strMsg);
}



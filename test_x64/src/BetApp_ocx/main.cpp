#include "BetWidget.h"

#include <ActiveQt/QAxFactory>
#include <QApplication>


//QAXFACTORY_DEFAULT(BetWidget,
//	"{ced2d7d3-66d5-4385-b711-6f7df4ec7c19}",
//	"{f232385d-dcb6-46f1-bdcb-dc465f0d558e}",
//	"{ebb72bb4-da7a-465e-8536-40b317a7356c}",
//	"{a88abfa6-745f-4c5e-b190-e1007adbfc67}",
//	"{0b2468a6-5da4-4f81-84ca-95e2e0ddff15}"
//)

QAXFACTORY_BEGIN(
	"{EC08F8FC-2754-47AB-8EFE-56A54057F34F}", // type library ID
	"{A095BA0C-224F-4933-A458-2DD7F6B85D90}") // application ID
	QAXCLASS(BetWidget)
	QAXCLASS(GroupInfo)
	QAXCLASS(PlayerInfo)
	QAXCLASS(GroupInfoList)
	QAXCLASS(PlayerInfoList)
QAXFACTORY_END()


#if 0
int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

	//if (!QAxFactory::isServer()) 
	//{
	//	MainWindow w;
	//	w.show();// 如果不提供COM服务那就做独立程序该做的事
	//	return app.exec();//离开了{}这个作用域你的w就没了，所以可能看到的是一闪而过的画面，故加此。
	//}

	return app.exec();
}
#endif

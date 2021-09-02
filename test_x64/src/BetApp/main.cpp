#include "BetDialog.h"
#include "BetApplication.h"


#ifdef USE_OCX

#include <QAxFactory>

QT_USE_NAMESPACE

QAXFACTORY_BEGIN("{98DE28B6-6CD3-4e08-B9FA-3D1DB43F1D2F}", "{05828915-AD1C-47ab-AB96-D6AD1E25F0E2}")
	QAXCLASS(BetDialog)
	//QAXCLASS(QAxWidget2)
QAXFACTORY_END()

#else

int main(int argc, char *argv[])
{
	BetApplication a(argc, argv);

	BetDialog w;
    w.show();

    return a.exec();
}

#endif
